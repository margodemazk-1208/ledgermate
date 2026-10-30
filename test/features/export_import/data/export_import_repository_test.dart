import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/asset.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/export_import/data/export_import_repository.dart';
import 'package:ledgermate/features/export_import/domain/backup_data.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late IsarExportImportRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: false);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('export_import_repo_test_');
    isar = await Isar.open([
      LocalProfileSchema,
      PayCycleSchema,
      db.TransactionSchema,
      CategorySchema,
      FinancialGoalSchema,
      AssetSchema,
      WalletSchema,
    ], directory: tempDir.path);
    repository = IsarExportImportRepository(
      isar: isar,
      directoryProvider: () async => tempDir,
    );
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('IsarExportImportRepository (FR-08)', () {
    test('createBackupData snapshots all 6 collections correctly', () async {
      final now = DateTime(2026, 10, 29, 10, 0, 0);

      await isar.writeTxn(() async {
        final p = LocalProfile()
          ..id = 1
          ..fixedSalary = 10000000
          ..incomeFrequency = IncomeFrequency.periodic
          ..onboardingComplete = true;
        await isar.localProfiles.put(p);

        final c = Category()
          ..id = 1
          ..name = 'Makan'
          ..isDefault = true;
        await isar.categorys.put(c);

        final cyc = PayCycle()
          ..id = 1
          ..startDate = now
          ..paydayDate = now.add(const Duration(days: 30))
          ..fixedSalary = 10000000;
        await isar.payCycles.put(cyc);

        final tx = db.Transaction()
          ..id = 1
          ..amount = 25000
          ..type = db.TransactionType.expense
          ..categoryId = 1
          ..date = now;
        await isar.transactions.put(tx);

        final g = FinancialGoal()
          ..id = 1
          ..goalName = 'Liburan'
          ..targetAmount = 5000000
          ..currentAmount = 1000000
          ..targetDate = now.add(const Duration(days: 90));
        await isar.financialGoals.put(g);

        final a = Asset()
          ..id = 1
          ..assetName = 'Rekening Jenius'
          ..assetType = 'Bank'
          ..purchaseValue = 5000000
          ..currentValue = 5200000
          ..lastUpdatedAt = now;
        await isar.assets.put(a);
      });

      final backup = await repository.createBackupData();
      expect(backup.profiles.length, 1);
      expect(backup.profiles.first.fixedSalary, 10000000);
      expect(backup.categories.length, 1);
      expect(backup.payCycles.length, 1);
      expect(backup.transactions.length, 1);
      expect(backup.financialGoals.length, 1);
      expect(backup.assets.length, 1);
    });

    test(
      'exportBackupToJson writes valid, readable JSON file to disk',
      () async {
        await isar.writeTxn(() async {
          final cat = Category()
            ..id = 1
            ..name = 'Transport'
            ..isDefault = true;
          await isar.categorys.put(cat);
        });

        final filePath = await repository.exportBackupToJson(
          targetDirectoryPath: tempDir.path,
          customFileName: 'test_backup.json',
        );

        final file = File(filePath);
        expect(await file.exists(), isTrue);

        final content = await file.readAsString();
        expect(content, contains('"app": "LedgerMate"'));
        expect(content, contains('"Transport"'));

        final parsed = await repository.validateBackupString(content);
        expect(parsed.categories.first.name, 'Transport');
      },
    );

    test('exportTransactionsToCsv writes RFC 4180 CSV table to disk', () async {
      await isar.writeTxn(() async {
        final cat = Category()
          ..id = 10
          ..name = 'Belanja'
          ..isDefault = true;
        await isar.categorys.put(cat);

        final tx = db.Transaction()
          ..id = 1
          ..amount = 50000
          ..type = db.TransactionType.expense
          ..categoryId = 10
          ..date = DateTime(2026, 10, 20)
          ..notes = 'Beli beras';
        await isar.transactions.put(tx);
      });

      final filePath = await repository.exportTransactionsToCsv(
        targetDirectoryPath: tempDir.path,
        customFileName: 'test_transaksi.csv',
      );

      final file = File(filePath);
      expect(await file.exists(), isTrue);

      final content = await file.readAsString();
      expect(
        content,
        contains('ID,Tanggal,Tipe,Kategori,Nominal,Catatan,ID_Siklus_Gaji'),
      );
      expect(content, contains('50000,Beli beras'));
    });

    test('validateBackupString rejects corrupt or non-JSON input', () async {
      await expectLater(
        repository.validateBackupString('NOT A JSON STRING'),
        throwsA(
          isA<BackupValidationException>().having(
            (e) => e.message,
            'message',
            contains('File bukan format JSON yang valid'),
          ),
        ),
      );

      await expectLater(
        repository.validateBackupString('[1, 2, 3]'),
        throwsA(
          isA<BackupValidationException>().having(
            (e) => e.message,
            'message',
            contains('objek utama harus berupa JSON Object'),
          ),
        ),
      );
    });

    test('restoreDatabase completely replaces existing local collections (REPLACE semantics)', () async {
      // Seed dataset A
      await isar.writeTxn(() async {
        final oldCat = Category()
          ..id = 1
          ..name = 'Kategori Lama'
          ..isDefault = true;
        await isar.categorys.put(oldCat);

        final oldTx = db.Transaction()
          ..id = 1
          ..amount = 10000
          ..type = db.TransactionType.expense
          ..categoryId = 1
          ..date = DateTime(2026, 1, 1);
        await isar.transactions.put(oldTx);
      });

      expect(await isar.categorys.count(), 1);
      expect(await isar.transactions.count(), 1);

      // Prepare backupData (Dataset B)
      final newNow = DateTime(2026, 10, 29);
      final newCat = Category()
        ..id = 99
        ..name = 'Kategori Baru Cadangan'
        ..isDefault = false;
      final newGoal = FinancialGoal()
        ..id = 77
        ..goalName = 'Target Baru'
        ..targetAmount = 20000000
        ..currentAmount = 5000000
        ..targetDate = newNow;

      final backupData = BackupData(
        exportedAt: newNow,
        profiles: [],
        payCycles: [],
        categories: [newCat],
        transactions: [],
        financialGoals: [newGoal],
        assets: [],
      );

      // Restore dataset B
      await repository.restoreDatabase(backupData);

      // Assert dataset A is replaced, not merged
      final categories = await isar.categorys.where().findAll();
      expect(categories.length, 1);
      expect(categories.first.id, 99);
      expect(categories.first.name, 'Kategori Baru Cadangan');

      final transactions = await isar.transactions.where().findAll();
      expect(transactions, isEmpty);

      final goals = await isar.financialGoals.where().findAll();
      expect(goals.length, 1);
      expect(goals.first.id, 77);
      expect(goals.first.goalName, 'Target Baru');
    });

    test(
      'round-trip export and restore produces exact matching data',
      () async {
        final now = DateTime(2026, 10, 29, 8, 30);

        await isar.writeTxn(() async {
          final profile = LocalProfile()
            ..id = 1
            ..fixedSalary = 12000000
            ..incomeFrequency = IncomeFrequency.periodic
            ..onboardingComplete = true;
          await isar.localProfiles.put(profile);

          final cat = Category()
            ..id = 15
            ..name = 'Investasi Rutin'
            ..isDefault = true;
          await isar.categorys.put(cat);

          final tx = db.Transaction()
            ..id = 100
            ..amount = 2000000
            ..type = db.TransactionType.expense
            ..categoryId = 15
            ..date = now
            ..notes = 'Beli reksadana';
          await isar.transactions.put(tx);
        });

        // Export to JSON
        final filePath = await repository.exportBackupToJson(
          targetDirectoryPath: tempDir.path,
        );
        final rawJson = await File(filePath).readAsString();
        final validated = await repository.validateBackupString(rawJson);

        // Clear DB manually to simulate fresh install
        await isar.writeTxn(() async {
          await isar.localProfiles.clear();
          await isar.categorys.clear();
          await isar.transactions.clear();
        });
        expect(await isar.transactions.count(), 0);

        // Restore
        await repository.restoreDatabase(validated);

        // Verify exact restore
        final restoredTx = await isar.transactions.get(100);
        expect(restoredTx, isNotNull);
        expect(restoredTx!.amount, 2000000);
        expect(restoredTx.notes, 'Beli reksadana');

        final restoredCat = await isar.categorys.get(15);
        expect(restoredCat, isNotNull);
        expect(restoredCat!.name, 'Investasi Rutin');

        final restoredProfile = await isar.localProfiles.get(1);
        expect(restoredProfile, isNotNull);
        expect(restoredProfile!.fixedSalary, 12000000);
      },
    );
  });
}
