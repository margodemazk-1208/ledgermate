import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/asset.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/export_import/domain/backup_data.dart';

void main() {
  group('BackupData & BackupSummary Domain (FR-08)', () {
    test(
      'serializes and deserializes a full dataset across all 6 collections',
      () {
        final now = DateTime(2026, 10, 29, 12, 0, 0);

        final profile = LocalProfile()
          ..id = 1
          ..fixedSalary = 15000000
          ..incomeFrequency = IncomeFrequency.periodic
          ..nextPaydayDate = now.add(const Duration(days: 15))
          ..incomeIntervalType = IncomeIntervalType.monthly
          ..carryOverBalance = 500000
          ..language = AppLanguage.id
          ..theme = AppThemeSetting.dark
          ..onboardingComplete = true;

        final payCycle = PayCycle()
          ..id = 10
          ..startDate = now.subtract(const Duration(days: 15))
          ..paydayDate = now.add(const Duration(days: 15))
          ..fixedSalary = 15000000
          ..variableIncomeTotal = 0;

        final category = Category()
          ..id = 20
          ..name = 'Makanan & Minuman'
          ..isDefault = true;

        final tx = db.Transaction()
          ..id = 30
          ..amount = 50000
          ..type = db.TransactionType.expense
          ..categoryId = 20
          ..date = now
          ..notes = 'Makan siang enak'
          ..payCycleId = 10;

        final goal = FinancialGoal()
          ..id = 40
          ..goalName = 'Dana Darurat'
          ..targetAmount = 50000000
          ..currentAmount = 10000000
          ..targetDate = DateTime(2027, 1, 1);

        final asset = Asset()
          ..id = 50
          ..assetName = 'Rekening Tabungan BCA'
          ..assetType = 'Tabungan'
          ..purchaseValue = 10000000
          ..currentValue = 12500000
          ..lastUpdatedAt = now;

        final backup = BackupData(
          exportedAt: now,
          profiles: [profile],
          payCycles: [payCycle],
          categories: [category],
          transactions: [tx],
          financialGoals: [goal],
          assets: [asset],
        );

        final summary = backup.summary;
        expect(summary.hasProfile, isTrue);
        expect(summary.payCycleCount, 1);
        expect(summary.categoryCount, 1);
        expect(summary.transactionCount, 1);
        expect(summary.goalCount, 1);
        expect(summary.assetCount, 1);
        expect(summary.totalRecords, 6);

        final json = backup.toJson();
        expect(json['version'], 1);
        expect(json['app'], 'LedgerMate');
        expect(json['exportedAt'], now.toIso8601String());
        expect(json['data'], isA<Map<String, dynamic>>());

        final roundTrip = BackupData.fromJson(json);
        expect(roundTrip.version, 1);
        expect(roundTrip.profiles.length, 1);
        expect(roundTrip.profiles.first.fixedSalary, 15000000);
        expect(
          roundTrip.profiles.first.incomeFrequency,
          IncomeFrequency.periodic,
        );

        expect(roundTrip.payCycles.length, 1);
        expect(roundTrip.payCycles.first.fixedSalary, 15000000);

        expect(roundTrip.categories.length, 1);
        expect(roundTrip.categories.first.name, 'Makanan & Minuman');

        expect(roundTrip.transactions.length, 1);
        expect(roundTrip.transactions.first.amount, 50000);
        expect(roundTrip.transactions.first.type, db.TransactionType.expense);
        expect(roundTrip.transactions.first.notes, 'Makan siang enak');

        expect(roundTrip.financialGoals.length, 1);
        expect(roundTrip.financialGoals.first.goalName, 'Dana Darurat');
        expect(roundTrip.financialGoals.first.targetAmount, 50000000);

        expect(roundTrip.assets.length, 1);
        expect(roundTrip.assets.first.assetName, 'Rekening Tabungan BCA');
        expect(roundTrip.assets.first.currentValue, 12500000);
      },
    );

    test('rejects foreign app backup files', () {
      final wrongAppJson = {
        'app': 'ForeignApp',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {},
      };

      expect(
        () => BackupData.fromJson(wrongAppJson),
        throwsA(
          isA<BackupValidationException>().having(
            (e) => e.message,
            'message',
            contains('bukan file backup dari aplikasi LedgerMate'),
          ),
        ),
      );
    });

    test('rejects incompatible schema versions', () {
      final badVersionJson = {
        'app': 'LedgerMate',
        'version': 99,
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {},
      };

      expect(
        () => BackupData.fromJson(badVersionJson),
        throwsA(
          isA<BackupValidationException>().having(
            (e) => e.message,
            'message',
            contains('tidak didukung oleh versi aplikasi ini'),
          ),
        ),
      );
    });

    test('rejects missing data block', () {
      final missingDataJson = {
        'app': 'LedgerMate',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
      };

      expect(
        () => BackupData.fromJson(missingDataJson),
        throwsA(
          isA<BackupValidationException>().having(
            (e) => e.message,
            'message',
            contains('blok data tidak ditemukan'),
          ),
        ),
      );
    });

    test('rejects malformed transaction entry with invalid enum', () {
      final badTxJson = {
        'app': 'LedgerMate',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {
          'profiles': [],
          'payCycles': [],
          'categories': [],
          'transactions': [
            {
              'id': 1,
              'amount': 25000,
              'type': 'unsupported_type',
              'categoryId': 10,
              'date': DateTime.now().toIso8601String(),
            },
          ],
          'financialGoals': [],
          'assets': [],
        },
      };

      expect(
        () => BackupData.fromJson(badTxJson),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('rejects malformed entity without required id or name', () {
      final badCategoryJson = {
        'app': 'LedgerMate',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {
          'profiles': [],
          'payCycles': [],
          'categories': [
            {'id': 1},
          ],
          'transactions': [],
          'financialGoals': [],
          'assets': [],
        },
      };

      expect(
        () => BackupData.fromJson(badCategoryJson),
        throwsA(isA<BackupValidationException>()),
      );
    });

    test('D18/M16 bug #9 regression: a backup with a NEGATIVE carryOverBalance '
        'imports successfully instead of being wrongly rejected', () {
      // A Mode B user who overspent has a legitimately negative
      // carryOverBalance — `calculateNextDayCarryOver` explicitly "absorbs
      // deficits if overspent" (see core/formulas/daily_budget_formulas.dart).
      // The OLD `min: 0` validation rejected this outright, breaking
      // restore-to-a-new-phone for exactly the users who most needed it.
      final negativeCarryOverJson = {
        'app': 'LedgerMate',
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'data': {
          'profiles': [
            {
              'id': 1,
              'fixedSalary': 0,
              'incomeFrequency': 'daily',
              'carryOverBalance': -75000,
              'language': 'id',
              'theme': 'dark',
              'notifDailyReminderEnabled': true,
              'notifDailyReminderTime': 1260,
              'notifLimitAlertEnabled': true,
              'notifPayCycleEnabled': true,
              'notifGoalMilestoneEnabled': true,
              'onboardingComplete': true,
            },
          ],
          'payCycles': [],
          'categories': [],
          'transactions': [],
          'financialGoals': [],
          'assets': [],
        },
      };

      final restored = BackupData.fromJson(negativeCarryOverJson);
      expect(restored.profiles, hasLength(1));
      expect(restored.profiles.first.carryOverBalance, -75000);
    });
  });
}
