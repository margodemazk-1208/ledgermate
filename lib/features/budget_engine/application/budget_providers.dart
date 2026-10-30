// Riverpod providers for M4 Smart Daily Budget Engine.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/budget_scope/budget_scope.dart';
import '../../../core/database/financial_goal.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/formulas/daily_budget_formulas.dart';
import '../../wallets/application/wallet_providers.dart';
import '../data/budget_repository.dart';

final budgetRepositoryProvider = Provider<BudgetRepositoryBase>((ref) {
  return BudgetRepository(ref.watch(isarProvider));
});

final budgetProfileStreamProvider = StreamProvider<LocalProfile?>((ref) {
  return ref.watch(budgetRepositoryProvider).watchProfile();
});

final budgetLatestPayCycleStreamProvider = StreamProvider<PayCycle?>((ref) {
  return ref.watch(budgetRepositoryProvider).watchLatestPayCycle();
});

final budgetTransactionsStreamProvider = StreamProvider<List<db.Transaction>>((
  ref,
) {
  return ref.watch(budgetRepositoryProvider).watchTransactions();
});

final budgetGoalsStreamProvider = StreamProvider<List<FinancialGoal>>((ref) {
  return ref.watch(budgetRepositoryProvider).watchGoals();
});

/// High-level presentation-ready daily budget state.
class DailyBudgetSummary {
  const DailyBudgetSummary({
    required this.incomeFrequency,
    required this.uangJajanAmanHariIni,
    required this.dailySavingsReserve,
    this.modeA,
    this.modeB,
    this.isCycleExpired = false,
  });

  final IncomeFrequency incomeFrequency;
  final int uangJajanAmanHariIni;
  final int dailySavingsReserve;
  final ModeABudgetResult? modeA;
  final ModeBBudgetResult? modeB;
  final bool isCycleExpired;

  bool get isPositive => uangJajanAmanHariIni >= 0;
}

/// Pure adapter mapping DB entities into the pure formula engine
/// in `lib/core/formulas/daily_budget_formulas.dart`.
///
/// Wallet/transfer scoping (BR-04, D16) is delegated to the SHARED helper in
/// `core/budget_scope/budget_scope.dart` — this is one of the 4 call sites
/// documented there; do not reimplement the filtering inline here again
/// (that regression is exactly D18/M16 bug #4 & #7).
DailyBudgetSummary computeDailyBudgetSummary({
  required LocalProfile profile,
  PayCycle? latestCycle,
  required List<db.Transaction> transactions,
  required List<FinancialGoal> goals,
  Set<int>? includedWalletIds,
  DateTime? referenceNow,
}) {
  final now = referenceNow ?? DateTime.now();

  // Convert Isar FinancialGoal models to pure GoalAllocationInput
  final goalInputs = goals.map((g) {
    return GoalAllocationInput(
      targetAmount: g.targetAmount,
      currentAmount: g.currentAmount,
      targetDate: g.targetDate,
      manualDailyAllocation: g.manualDailyAllocation,
    );
  }).toList();

  final dailySavingsReserve = calculateDailySavingsReserve(
    goals: goalInputs,
    today: now,
  );

  if (profile.incomeFrequency == IncomeFrequency.periodic) {
    // Mode A: Periodik (Lump-sum pay cycle)
    final payday = latestCycle?.paydayDate ?? profile.nextPaydayDate ?? now;
    final remainingDays = calculateRemainingDays(now, payday);
    final isExpired = isModeACycleExpired(today: now, paydayDate: payday);

    final cycleId = latestCycle?.id;
    final cycleStart = latestCycle?.startDate;

    final cycleTxs = transactions.where((tx) {
      if (cycleId != null && tx.payCycleId != null) {
        return tx.payCycleId == cycleId;
      }
      if (cycleStart != null) {
        return !tx.date.isBefore(cycleStart);
      }
      return true;
    }).toList();

    final totals = sumBudgetScopedTransactions(
      transactions: cycleTxs,
      includedWalletIds: includedWalletIds,
      predicate: (_) => true,
    );

    final mandatoryExpenses =
        latestCycle?.mandatoryExpenses.fold<int>(
          0,
          (sum, item) => sum + item.amount,
        ) ??
        0;

    final fixedIncome = latestCycle?.fixedSalary ?? profile.fixedSalary;

    final modeAResult = calculateModeABudget(
      fixedIncome: fixedIncome,
      additionalIncome: totals.income,
      mandatoryExpenses: mandatoryExpenses,
      recordedExpenses: totals.expense,
      remainingDays: remainingDays,
      dailySavingsReserve: dailySavingsReserve,
    );

    return DailyBudgetSummary(
      incomeFrequency: IncomeFrequency.periodic,
      uangJajanAmanHariIni: modeAResult.uangJajanAmanHariIni,
      dailySavingsReserve: dailySavingsReserve,
      modeA: modeAResult,
      isCycleExpired: isExpired,
    );
  } else {
    // Mode B: Harian (Bekel harian/irregular)
    final isRolloverDue = isModeBDailyRolloverDue(
      today: now,
      lastRolloverDate: profile.lastRolloverDate,
      transactionDates: transactions.map((t) => t.date).toList(),
    );

    final totals = sumBudgetScopedTransactions(
      transactions: transactions,
      includedWalletIds: includedWalletIds,
      predicate: (tx) => isSameCalendarDay(tx.date, now),
    );

    final pengeluaranWajibHariIni = profile.mandatoryExpenses.fold<int>(
      0,
      (sum, item) => sum + item.amount,
    );

    final saldoCarryOver = profile.carryOverBalance;

    final modeBResult = calculateModeBBudget(
      saldoCarryOver: saldoCarryOver,
      bekelHariIni: totals.income,
      pengeluaranWajibHariIni: pengeluaranWajibHariIni,
      pengeluaranHariIni: totals.expense,
      dailySavingsReserve: dailySavingsReserve,
    );

    return DailyBudgetSummary(
      incomeFrequency: IncomeFrequency.daily,
      uangJajanAmanHariIni: modeBResult.uangJajanAmanHariIni,
      dailySavingsReserve: dailySavingsReserve,
      modeB: modeBResult,
      isCycleExpired: isRolloverDue,
    );
  }
}

/// Reactively recomputed whenever profile, pay cycles, transactions, goals,
/// or wallets change.
///
/// D18/M16 bug #8: ALL FOUR source streams (profile, pay cycle, transactions,
/// goals) plus the wallets stream must finish loading before any number is
/// computed — gating on only some of them let a transiently-wrong number
/// (computed with `latestCycle: null` or `includedWalletIds: null` before
/// the real data arrived) flash on screen, which M14's count-up animation
/// would then visibly animate away from. The UI shows its skeleton loader
/// for the `AsyncValue.loading()` case instead (`budget_home_screen.dart`).
final dailyBudgetSummaryProvider = Provider<AsyncValue<DailyBudgetSummary>>((
  ref,
) {
  final profileAsync = ref.watch(budgetProfileStreamProvider);
  final cycleAsync = ref.watch(budgetLatestPayCycleStreamProvider);
  final txsAsync = ref.watch(budgetTransactionsStreamProvider);
  final goalsAsync = ref.watch(budgetGoalsStreamProvider);
  final walletsAsync = ref.watch(walletsStreamProvider);

  if (profileAsync.hasError) {
    return AsyncValue.error(profileAsync.error!, profileAsync.stackTrace!);
  }
  if (cycleAsync.hasError) {
    return AsyncValue.error(cycleAsync.error!, cycleAsync.stackTrace!);
  }
  if (txsAsync.hasError) {
    return AsyncValue.error(txsAsync.error!, txsAsync.stackTrace!);
  }
  if (goalsAsync.hasError) {
    return AsyncValue.error(goalsAsync.error!, goalsAsync.stackTrace!);
  }
  if (walletsAsync.hasError) {
    return AsyncValue.error(walletsAsync.error!, walletsAsync.stackTrace!);
  }

  if (profileAsync.isLoading ||
      cycleAsync.isLoading ||
      txsAsync.isLoading ||
      goalsAsync.isLoading ||
      walletsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final profile = profileAsync.value;
  if (profile == null) {
    return const AsyncValue.loading();
  }

  final wallets = walletsAsync.value ?? const [];
  final includedWalletIds = includedWalletIdsFrom(wallets);

  final summary = computeDailyBudgetSummary(
    profile: profile,
    latestCycle: cycleAsync.value,
    transactions: txsAsync.value ?? const [],
    goals: goalsAsync.value ?? const [],
    includedWalletIds: includedWalletIds,
  );

  return AsyncValue.data(summary);
});
