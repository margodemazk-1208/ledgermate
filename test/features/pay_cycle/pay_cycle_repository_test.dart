// Real Isar integration tests for PayCycleRepository (M5: FR-05, BR-02).
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/notifications/application/pay_cycle_notification_hook.dart';
import 'package:ledgermate/features/pay_cycle/data/pay_cycle_repository.dart';

class FakePayCycleNotificationHook implements PayCycleNotificationHook {
  int onPayCycleExpiredCalls = 0;
  int onPayCycleStartedCalls = 0;
  IncomeFrequency? lastFrequency;
  DateTime? lastNextPayday;
  int? lastIncomeAmount;

  @override
  Future<void> onPayCycleExpired({
    required IncomeFrequency incomeFrequency,
    required DateTime expiredDate,
  }) async {
    onPayCycleExpiredCalls++;
  }

  @override
  Future<void> onPayCycleStarted({
    required IncomeFrequency incomeFrequency,
    DateTime? nextPaydayDate,
    required int incomeAmount,
  }) async {
    onPayCycleStartedCalls++;
    lastFrequency = incomeFrequency;
    lastNextPayday = nextPaydayDate;
    lastIncomeAmount = incomeAmount;
  }
}

void main() {
  late Directory tempDir;
  late Isar isar;
  late PayCycleRepository repository;
  late FakePayCycleNotificationHook notificationHook;
  var instanceCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'ledgermate_pay_cycle_repo_test_',
    );
    instanceCounter++;
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'pay_cycle_repo_test_$instanceCounter',
    );
    notificationHook = FakePayCycleNotificationHook();
    repository = PayCycleRepository(isar, notificationHook);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Mode A transition: creates new PayCycle, updates profile, triggers hook, preserves history', () async {
    // Seed initial profile and initial cycle
    final initialStart = DateTime(2026, 10, 1);
    final initialPayday = DateTime(2026, 10, 25);

    await isar.writeTxn(() async {
      final profile = LocalProfile()
        ..fixedSalary = 5000000
        ..nextPaydayDate = initialPayday
        ..incomeFrequency = IncomeFrequency.periodic
        ..incomeIntervalType = IncomeIntervalType.monthly
        ..onboardingComplete = true;
      await isar.localProfiles.put(profile);

      final cycle1 = PayCycle()
        ..fixedSalary = 5000000
        ..startDate = initialStart
        ..paydayDate = initialPayday;
      await isar.payCycles.put(cycle1);
    });

    expect(await isar.payCycles.count(), 1);

    // Complete Mode A transition for the new cycle
    final newPayday = DateTime(2026, 11, 25);
    final transitionNow = DateTime(2026, 10, 25);
    final newExpenses = [
      MandatoryExpenseItem()
        ..name = 'Sewa Kos'
        ..amount = 1200000,
    ];

    await repository.completeModeATransition(
      fixedSalary: 5500000,
      nextPaydayDate: newPayday,
      incomeIntervalType: IncomeIntervalType.monthly,
      mandatoryExpenses: newExpenses,
      referenceNow: transitionNow,
    );

    // Verify: historical PayCycle rows are preserved (now 2 rows total)
    final cycles = await repository.getAllPayCycles();
    expect(cycles.length, 2);
    expect(cycles.first.paydayDate, newPayday);
    expect(cycles.first.fixedSalary, 5500000);
    expect(cycles.first.mandatoryExpenses.length, 1);
    expect(cycles.first.mandatoryExpenses.first.name, 'Sewa Kos');

    // Verify: LocalProfile is updated
    final updatedProfile = await repository.getProfile();
    expect(updatedProfile, isNotNull);
    expect(updatedProfile!.fixedSalary, 5500000);
    expect(updatedProfile.nextPaydayDate, newPayday);

    // Verify: notification hook fired
    expect(notificationHook.onPayCycleStartedCalls, 1);
    expect(notificationHook.lastFrequency, IncomeFrequency.periodic);
    expect(notificationHook.lastNextPayday, newPayday);
    expect(notificationHook.lastIncomeAmount, 5500000);
  });

  test('Mode B transition: updates carryOver, sets lastRolloverDate, resets mandatory expenses, logs bekel', () async {
    // Seed initial profile and default category
    await isar.writeTxn(() async {
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.daily
        ..carryOverBalance = 100000
        ..mandatoryExpenses = [
          MandatoryExpenseItem()
            ..name = 'Bensin Kemarin'
            ..amount = 20000,
        ]
        ..lastRolloverDate = DateTime(2026, 10, 27)
        ..onboardingComplete = true;
      await isar.localProfiles.put(profile);

      final cat = Category()
        ..name = 'Uang Saku'
        ..isDefault = true;
      await isar.categorys.put(cat);
    });

    final today = DateTime(2026, 10, 28);
    final todayExpenses = [
      MandatoryExpenseItem()
        ..name = 'Parkir Hari Ini'
        ..amount = 10000,
    ];

    await repository.completeModeBTransition(
      carryOverBalance: 140000,
      todayMandatoryExpenses: todayExpenses,
      todayBekelIncome: 50000,
      referenceNow: today,
    );

    // Verify: LocalProfile updated with carry-over and new mandatory expenses per BR-02
    final profile = await repository.getProfile();
    expect(profile, isNotNull);
    expect(profile!.carryOverBalance, 140000);
    expect(profile.lastRolloverDate, today);
    expect(profile.mandatoryExpenses.length, 1);
    expect(profile.mandatoryExpenses.first.name, 'Parkir Hari Ini');

    // Verify: Bekel income transaction created
    final txs = await repository.getTransactions();
    expect(txs.length, 1);
    expect(txs.first.type, db.TransactionType.income);
    expect(txs.first.amount, 50000);
    expect(txs.first.notes, 'Bekel hari ini');

    // Verify: notification hook fired
    expect(notificationHook.onPayCycleStartedCalls, 1);
    expect(notificationHook.lastFrequency, IncomeFrequency.daily);
    expect(notificationHook.lastIncomeAmount, 50000);
  });
}
