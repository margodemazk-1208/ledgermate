// Round-trip persistence tests for all 6 PRD §8 Isar collections (M1).
// Verifies every field type survives a put()+get() cycle, especially the
// whole-Rupiah `int` fields that stand in for Isar's missing Decimal type
// (see the decision note in lib/core/database/isar_provider.dart).
//
// Each test opens a uniquely-named Isar instance in a fresh temp directory
// so tests don't interfere with each other; `flutter test` must run with
// `-j 1` per isar_community's own unit-test guidance, since
// Isar.initializeIsarCore(download: true) downloads a shared native binary
// once and concurrent downloads race.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/asset.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;

void main() {
  late Directory tempDir;
  late Isar isar;
  var instanceCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ledgermate_isar_test_');
    instanceCounter++;
    isar = await Isar.open(
      [
        LocalProfileSchema,
        PayCycleSchema,
        db.TransactionSchema,
        CategorySchema,
        FinancialGoalSchema,
        AssetSchema,
      ],
      directory: tempDir.path,
      name: 'test_instance_$instanceCounter',
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('LocalProfile', () {
    test(
      'round-trips every field, incl. whole-Rupiah ints and enums',
      () async {
        final profile = LocalProfile()
          ..fixedSalary = 5000000
          ..incomeFrequency = IncomeFrequency.periodic
          ..nextPaydayDate = DateTime(2026, 11, 25)
          ..carryOverBalance = 12345
          ..language = AppLanguage.id
          ..theme = AppThemeSetting.dark
          ..notifDailyReminderEnabled = false
          ..notifDailyReminderTime = 22 * 60
          ..notifLimitAlertEnabled = false
          ..notifPayCycleEnabled = false
          ..notifGoalMilestoneEnabled = false;

        await isar.writeTxn(() => isar.localProfiles.put(profile));
        final fetched = await isar.localProfiles.get(profile.id);

        expect(fetched, isNotNull);
        expect(fetched!.fixedSalary, 5000000);
        expect(fetched.fixedSalary, isA<int>());
        expect(fetched.incomeFrequency, IncomeFrequency.periodic);
        expect(fetched.nextPaydayDate, DateTime(2026, 11, 25));
        expect(fetched.carryOverBalance, 12345);
        expect(fetched.language, AppLanguage.id);
        expect(fetched.theme, AppThemeSetting.dark);
        expect(fetched.notifDailyReminderEnabled, false);
        expect(fetched.notifDailyReminderTime, 22 * 60);
        expect(fetched.notifLimitAlertEnabled, false);
        expect(fetched.notifPayCycleEnabled, false);
        expect(fetched.notifGoalMilestoneEnabled, false);
      },
    );

    test('default values match PRD §8 (daily-mode fields untouched)', () async {
      final profile = LocalProfile();
      await isar.writeTxn(() => isar.localProfiles.put(profile));
      final fetched = await isar.localProfiles.get(profile.id);

      expect(fetched!.nextPaydayDate, isNull);
      expect(fetched.carryOverBalance, 0);
      expect(fetched.notifDailyReminderTime, 21 * 60);
      expect(fetched.notifDailyReminderEnabled, true);
      expect(fetched.notifLimitAlertEnabled, true);
      expect(fetched.notifPayCycleEnabled, true);
      expect(fetched.notifGoalMilestoneEnabled, true);
    });
  });

  group('PayCycle', () {
    test(
      'round-trips fields incl. embedded MandatoryExpenseItem list',
      () async {
        final cycle = PayCycle()
          ..startDate = DateTime(2026, 10, 25)
          ..paydayDate = DateTime(2026, 11, 25)
          ..fixedSalary = 5000000
          ..variableIncomeTotal = 250000
          ..mandatoryExpenses = [
            MandatoryExpenseItem()
              ..name = 'Kos'
              ..amount = 800000,
            MandatoryExpenseItem()
              ..name = 'Cicilan'
              ..amount = 500000,
          ];

        await isar.writeTxn(() => isar.payCycles.put(cycle));
        final fetched = await isar.payCycles.get(cycle.id);

        expect(fetched, isNotNull);
        expect(fetched!.startDate, DateTime(2026, 10, 25));
        expect(fetched.paydayDate, DateTime(2026, 11, 25));
        expect(fetched.fixedSalary, 5000000);
        expect(fetched.variableIncomeTotal, 250000);
        expect(fetched.mandatoryExpenses.length, 2);
        expect(fetched.mandatoryExpenses[0].name, 'Kos');
        expect(fetched.mandatoryExpenses[0].amount, 800000);
        expect(fetched.mandatoryExpenses[1].name, 'Cicilan');
        expect(fetched.mandatoryExpenses[1].amount, 500000);
      },
    );
  });

  group('Transaction', () {
    test('round-trips fields incl. FK ints and enum type', () async {
      final category = Category()
        ..name = 'Makan'
        ..isDefault = true;
      await isar.writeTxn(() => isar.categorys.put(category));

      final cycle = PayCycle()
        ..startDate = DateTime.now()
        ..paydayDate = DateTime.now();
      await isar.writeTxn(() => isar.payCycles.put(cycle));

      final txn = db.Transaction()
        ..type = db.TransactionType.expense
        ..amount = 15000
        ..categoryId = category.id
        ..date = DateTime(2026, 10, 28)
        ..notes = 'Nasi goreng'
        ..payCycleId = cycle.id;

      await isar.writeTxn(() => isar.transactions.put(txn));
      final fetched = await isar.transactions.get(txn.id);

      expect(fetched, isNotNull);
      expect(fetched!.type, db.TransactionType.expense);
      expect(fetched.amount, 15000);
      expect(fetched.categoryId, category.id);
      expect(fetched.date, DateTime(2026, 10, 28));
      expect(fetched.notes, 'Nasi goreng');
      expect(fetched.payCycleId, cycle.id);
    });

    test(
      'payCycleId is nullable (Mode B daily income has no pay cycle)',
      () async {
        final category = Category()
          ..name = 'Transport'
          ..isDefault = false;
        await isar.writeTxn(() => isar.categorys.put(category));

        final txn = db.Transaction()
          ..type = db.TransactionType.income
          ..amount = 50000
          ..categoryId = category.id
          ..date = DateTime(2026, 10, 28);

        await isar.writeTxn(() => isar.transactions.put(txn));
        final fetched = await isar.transactions.get(txn.id);

        expect(fetched!.payCycleId, isNull);
        expect(fetched.notes, isNull);
      },
    );
  });

  group('Category', () {
    test('round-trips name + isDefault', () async {
      final category = Category()
        ..name = 'Hiburan'
        ..isDefault = false;
      await isar.writeTxn(() => isar.categorys.put(category));
      final fetched = await isar.categorys.get(category.id);

      expect(fetched, isNotNull);
      expect(fetched!.name, 'Hiburan');
      expect(fetched.isDefault, false);
    });
  });

  group('FinancialGoal', () {
    test('round-trips fields incl. manual allocation override', () async {
      final goal = FinancialGoal()
        ..goalName = 'Laptop baru'
        ..targetAmount = 15000000
        ..currentAmount = 2500000
        ..targetDate = DateTime(2027, 3, 1)
        ..manualDailyAllocation = 20000;

      await isar.writeTxn(() => isar.financialGoals.put(goal));
      final fetched = await isar.financialGoals.get(goal.id);

      expect(fetched, isNotNull);
      expect(fetched!.goalName, 'Laptop baru');
      expect(fetched.targetAmount, 15000000);
      expect(fetched.currentAmount, 2500000);
      expect(fetched.targetDate, DateTime(2027, 3, 1));
      expect(fetched.manualDailyAllocation, 20000);
    });

    test('manualDailyAllocation defaults to null (auto-calculated)', () async {
      final goal = FinancialGoal()
        ..goalName = 'Dana darurat'
        ..targetAmount = 5000000
        ..currentAmount = 0
        ..targetDate = DateTime(2027, 1, 1);

      await isar.writeTxn(() => isar.financialGoals.put(goal));
      final fetched = await isar.financialGoals.get(goal.id);

      expect(fetched!.manualDailyAllocation, isNull);
    });
  });

  group('Asset', () {
    test('round-trips fields; gain/loss stays unstored/derivable', () async {
      final asset = Asset()
        ..assetName = 'Emas Antam 10gr'
        ..assetType = 'emas'
        ..purchaseValue = 9500000
        ..currentValue = 10200000
        ..lastUpdatedAt = DateTime(2026, 10, 28, 9, 30);

      await isar.writeTxn(() => isar.assets.put(asset));
      final fetched = await isar.assets.get(asset.id);

      expect(fetched, isNotNull);
      expect(fetched!.assetName, 'Emas Antam 10gr');
      expect(fetched.assetType, 'emas');
      expect(fetched.purchaseValue, 9500000);
      expect(fetched.currentValue, 10200000);
      expect(fetched.lastUpdatedAt, DateTime(2026, 10, 28, 9, 30));
      // gainLoss is computed on the fly per PRD §8, never persisted.
      expect(fetched.currentValue - fetched.purchaseValue, 700000);
    });
  });
}
