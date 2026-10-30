// Daily accrual/catch-up job (BR-03 goal auto-accrual; BR-01 Mode B
// carry-over advancement) — D18/M16 bug #1 & #4c.
//
// Before M16, `DailySavingsReserve` was subtracted from the displayed daily
// budget every day, but no code ever credited it to any goal's
// `currentAmount` — the money was deducted from spending but never arrived
// anywhere (bug #1). Separately, Mode B's carry-over only ever advanced by
// a single day when the user manually visited the Pay Cycle Transition
// screen, silently dropping any day(s) the app wasn't opened (bug #4c).
//
// `runCatchUp()` is the single automatic engine for both: it walks every
// full calendar day between `LocalProfile.lastAccrualDate` (exclusive) and
// today (inclusive), applying BR-03 accrual to every active goal and (Mode B
// only) advancing `carryOverBalance` one day at a time via the SAME shared
// math as the manual transition screen's preview
// (`core/budget_scope/budget_scope.dart` — see that file's header for why
// this must stay a single shared implementation). Wired to run on every
// Isar open (`core/database/isar_provider.dart`), i.e. on every app launch.
import 'package:isar_community/isar.dart';

import '../budget_scope/budget_scope.dart';
import '../database/financial_goal.dart';
import '../database/local_profile.dart';
import '../database/transaction.dart';
import '../database/wallet.dart';
import '../formulas/daily_budget_formulas.dart';

class DailyAccrualService {
  DailyAccrualService(this._isar);

  final Isar _isar;

  /// Runs the catch-up for every day since the last processed day, up to
  /// and including [referenceNow]'s calendar day. Idempotent and safe to
  /// call on every app launch — returns the number of calendar days
  /// actually processed (0 if already up to date, no profile, or
  /// onboarding incomplete).
  Future<int> runCatchUp({DateTime? referenceNow}) async {
    final now = referenceNow ?? DateTime.now();
    final today = normalizeDate(now);

    final profile = await _isar.localProfiles.where().findFirst();
    if (profile == null || !profile.onboardingComplete) return 0;

    if (profile.lastAccrualDate == null) {
      // First run ever for this profile (fresh install, or upgrading from
      // pre-M16 data with no accrual history). Seed to today WITHOUT
      // retroactively accruing for days before this fix existed — there is
      // no reliable way to know what "should have" accrued pre-M16.
      await _isar.writeTxn(() async {
        final p = await _isar.localProfiles.where().findFirst();
        if (p == null) return;
        p.lastAccrualDate = today;
        await _isar.localProfiles.put(p);
      });
      return 0;
    }

    var cursor = normalizeDate(profile.lastAccrualDate!)
        .add(const Duration(days: 1));
    var daysProcessed = 0;
    while (!cursor.isAfter(today)) {
      await _processDay(cursor);
      cursor = cursor.add(const Duration(days: 1));
      daysProcessed++;
    }
    return daysProcessed;
  }

  Future<void> _processDay(DateTime day) async {
    await _isar.writeTxn(() async {
      final profile = await _isar.localProfiles.where().findFirst();
      if (profile == null) return;

      // --- BR-03: Goal auto-accrual ---
      final goals = await _isar.financialGoals.where().findAll();
      final goalInputs = <GoalAllocationInput>[];
      for (final goal in goals) {
        goalInputs.add(
          GoalAllocationInput(
            targetAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            targetDate: goal.targetDate,
            manualDailyAllocation: goal.manualDailyAllocation,
          ),
        );
        if (goal.currentAmount >= goal.targetAmount) {
          continue; // already fulfilled — no further accrual
        }
        final allocation = calculateGoalDailyAllocation(
          targetAmount: goal.targetAmount,
          currentAmount: goal.currentAmount,
          targetDate: goal.targetDate,
          today: day,
          manualDailyAllocation: goal.manualDailyAllocation,
        );
        if (allocation > 0) {
          goal.currentAmount += allocation;
          await _isar.financialGoals.put(goal);
        }
      }

      // --- BR-01 Mode B: carry-over advance for the elapsed day ---
      if (profile.incomeFrequency == IncomeFrequency.daily) {
        final wallets = await _isar.wallets.where().findAll();
        final includedWalletIds = includedWalletIdsFrom(wallets);
        final transactions = await _isar.transactions.where().findAll();

        profile.carryOverBalance = advanceModeBCarryOverOneDay(
          startingCarryOver: profile.carryOverBalance,
          day: day,
          transactions: transactions,
          includedWalletIds: includedWalletIds,
          mandatoryExpensesForDay: profile.mandatoryExpenses,
          goals: goalInputs,
        );
      }

      profile.lastAccrualDate = day;
      await _isar.localProfiles.put(profile);
    });
  }
}

/// Convenience entrypoint used by `openLedgerMateIsar` and tests.
Future<int> runDailyAccrualCatchUp(Isar isar, {DateTime? referenceNow}) {
  return DailyAccrualService(isar).runCatchUp(referenceNow: referenceNow);
}
