// Riverpod providers for M5 Pay Cycle Transition feature (FR-05, BR-02).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/formulas/daily_budget_formulas.dart';
import '../../budget_engine/application/budget_providers.dart';
import '../../notifications/application/pay_cycle_notification_hook.dart';
import '../data/pay_cycle_repository.dart';
import 'pay_cycle_transition_state.dart';

final payCycleRepositoryProvider = Provider<PayCycleRepositoryBase>((ref) {
  final isar = ref.watch(isarProvider);
  final hook = ref.watch(payCycleNotificationHookProvider);
  return PayCycleRepository(isar, hook);
});

/// Reactively calculates whether a pay cycle transition (Mode A) or
/// daily rollover (Mode B) is currently due (FR-05).
final isCycleTransitionDueProvider = Provider<AsyncValue<bool>>((ref) {
  final profileAsync = ref.watch(budgetProfileStreamProvider);
  final cycleAsync = ref.watch(budgetLatestPayCycleStreamProvider);
  final txsAsync = ref.watch(budgetTransactionsStreamProvider);

  if (profileAsync.hasError) {
    return AsyncValue.error(profileAsync.error!, profileAsync.stackTrace!);
  }
  if (cycleAsync.hasError) {
    return AsyncValue.error(cycleAsync.error!, cycleAsync.stackTrace!);
  }
  if (txsAsync.hasError) {
    return AsyncValue.error(txsAsync.error!, txsAsync.stackTrace!);
  }

  if (profileAsync.isLoading || txsAsync.isLoading) {
    return const AsyncValue.loading();
  }

  final profile = profileAsync.value;
  if (profile == null || !profile.onboardingComplete) {
    return const AsyncValue.data(false);
  }

  final now = DateTime.now();

  if (profile.incomeFrequency == IncomeFrequency.periodic) {
    final latestCycle = cycleAsync.value;
    final payday = latestCycle?.paydayDate ?? profile.nextPaydayDate;
    if (payday == null) return const AsyncValue.data(false);

    final isExpired = isModeACycleExpired(today: now, paydayDate: payday);
    return AsyncValue.data(isExpired);
  } else {
    final txs = txsAsync.value ?? [];
    final isDue = isModeBDailyRolloverDue(
      today: now,
      lastRolloverDate: profile.lastRolloverDate,
      transactionDates: txs.map((t) => t.date).toList(),
    );
    return AsyncValue.data(isDue);
  }
});

/// Pure helper to compute Mode B carry-over balance from yesterday
/// per BR-01 & BR-02 formulas.
int computeModeBYesterdayCarryOver({
  required LocalProfile profile,
  required List<db.Transaction> transactions,
  required int dailySavingsReserve,
  DateTime? referenceNow,
}) {
  final now = referenceNow ?? DateTime.now();
  final todayMidnight = normalizeDate(now);

  final lastDate = profile.lastRolloverDate != null
      ? normalizeDate(profile.lastRolloverDate!)
      : todayMidnight.subtract(const Duration(days: 1));

  var bekelKemarin = 0;
  var pengeluaranKemarin = 0;
  for (final tx in transactions) {
    if (isSameCalendarDay(tx.date, lastDate)) {
      if (tx.type == db.TransactionType.income) {
        bekelKemarin += tx.amount;
      } else {
        pengeluaranKemarin += tx.amount;
      }
    }
  }

  final pengeluaranWajibKemarin = profile.mandatoryExpenses.fold<int>(
    0,
    (sum, item) => sum + item.amount,
  );

  final previousCarryOver = profile.carryOverBalance;

  final yesterdayBudget = calculateModeBBudget(
    saldoCarryOver: previousCarryOver,
    bekelHariIni: bekelKemarin,
    pengeluaranWajibHariIni: pengeluaranWajibKemarin,
    pengeluaranHariIni: pengeluaranKemarin,
    dailySavingsReserve: dailySavingsReserve,
  );

  return calculateNextDayCarryOver(yesterdayBudget.uangJajanAmanHariIni);
}

DateTime calculateDefaultNextPayday(
  DateTime startDate,
  IncomeIntervalType type,
) {
  switch (type) {
    case IncomeIntervalType.weekly:
      return startDate.add(const Duration(days: 7));
    case IncomeIntervalType.biweekly:
      return startDate.add(const Duration(days: 14));
    case IncomeIntervalType.monthly:
      final nextMonth = startDate.month == 12 ? 1 : startDate.month + 1;
      final year = startDate.month == 12 ? startDate.year + 1 : startDate.year;
      final daysInNextMonth = DateTime(year, nextMonth + 1, 0).day;
      final day = startDate.day > daysInNextMonth
          ? daysInNextMonth
          : startDate.day;
      return DateTime(year, nextMonth, day);
    case IncomeIntervalType.custom:
      return startDate.add(const Duration(days: 30));
  }
}

/// Manages transition form state for FR-05 pay cycle transition.
class PayCycleTransitionNotifier extends Notifier<PayCycleTransitionState> {
  @override
  PayCycleTransitionState build() {
    final profile = ref.watch(budgetProfileStreamProvider).value;
    if (profile == null) {
      return const PayCycleTransitionState(
        incomeFrequency: IncomeFrequency.periodic,
      );
    }

    final now = DateTime.now();
    final intervalType =
        profile.incomeIntervalType ?? IncomeIntervalType.monthly;
    DateTime? nextPayday;
    if (profile.incomeFrequency == IncomeFrequency.periodic) {
      nextPayday = calculateDefaultNextPayday(now, intervalType);
    }

    var carryOver = 0;
    if (profile.incomeFrequency == IncomeFrequency.daily) {
      final txs = ref.watch(budgetTransactionsStreamProvider).value ?? [];
      final goals = ref.watch(budgetGoalsStreamProvider).value ?? [];

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

      carryOver = computeModeBYesterdayCarryOver(
        profile: profile,
        transactions: txs,
        dailySavingsReserve: dailySavingsReserve,
        referenceNow: now,
      );
    }

    return PayCycleTransitionState(
      incomeFrequency: profile.incomeFrequency,
      nextPaydayDate: nextPayday,
      incomeIntervalType: intervalType,
      yesterdayCarryOver: carryOver,
    );
  }

  void initialize({
    required IncomeFrequency frequency,
    DateTime? initialNextPaydayDate,
    IncomeIntervalType? intervalType,
    int yesterdayCarryOver = 0,
  }) {
    state = PayCycleTransitionState(
      incomeFrequency: frequency,
      nextPaydayDate: initialNextPaydayDate,
      incomeIntervalType: intervalType ?? IncomeIntervalType.monthly,
      yesterdayCarryOver: yesterdayCarryOver,
    );
  }

  void setNextPaydayDate(DateTime date) {
    state = state.copyWith(nextPaydayDate: date);
  }

  void setIncomeIntervalType(IncomeIntervalType type) {
    state = state.copyWith(incomeIntervalType: type);
  }

  void setFixedSalary(int? salary) {
    state = state.copyWith(fixedSalary: salary);
  }

  void addMandatoryExpense(MandatoryExpenseItem item) {
    state = state.copyWith(
      mandatoryExpenses: [...state.mandatoryExpenses, item],
    );
  }

  void removeMandatoryExpenseAt(int index) {
    final list = [...state.mandatoryExpenses]..removeAt(index);
    state = state.copyWith(mandatoryExpenses: list);
  }

  void setTodayBekel(int? amount) {
    state = state.copyWith(todayBekelIncome: amount);
  }

  void addTodayMandatoryExpense(MandatoryExpenseItem item) {
    state = state.copyWith(
      todayMandatoryExpenses: [...state.todayMandatoryExpenses, item],
    );
  }

  void removeTodayMandatoryExpenseAt(int index) {
    final list = [...state.todayMandatoryExpenses]..removeAt(index);
    state = state.copyWith(todayMandatoryExpenses: list);
  }

  Future<bool> submitTransition({DateTime? referenceNow}) async {
    if (!state.canSubmit) {
      state = state.copyWith(
        submitError: 'Harap lengkapi semua data yang diperlukan.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    final repo = ref.read(payCycleRepositoryProvider);

    try {
      if (state.isPeriodic) {
        await repo.completeModeATransition(
          fixedSalary: state.fixedSalary!,
          nextPaydayDate: state.nextPaydayDate!,
          incomeIntervalType: state.incomeIntervalType,
          mandatoryExpenses: state.mandatoryExpenses,
          referenceNow: referenceNow,
        );
      } else {
        await repo.completeModeBTransition(
          carryOverBalance: state.yesterdayCarryOver,
          todayMandatoryExpenses: state.todayMandatoryExpenses,
          todayBekelIncome: state.todayBekelIncome,
          referenceNow: referenceNow,
        );
      }

      state = state.copyWith(isSubmitting: false, isSuccess: true);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submitError: e.toString());
      return false;
    }
  }
}

final payCycleTransitionNotifierProvider =
    NotifierProvider<PayCycleTransitionNotifier, PayCycleTransitionState>(
      PayCycleTransitionNotifier.new,
    );
