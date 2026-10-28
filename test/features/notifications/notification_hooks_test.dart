import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/notifications/application/goal_notification_hook.dart';
import 'package:ledgermate/features/notifications/application/limit_alert_hook.dart';
import 'package:ledgermate/features/notifications/application/pay_cycle_notification_hook.dart';
import 'package:ledgermate/features/notifications/data/notification_service.dart';

import 'fake_notification_service.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late FakeNotificationService fakeNotif;
  late ProviderContainer container;
  var instanceCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'ledgermate_notif_hooks_test_',
    );
    instanceCounter++;
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'notif_hooks_test_$instanceCounter',
    );
    fakeNotif = FakeNotificationService();

    container = ProviderContainer(
      overrides: [
        isarProvider.overrideWithValue(isar),
        notificationServiceProvider.overrideWithValue(fakeNotif),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('PayCycleNotificationHook (FR-11 reminder type 3)', () {
    test('dispatches alert on pay cycle start when enabled', () async {
      final profile = LocalProfile()..notifPayCycleEnabled = true;
      await isar.writeTxn(() => isar.localProfiles.put(profile));

      final hook = container.read(payCycleNotificationHookProvider);
      await hook.onPayCycleStarted(
        incomeFrequency: IncomeFrequency.periodic,
        nextPaydayDate: DateTime(2026, 11, 25),
        incomeAmount: 5000000,
      );

      expect(fakeNotif.payCycleAlerts.length, 1);
      expect(fakeNotif.payCycleAlerts.first['title'], 'Siklus Baru Dimulai');
    });

    test('does not dispatch if disabled in profile', () async {
      final profile = LocalProfile()..notifPayCycleEnabled = false;
      await isar.writeTxn(() => isar.localProfiles.put(profile));

      final hook = container.read(payCycleNotificationHookProvider);
      await hook.onPayCycleStarted(
        incomeFrequency: IncomeFrequency.daily,
        incomeAmount: 100000,
      );

      expect(fakeNotif.payCycleAlerts, isEmpty);
    });

    test('dispatches expired alert when cycle ends', () async {
      final profile = LocalProfile()..notifPayCycleEnabled = true;
      await isar.writeTxn(() => isar.localProfiles.put(profile));

      final hook = container.read(payCycleNotificationHookProvider);
      await hook.onPayCycleExpired(
        incomeFrequency: IncomeFrequency.periodic,
        expiredDate: DateTime.now(),
      );

      expect(fakeNotif.payCycleAlerts.length, 1);
      expect(
        fakeNotif.payCycleAlerts.first['title'],
        'Siklus Gajian Telah Tiba!',
      );
    });
  });

  group('GoalNotificationHook (FR-11 reminder type 4)', () {
    test(
      'triggers alert when goal crosses 25%, 50%, 75%, or 100% milestone',
      () async {
        final profile = LocalProfile()..notifGoalMilestoneEnabled = true;
        await isar.writeTxn(() => isar.localProfiles.put(profile));

        final hook = container.read(goalNotificationHookProvider);
        // Cross 50% milestone (from 400k to 550k on a 1.000.000 target)
        await hook.onGoalProgressChanged(
          goalName: 'Dana Darurat',
          targetAmount: 1000000,
          oldCurrentAmount: 400000,
          newCurrentAmount: 550000,
        );

        expect(fakeNotif.goalMilestoneAlerts.length, 1);
        expect(fakeNotif.goalMilestoneAlerts.first['goalName'], 'Dana Darurat');
        expect(fakeNotif.goalMilestoneAlerts.first['milestonePercent'], 50);
      },
    );

    test('does not trigger if milestone was not crossed', () async {
      final profile = LocalProfile()..notifGoalMilestoneEnabled = true;
      await isar.writeTxn(() => isar.localProfiles.put(profile));

      final hook = container.read(goalNotificationHookProvider);
      // From 510k to 520k (both within 50% to 75% range)
      await hook.onGoalProgressChanged(
        goalName: 'Laptop Baru',
        targetAmount: 1000000,
        oldCurrentAmount: 510000,
        newCurrentAmount: 520000,
      );

      expect(fakeNotif.goalMilestoneAlerts, isEmpty);
    });
  });

  group('LimitAlertHook (FR-11 reminder type 2)', () {
    test('triggers limit alert when uang jajan aman hari ini <= 0', () async {
      final today = DateTime.now();
      final profile = LocalProfile()
        ..notifLimitAlertEnabled = true
        ..incomeFrequency = IncomeFrequency.periodic;
      await isar.writeTxn(() => isar.localProfiles.put(profile));

      final cycle = PayCycle()
        ..fixedSalary = 1000000
        ..startDate = today.subtract(const Duration(days: 1))
        ..paydayDate = today.add(const Duration(days: 9));
      await isar.writeTxn(() => isar.payCycles.put(cycle));

      // Add a heavy transaction that wipes out today's budget
      final tx = db.Transaction()
        ..amount = 2000000
        ..type = db.TransactionType.expense
        ..categoryId = 1
        ..date = today;
      await isar.writeTxn(() => isar.transactions.put(tx));

      final hook = container.read(limitAlertHookProvider);
      await hook.onTransactionSaved();

      expect(fakeNotif.limitExceededAlerts.length, 1);
    });
  });
}
