import 'dart:async';

import 'package:ledgermate/core/database/asset.dart';
import 'package:ledgermate/features/assets/data/assets_repository.dart';

/// In-memory test double for [AssetsRepositoryBase] to avoid Isar async
/// hangs under `testWidgets()`.
class FakeAssetsRepository implements AssetsRepositoryBase {
  FakeAssetsRepository({List<Asset>? initialAssets}) {
    if (initialAssets != null) {
      _assets.addAll(initialAssets);
    }
  }

  final List<Asset> _assets = [];
  final _assetsController = StreamController<List<Asset>>.broadcast();
  int _nextId = 1;

  void dispose() {
    _assetsController.close();
  }

  void _notify() {
    final sorted = [..._assets]
      ..sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    _assetsController.add(sorted);
  }

  @override
  Stream<List<Asset>> watchAssets() {
    final current = [..._assets]
      ..sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
    return Stream<List<Asset>>.value(current)
        .concatWith(_assetsController.stream);
  }

  @override
  Future<List<Asset>> getAssets() async {
    return [..._assets]
      ..sort((a, b) => b.lastUpdatedAt.compareTo(a.lastUpdatedAt));
  }

  @override
  Future<Asset?> getAssetById(int id) async {
    try {
      return _assets.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
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
        'Modal awal (purchaseValue) harus lebih besar dari 0.',
      );
    }
    if (currentValue < 0) {
      throw ArgumentError.value(
        currentValue,
        'currentValue',
        'Nilai sekarang (currentValue) tidak boleh negatif.',
      );
    }

    Asset asset;
    if (id != null && id > 0) {
      final index = _assets.indexWhere((a) => a.id == id);
      if (index >= 0) {
        asset = _assets[index];
      } else {
        asset = Asset()..id = id;
        _assets.add(asset);
      }
    } else {
      asset = Asset()..id = _nextId++;
      _assets.add(asset);
    }

    asset.assetName = trimmedName;
    asset.assetType = trimmedType;
    asset.purchaseValue = purchaseValue;
    asset.currentValue = currentValue;
    asset.lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

    _notify();
    return asset;
  }

  @override
  Future<Asset> updateAssetCurrentValue({
    required int id,
    required int currentValue,
    DateTime? updatedAt,
  }) async {
    if (currentValue < 0) {
      throw ArgumentError.value(
        currentValue,
        'currentValue',
        'Nilai sekarang (currentValue) tidak boleh negatif.',
      );
    }

    final asset = await getAssetById(id);
    if (asset == null) {
      throw ArgumentError('Aset dengan ID $id tidak ditemukan.');
    }

    asset.currentValue = currentValue;
    asset.lastUpdatedAt = updatedAt ?? DateTime.now();

    _notify();
    return asset;
  }

  @override
  Future<bool> deleteAsset(int id) async {
    _assets.removeWhere((a) => a.id == id);
    _notify();
    return true;
  }
}

extension<T> on Stream<T> {
  Stream<T> concatWith(Stream<T> other) async* {
    yield* this;
    yield* other;
  }
}
