// Riverpod providers for M4 Smart Daily Budget Engine.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/financial_goal.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/formulas/daily_budget_formulas.dart';
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
  });

  final IncomeFrequency incomeFrequency;
  final int uangJajanAmanHariIni;
  final int dailySavingsReserve;
  final ModeABudgetResult? modeA;
  final ModeBBudgetResult? modeB;

  bool get isPositive => uangJajanAmanHariIni >= 0;
}

/// Helper to check if two dates share the exact same calendar day.
bool isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Pure adapter mapping DB entities into the pure formula engine
/// in `lib/core/formulas/daily_budget_formulas.dart`.
DailyBudgetSummary computeDailyBudgetSummary({
  required LocalProfile profile,
  PayCycle? latestCycle,
  required List<db.Transaction> transactions,
  required List<FinancialGoal> goals,
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

    var additionalIncome = 0;
    var recordedExpenses = 0;
    for (final tx in cycleTxs) {
      if (tx.type == db.TransactionType.income) {
        additionalIncome += tx.amount;
      } else {
        recordedExpenses += tx.amount;
      }
    }

    final mandatoryExpenses =
        latestCycle?.mandatoryExpenses.fold<int>(
          0,
          (sum, item) => sum + item.amount,
        ) ??
        0;

    final fixedIncome = latestCycle?.fixedSalary ?? profile.fixedSalary;

    final modeAResult = calculateModeABudget(
      fixedIncome: fixedIncome,
      additionalIncome: additionalIncome,
      mandatoryExpenses: mandatoryExpenses,
      recordedExpenses: recordedExpenses,
      remainingDays: remainingDays,
      dailySavingsReserve: dailySavingsReserve,
    );

    return DailyBudgetSummary(
      incomeFrequency: IncomeFrequency.periodic,
      uangJajanAmanHariIni: modeAResult.uangJajanAmanHariIni,
      dailySavingsReserve: dailySavingsReserve,
      modeA: modeAResult,
    );
  } else {
    // Mode B: Harian (Bekel harian/irregular)
    var bekelHariIni = 0;
    var pengeluaranHariIni = 0;
    for (final tx in transactions) {
      if (isSameCalendarDay(tx.date, now)) {
        if (tx.type == db.TransactionType.income) {
          bekelHariIni += tx.amount;
        } else {
          pengeluaranHariIni += tx.amount;
        }
      }
    }

    final pengeluaranWajibHariIni = profile.mandatoryExpenses.fold<int>(
      0,
      (sum, item) => sum + item.amount,
    );

    final saldoCarryOver = profile.carryOverBalance;

    final modeBResult = calculateModeBBudget(
      saldoCarryOver: saldoCarryOver,
      bekelHariIni: bekelHariIni,
      pengeluaranWajibHariIni: pengeluaranWajibHariIni,
      pengeluaranHariIni: pengeluaranHariIni,
      dailySavingsReserve: dailySavingsReserve,
    );

    return DailyBudgetSummary(
      incomeFrequency: IncomeFrequency.daily,
      uangJajanAmanHariIni: modeBResult.uangJajanAmanHariIni,
      dailySavingsReserve: dailySavingsReserve,
      modeB: modeBResult,
    );
  }
}

/// Reactively recomputed whenever profile, pay cycles, transactions, or goals change.
final dailyBudgetSummaryProvider = Provider<AsyncValue<DailyBudgetSummary>>((
  ref,
) {
  final profileAsync = ref.watch(budgetProfileStreamProvider);
  final cycleAsync = ref.watch(budgetLatestPayCycleStreamProvider);
  final txsAsync = ref.watch(budgetTransactionsStreamProvider);
  final goalsAsync = ref.watch(budgetGoalsStreamProvider);

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

  if (profileAsync.isLoading || txsAsync.isLoading || goalsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final profile = profileAsync.value;
  if (profile == null) {
    return const AsyncValue.loading();
  }

  final summary = computeDailyBudgetSummary(
    profile: profile,
    latestCycle: cycleAsync.value,
    transactions: txsAsync.value ?? const [],
    goals: goalsAsync.value ?? const [],
  );

  return AsyncValue.data(summary);
});
