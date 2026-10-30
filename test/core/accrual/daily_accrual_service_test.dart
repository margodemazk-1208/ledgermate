// Unit tests for DailyAccrualService (D18/M16 bug #1 & #4c).
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/accrual/daily_accrual_service.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/core/time/current_day_provider.dart';
import 'package:ledgermate/features/goals/application/goals_providers.dart';
import 'package:ledgermate/features/onboarding/data/onboarding_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late DailyAccrualService service;
  var instanceCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('accrual_test_');
    instanceCounter++;
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'accrual_test_$instanceCounter',
    );
    service = DailyAccrualService(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('D18/M16 bug #1: goal auto-accrual was never implemented', () {
    test('a goal\'s currentAmount increases by its daily allocation after one day passes', () async {
      await isar.writeTxn(() async {
        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..onboardingComplete = true
          // Seeded as if the job already ran yesterday.
          ..lastAccrualDate = DateTime(2026, 10, 27);
        await isar.localProfiles.put(profile);

        final goal = FinancialGoal()
          ..goalName = 'Dana Darurat'
          ..targetAmount = 1000000
          ..currentAmount = 0
          ..targetDate = DateTime(2026, 11, 6); // 10 days from Oct 27
        await isar.financialGoals.put(goal);
      });

      final processed = await service.runCatchUp(
        referenceNow: DateTime(2026, 10, 28),
      );

      expect(processed, 1); // exactly one elapsed day: Oct 28

      final goal = await isar.financialGoals.where().findFirst();
      // Before M16, this was 0 forever — the reserve was deducted from the
      // displayed budget but never credited anywhere. BR-03's daily
      // allocation is recomputed for the day actually being accrued
      // (Oct 28 -> target Nov 6 is 9 days remaining):
      // ceil(1,000,000 / 9) = 111,112.
      expect(goal!.currentAmount, 111112);

      final profile = await isar.localProfiles.where().findFirst();
      expect(profile!.lastAccrualDate, DateTime(2026, 10, 28));
    });

    test(
      'manualDailyAllocation override is honored by the accrual job',
      () async {
        await isar.writeTxn(() async {
          final profile = LocalProfile()
            ..incomeFrequency = IncomeFrequency.periodic
            ..onboardingComplete = true
            ..lastAccrualDate = DateTime(2026, 10, 27);
          await isar.localProfiles.put(profile);

          final goal = FinancialGoal()
            ..goalName = 'Custom Override'
            ..targetAmount = 10000000
            ..currentAmount = 0
            ..targetDate = DateTime(2027, 1, 1)
            ..manualDailyAllocation = 20000;
          await isar.financialGoals.put(goal);
        });

        await service.runCatchUp(referenceNow: DateTime(2026, 10, 28));

        final goal = await isar.financialGoals.where().findFirst();
        expect(goal!.currentAmount, 20000);
      },
    );

    test('a fulfilled goal does not over-accrue past its target', () async {
      await isar.writeTxn(() async {
        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..onboardingComplete = true
          ..lastAccrualDate = DateTime(2026, 10, 27);
        await isar.localProfiles.put(profile);

        final goal = FinancialGoal()
          ..goalName = 'Sudah Tercapai'
          ..targetAmount = 500000
          ..currentAmount = 500000
          ..targetDate = DateTime(2026, 11, 1);
        await isar.financialGoals.put(goal);
      });

      await service.runCatchUp(referenceNow: DateTime(2026, 10, 28));

      final goal = await isar.financialGoals.where().findFirst();
      expect(goal!.currentAmount, 500000); // unchanged
    });

    test('first-ever run seeds lastAccrualDate to today WITHOUT retroactively accruing', () async {
      await isar.writeTxn(() async {
        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..onboardingComplete = true; // lastAccrualDate == null
        await isar.localProfiles.put(profile);

        final goal = FinancialGoal()
          ..goalName = 'Goal Lama'
          ..targetAmount = 1000000
          ..currentAmount = 0
          ..targetDate = DateTime(2026, 12, 1);
        await isar.financialGoals.put(goal);
      });

      final processed = await service.runCatchUp(
        referenceNow: DateTime(2026, 10, 28),
      );

      expect(processed, 0); // seeding only, no day actually processed
      final goal = await isar.financialGoals.where().findFirst();
      expect(goal!.currentAmount, 0); // no retroactive accrual

      final profile = await isar.localProfiles.where().findFirst();
      expect(profile!.lastAccrualDate, DateTime(2026, 10, 28));
    });

    test('does nothing before onboarding is complete', () async {
      await isar.writeTxn(() async {
        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..onboardingComplete = false
          ..lastAccrualDate = DateTime(2026, 10, 20);
        await isar.localProfiles.put(profile);
      });

      final processed = await service.runCatchUp(
        referenceNow: DateTime(2026, 10, 28),
      );
      expect(processed, 0);
    });
  });

  group(
    'D18/M16 bug #4c: Mode B carry-over catch-up for multiple missed days',
    () {
      test('advances carryOverBalance for every elapsed day the app was closed, not just one', () async {
        final wallet = Wallet()
          ..name = 'Tunai'
          ..icon = 'wallet'
          ..startingBalance = 0
          ..includeInDailyBudget = true
          ..createdAt = DateTime(2026, 1, 1);

        await isar.writeTxn(() async {
          final w = wallet;
          final id = await isar.wallets.put(w);
          w.id = id;

          final profile = LocalProfile()
            ..incomeFrequency = IncomeFrequency.daily
            ..onboardingComplete = true
            ..carryOverBalance = 0
            ..lastAccrualDate = DateTime(2026, 10, 24);
          await isar.localProfiles.put(profile);

          // 50,000 income recorded on each of 3 days the app wasn't opened.
          for (final day in [25, 26, 27]) {
            await isar.transactions.put(
              db.Transaction()
                ..type = db.TransactionType.income
                ..amount = 50000
                ..walletId = w.id
                ..date = DateTime(2026, 10, day),
            );
          }
        });

        final processed = await service.runCatchUp(
          referenceNow: DateTime(2026, 10, 28),
        );

        expect(processed, 4); // Oct 25, 26, 27, 28

        final profile = await isar.localProfiles.where().findFirst();
        // Each of the 3 days with recorded income accrues 50,000 unspent;
        // Oct 28 (today, no transactions yet) accrues 0 more.
        expect(profile!.carryOverBalance, 150000);
      });
    },
  );

  group('M24: Goal Accrual Same-Day Fix (v1.4 Phase 4)', () {
    test('reproduction: fresh onboarding completes today -> user creates goal today -> runCatchUp accrues today immediately', () async {
      final today = DateTime(2026, 10, 28, 10, 0);
      final onboardingRepo = OnboardingRepository(isar);

      // 1. Fresh onboarding completes on reference date `today`
      await onboardingRepo.completeOnboarding(
        incomeFrequency: IncomeFrequency.periodic,
        incomeIntervalType: IncomeIntervalType.monthly,
        nextPaydayDate: DateTime(2026, 11, 28),
        initialIncomeAmount: 5000000,
        mandatoryExpenses: const [],
        referenceNow: today,
      );

      // 2. User creates and funds a goal on `today`
      // 9 days remaining to Nov 6 from Oct 28: ceil(1000000 / 9) = 111112.
      await isar.writeTxn(() async {
        final goal = FinancialGoal()
          ..goalName = 'Dana Darurat'
          ..targetAmount = 1000000
          ..currentAmount = 0
          ..targetDate = DateTime(2026, 11, 6);
        await isar.financialGoals.put(goal);
      });

      // 3. Catch-up runs (as it would on the same session/launch)
      final processed = await service.runCatchUp(referenceNow: today);

      // Pre-fix: processed was 0 because lastAccrualDate was null and hit the
      // silent-seed-and-skip branch, leaving goal.currentAmount at 0 until tomorrow.
      // Post-fix: lastAccrualDate was seeded to yesterday by onboarding, so today
      // is processed immediately!
      expect(processed, 1);

      final goal = await isar.financialGoals.where().findFirst();
      expect(goal!.currentAmount, 111112);

      final profile = await isar.localProfiles.where().findFirst();
      expect(profile!.lastAccrualDate, DateTime(2026, 10, 28));
    });

    test('pre-M16-upgrade path is UNCHANGED: existing profile with null lastAccrualDate still silently seeds without retroactive accrual', () async {
      final today = DateTime(2026, 10, 28, 10, 0);

      // Simulate existing profile upgrading from pre-M16 data:
      // onboardingComplete is true, but lastAccrualDate is null.
      await isar.writeTxn(() async {
        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..onboardingComplete = true; // lastAccrualDate == null
        await isar.localProfiles.put(profile);

        final goal = FinancialGoal()
          ..goalName = 'Goal Lama'
          ..targetAmount = 1000000
          ..currentAmount = 0
          ..targetDate = DateTime(2026, 12, 1);
        await isar.financialGoals.put(goal);
      });

      final processed = await service.runCatchUp(referenceNow: today);

      // Upgrade path: zero days processed, no retroactive credit, seeds to today.
      expect(processed, 0);
      final goal = await isar.financialGoals.where().findFirst();
      expect(goal!.currentAmount, 0);

      final profile = await isar.localProfiles.where().findFirst();
      expect(profile!.lastAccrualDate, DateTime(2026, 10, 28));
    });

    test('item 2: resume-triggered catch-up across a day boundary without a cold relaunch', () async {
      // App was active yesterday (Oct 27) and up-to-date with accruals.
      await isar.writeTxn(() async {
        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..onboardingComplete = true
          ..lastAccrualDate = DateTime(2026, 10, 27);
        await isar.localProfiles.put(profile);

        final goal = FinancialGoal()
          ..goalName = 'Target Liburan'
          ..targetAmount = 1000000
          ..currentAmount = 0
          ..targetDate = DateTime(2026, 11, 6); // 9 days from Oct 28
        await isar.financialGoals.put(goal);
      });

      // Setup container with injectable systemClock and Isar
      var fakeNow = DateTime(2026, 10, 27, 23, 0);
      final container = ProviderContainer(
        overrides: [
          isarProvider.overrideWithValue(isar),
          systemClockProvider.overrideWithValue(() => fakeNow),
        ],
      );
      addTearDown(container.dispose);

      // App backgrounded across day boundary; resumed on Oct 28 at 08:00
      fakeNow = DateTime(2026, 10, 28, 8, 0);

      // Simulate app resume trigger: refresh day provider + run accrual catch-up
      container.read(currentDayProvider.notifier).refresh();
      final processed = await runDailyAccrualCatchUp(
        container.read(isarProvider),
        referenceNow: container.read(systemClockProvider)(),
      );

      expect(processed, 1);

      final goal = await isar.financialGoals.where().findFirst();
      expect(goal!.currentAmount, 111112);

      final profile = await isar.localProfiles.where().findFirst();
      expect(profile!.lastAccrualDate, DateTime(2026, 10, 28));
    });

    test('item 3: goal progress UI / reactive stream reflects post-accrual state immediately without manual refresh', () async {
      await isar.writeTxn(() async {
        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..onboardingComplete = true
          ..lastAccrualDate = DateTime(2026, 10, 27);
        await isar.localProfiles.put(profile);

        final goal = FinancialGoal()
          ..goalName = 'Reactive Goal'
          ..targetAmount = 500000
          ..currentAmount = 0
          ..targetDate = DateTime(2026, 11, 1); // 4 days remaining from Oct 28
        await isar.financialGoals.put(goal);
      });

      final container = ProviderContainer(
        overrides: [isarProvider.overrideWithValue(isar)],
      );
      addTearDown(container.dispose);

      // Watch goals overview summary (which drives GoalsScreen UI)
      final emittedTotals = <int>[];
      final sub = container.listen<AsyncValue<GoalsOverviewSummary>>(
        goalsOverviewSummaryProvider,
        (prev, next) {
          if (next.hasValue) {
            emittedTotals.add(next.value!.totalCurrentAmount);
          }
        },
        fireImmediately: true,
      );
      addTearDown(sub.close);

      // Wait for stream to emit initial data
      await pumpEventQueue();
      expect(emittedTotals, isNotEmpty);
      expect(emittedTotals.first, 0);

      // Run catch-up for Oct 28
      // ceil(500000 / 4) = 125000
      await service.runCatchUp(referenceNow: DateTime(2026, 10, 28));

      // Pump event loop for Isar stream watcher to deliver update
      await pumpEventQueue();

      // Reactive stream must have received the updated state immediately
      expect(emittedTotals.last, 125000);
    });
  });
}
