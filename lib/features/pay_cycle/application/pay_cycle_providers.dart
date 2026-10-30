// Riverpod providers for M5 Pay Cycle Transition feature (FR-05, BR-02).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/budget_scope/budget_scope.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/database/wallet.dart';
import '../../../core/formulas/daily_budget_formulas.dart';
import '../../../core/time/current_day_provider.dart';
import '../../budget_engine/application/budget_providers.dart';
import '../../notifications/application/pay_cycle_notification_hook.dart';
import '../../wallets/application/wallet_providers.dart';
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

  // D18/M17 bug #4: watched so this re-evaluates on a midnight/resume
  // day-rollover alone, without requiring a data write to trigger a rebuild.
  final now = ref.watch(currentDayProvider);

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

/// Computes Mode B's carry-over balance to pre-fill the Pay Cycle Transition
/// screen, catching up every full day between `profile.lastRolloverDate`
/// and yesterday (D18/M16 bug #4):
/// (a) transfers are excluded/netted per D16, not counted as plain expense;
/// (b) only transactions in `includeInDailyBudget` wallets count (BR-04);
/// (c) if 2+ days were skipped since the user last visited this screen,
/// each skipped day is rolled over in order, not just the single most
/// recent one.
///
/// Shares its per-day math with the automatic background catch-up job
/// (`core/accrual/daily_accrual_service.dart`) via
/// `core/budget_scope/budget_scope.dart` — see that file's header for why
/// there must be exactly one implementation of this math, not two.
///
/// Known limitation (pre-existing, not introduced by this fix): historical
/// mandatory expenses for skipped days cannot be recovered — `LocalProfile.
/// mandatoryExpenses` only ever holds the MOST RECENTLY entered day's list
/// (BR-02 has no per-day history) — so the current list is used as the best
/// available approximation for every skipped day.
int computeModeBYesterdayCarryOver({
  required LocalProfile profile,
  required List<db.Transaction> transactions,
  required List<Wallet> wallets,
  required List<GoalAllocationInput> goals,
  DateTime? referenceNow,
}) {
  final now = referenceNow ?? DateTime.now();
  final today = normalizeDate(now);
  final yesterday = today.subtract(const Duration(days: 1));

  final lastProcessed = profile.lastRolloverDate != null
      ? normalizeDate(profile.lastRolloverDate!)
      : yesterday.subtract(const Duration(days: 1));

  if (!lastProcessed.isBefore(yesterday)) {
    // Already caught up through yesterday — nothing to advance.
    return profile.carryOverBalance;
  }

  return advanceModeBCarryOverAcrossDays(
    startingCarryOver: profile.carryOverBalance,
    fromDateExclusive: lastProcessed,
    toDateInclusive: yesterday,
    transactions: transactions,
    includedWalletIds: includedWalletIdsFrom(wallets),
    mandatoryExpensesForDay: profile.mandatoryExpenses,
    goals: goals,
  );
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
///
/// D18/M17 bug #5a: `build()` previously used `ref.watch(...)` on the
/// profile/transactions/goals/wallets streams. Since this is a `Notifier`,
/// `build()` re-runs and completely resets `state` every time ANY of those
/// streams emits a new value for ANY reason (e.g. the user adds an
/// unrelated transaction on another screen while this form is open in the
/// background stack) — wiping out whatever the user had already typed into
/// the transition form. `build()` must only read these ONCE to seed the
/// form's initial values, never re-trigger on later upstream changes —
/// hence `ref.read` below instead of `ref.watch`.
class PayCycleTransitionNotifier extends Notifier<PayCycleTransitionState> {
  @override
  PayCycleTransitionState build() {
    final profile = ref.read(budgetProfileStreamProvider).value;
    if (profile == null) {
      return const PayCycleTransitionState(
        incomeFrequency: IncomeFrequency.periodic,
      );
    }

    final now = ref.read(currentDayProvider);
    final intervalType =
        profile.incomeIntervalType ?? IncomeIntervalType.monthly;
    DateTime? nextPayday;
    if (profile.incomeFrequency == IncomeFrequency.periodic) {
      nextPayday = calculateDefaultNextPayday(now, intervalType);
    }

    var carryOver = 0;
    if (profile.incomeFrequency == IncomeFrequency.daily) {
      final txs = ref.read(budgetTransactionsStreamProvider).value ?? [];
      final goals = ref.read(budgetGoalsStreamProvider).value ?? [];

      final goalInputs = goals.map((g) {
        return GoalAllocationInput(
          targetAmount: g.targetAmount,
          currentAmount: g.currentAmount,
          targetDate: g.targetDate,
          manualDailyAllocation: g.manualDailyAllocation,
        );
      }).toList();

      final wallets = ref.read(walletsStreamProvider).value ?? [];

      carryOver = computeModeBYesterdayCarryOver(
        profile: profile,
        transactions: txs,
        wallets: wallets,
        goals: goalInputs,
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
    // D18/M17 bug #5b: re-entrancy guard against double-submit. Checking
    // the NOTIFIER's own authoritative `state.isSubmitting` (not a
    // widget-captured snapshot) closes the race even if two taps land in
    // the same frame before the UI has a chance to rebuild and disable the
    // button — the first call's synchronous `isSubmitting: true` write
    // below is visible to the second call immediately.
    if (state.isSubmitting) {
      return false;
    }

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
    NotifierProvider.autoDispose<
      PayCycleTransitionNotifier,
      PayCycleTransitionState
    >(PayCycleTransitionNotifier.new);
