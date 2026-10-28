import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/asset.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart';
import 'package:ledgermate/features/assets/data/assets_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late AssetsRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: false);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('assets_repo_test_');
    isar = await Isar.open([
      LocalProfileSchema,
      PayCycleSchema,
      TransactionSchema,
      CategorySchema,
      FinancialGoalSchema,
      AssetSchema,
    ], directory: tempDir.path);
    repository = AssetsRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('AssetsRepository CRUD (FR-10, DECISIONS.md D8)', () {
    test('saveAsset creates new asset when id is null', () async {
      final asset = await repository.saveAsset(
        name: 'Emas Antam 10g',
        type: 'Emas',
        purchaseValue: 12000000,
        currentValue: 14500000,
      );

      expect(asset.id, greaterThan(0));
      expect(asset.assetName, 'Emas Antam 10g');
      expect(asset.assetType, 'Emas');
      expect(asset.purchaseValue, 12000000);
      expect(asset.currentValue, 14500000);
      expect(asset.lastUpdatedAt, isNotNull);

      final fetched = await repository.getAssetById(asset.id);
      expect(fetched, isNotNull);
      expect(fetched!.assetName, 'Emas Antam 10g');
      expect(fetched.currentValue, 14500000);
    });

    test('saveAsset updates existing asset when id is provided', () async {
      final initial = await repository.saveAsset(
        name: 'Saham BBCA',
        type: 'Saham',
        purchaseValue: 8000000,
        currentValue: 9000000,
      );

      final updated = await repository.saveAsset(
        id: initial.id,
        name: 'Saham BBCA Lot 10',
        type: 'Saham',
        purchaseValue: 8500000,
        currentValue: 10200000,
      );

      expect(updated.id, initial.id);
      expect(updated.assetName, 'Saham BBCA Lot 10');
      expect(updated.purchaseValue, 8500000);
      expect(updated.currentValue, 10200000);

      final list = await repository.getAssets();
      expect(list.length, 1);
      expect(list.first.assetName, 'Saham BBCA Lot 10');
    });

    test(
      'updateAssetCurrentValue updates only currentValue and lastUpdatedAt',
      () async {
        final initialTime = DateTime(2026, 1, 1);
        final asset = await repository.saveAsset(
          name: 'Reksadana Saham',
          type: 'Reksadana',
          purchaseValue: 5000000,
          currentValue: 5200000,
          lastUpdatedAt: initialTime,
        );

        final newTime = DateTime(2026, 10, 28);
        final updated = await repository.updateAssetCurrentValue(
          id: asset.id,
          currentValue: 5800000,
          updatedAt: newTime,
        );

        expect(updated.id, asset.id);
        expect(updated.assetName, 'Reksadana Saham');
        expect(updated.assetType, 'Reksadana');
        expect(updated.purchaseValue, 5000000); // unchanged
        expect(updated.currentValue, 5800000); // updated
        expect(updated.lastUpdatedAt, newTime); // updated
      },
    );

    test('deleteAsset deletes target asset', () async {
      final a1 = await repository.saveAsset(
        name: 'Aset 1',
        type: 'Emas',
        purchaseValue: 1000000,
        currentValue: 1100000,
      );
      final a2 = await repository.saveAsset(
        name: 'Aset 2',
        type: 'Saham',
        purchaseValue: 2000000,
        currentValue: 2200000,
      );

      final success = await repository.deleteAsset(a1.id);
      expect(success, isTrue);

      final remaining = await repository.getAssets();
      expect(remaining.length, 1);
      expect(remaining.first.id, a2.id);

      final deleted = await repository.getAssetById(a1.id);
      expect(deleted, isNull);
    });

    test('getAssets sorts by lastUpdatedAt descending', () async {
      final older = await repository.saveAsset(
        name: 'Aset Lama',
        type: 'Properti',
        purchaseValue: 100000000,
        currentValue: 120000000,
        lastUpdatedAt: DateTime(2026, 1, 15),
      );
      final newer = await repository.saveAsset(
        name: 'Aset Baru',
        type: 'Emas',
        purchaseValue: 5000000,
        currentValue: 6000000,
        lastUpdatedAt: DateTime(2026, 10, 20),
      );

      final assets = await repository.getAssets();
      expect(assets.first.id, newer.id);
      expect(assets.last.id, older.id);
    });

    test('validations reject invalid values', () async {
      expect(
        () => repository.saveAsset(
          name: '   ',
          type: 'Emas',
          purchaseValue: 1000,
          currentValue: 1000,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repository.saveAsset(
          name: 'Emas',
          type: '   ',
          purchaseValue: 1000,
          currentValue: 1000,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repository.saveAsset(
          name: 'Emas',
          type: 'Emas',
          purchaseValue: 0,
          currentValue: 1000,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repository.saveAsset(
          name: 'Emas',
          type: 'Emas',
          purchaseValue: 1000,
          currentValue: -100,
        ),
        throwsA(isA<ArgumentError>()),
      );

      expect(
        () => repository.updateAssetCurrentValue(id: 999, currentValue: 1000),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
