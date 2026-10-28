// Assets data layer (M7): handles CRUD and reactive queries for
// manually-valued net-worth assets (FR-10, DECISIONS.md D8).
// Entirely separate from the Smart Daily Budget Engine.
import 'package:isar_community/isar.dart';

import '../../../core/database/asset.dart';

abstract class AssetsRepositoryBase {
  Stream<List<Asset>> watchAssets();

  Future<List<Asset>> getAssets();

  Future<Asset?> getAssetById(int id);

  Future<Asset> saveAsset({
    int? id,
    required String name,
    required String type,
    required int purchaseValue,
    required int currentValue,
    DateTime? lastUpdatedAt,
  });

  Future<Asset> updateAssetCurrentValue({
    required int id,
    required int currentValue,
    DateTime? updatedAt,
  });

  Future<bool> deleteAsset(int id);
}

class AssetsRepository implements AssetsRepositoryBase {
  AssetsRepository(this._isar);

  final Isar _isar;

  @override
  Stream<List<Asset>> watchAssets() {
    return _isar.assets.where().sortByLastUpdatedAtDesc().watch(
      fireImmediately: true,
    );
  }

  @override
  Future<List<Asset>> getAssets() {
    return _isar.assets.where().sortByLastUpdatedAtDesc().findAll();
  }

  @override
  Future<Asset?> getAssetById(int id) {
    return _isar.assets.get(id);
  }

  @override
  Future<Asset> saveAsset({
    int? id,
    required String name,
    required String type,
    required int purchaseValue,
    required int currentValue,
    DateTime? lastUpdatedAt,
  }) async {
    final trimmedName = name.trim();
    final trimmedType = type.trim();

    if (trimmedName.isEmpty) {
      throw ArgumentError.value(name, 'name', 'Nama aset tidak boleh kosong.');
    }
    if (trimmedType.isEmpty) {
      throw ArgumentError.value(type, 'type', 'Tipe aset tidak boleh kosong.');
    }
    if (purchaseValue <= 0) {
      throw ArgumentError.value(
        purchaseValue,
        'purchaseValue',
        'Nilai beli/modal awal harus lebih besar dari 0.',
      );
    }
    if (currentValue < 0) {
      throw ArgumentError.value(
        currentValue,
        'currentValue',
        'Nilai sekarang tidak boleh negatif.',
      );
    }

    final now = lastUpdatedAt ?? DateTime.now();

    return _isar.writeTxn(() async {
      final asset = (id != null && id > 0)
          ? (await _isar.assets.get(id) ?? Asset())
          : Asset();

      if (id != null && id > 0) {
        asset.id = id;
      }
      asset.assetName = trimmedName;
      asset.assetType = trimmedType;
      asset.purchaseValue = purchaseValue;
      asset.currentValue = currentValue;
      asset.lastUpdatedAt = now;

      final savedId = await _isar.assets.put(asset);
      asset.id = savedId;
      return asset;
    });
  }

  @override
  Future<Asset> updateAssetCurrentValue({
    required int id,
    required int currentValue,
    DateTime? updatedAt,
  }) async {
    if (id <= 0) {
      throw ArgumentError.value(id, 'id', 'ID aset tidak valid.');
    }
    if (currentValue < 0) {
      throw ArgumentError.value(
        currentValue,
        'currentValue',
        'Nilai sekarang tidak boleh negatif.',
      );
    }

    final now = updatedAt ?? DateTime.now();

    return _isar.writeTxn(() async {
      final asset = await _isar.assets.get(id);
      if (asset == null) {
        throw ArgumentError('Aset dengan ID $id tidak ditemukan.');
      }

      asset.currentValue = currentValue;
      asset.lastUpdatedAt = now;

      await _isar.assets.put(asset);
      return asset;
    });
  }

  @override
  Future<bool> deleteAsset(int id) async {
    return _isar.writeTxn(() async {
      return _isar.assets.delete(id);
    });
  }
}
