// Riverpod providers and domain helpers for M7 Asset/Investment Tracker
// (FR-10, DECISIONS.md D8).
// Completely separate from the Smart Daily Budget Engine (BR-01, BR-02, BR-03).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/asset.dart';
import '../../../core/database/isar_provider.dart';
import '../data/assets_repository.dart';

final assetsRepositoryProvider = Provider<AssetsRepositoryBase>((ref) {
  return AssetsRepository(ref.watch(isarProvider));
});

final assetsStreamProvider = StreamProvider<List<Asset>>((ref) {
  return ref.watch(assetsRepositoryProvider).watchAssets();
});

/// Domain wrapper around an [Asset] entity providing calculated metrics.
///
/// Per PRD FR-10 and §8, `gainLoss` is computed on-the-fly as
/// `currentValue - purchaseValue` and is NEVER stored in the database.
class AssetItem {
  const AssetItem(this.asset);

  final Asset asset;

  int get id => asset.id;
  String get name => asset.assetName;
  String get type => asset.assetType;
  int get purchaseValue => asset.purchaseValue;
  int get currentValue => asset.currentValue;
  DateTime get lastUpdatedAt => asset.lastUpdatedAt;

  /// Gain or loss computed on-the-fly (FR-10).
  int get gainLoss => currentValue - purchaseValue;

  /// Return percentage relative to initial purchase value.
  /// Returns 0.0 if purchase value is 0.
  double get returnPercentage =>
      purchaseValue > 0 ? (gainLoss / purchaseValue) * 100 : 0.0;

  /// Alias for returnPercentage.
  double get gainLossPercentage => returnPercentage;

  /// True if currentValue is equal or greater than purchaseValue.
  bool get isGain => gainLoss >= 0;

  /// True if currentValue is strictly less than purchaseValue.
  bool get isLoss => gainLoss < 0;

  /// True if currentValue equals purchaseValue.
  bool get isBreakEven => gainLoss == 0;
}

/// Aggregate portfolio summary across all assets (FR-10).
class AssetsOverviewSummary {
  const AssetsOverviewSummary({
    required this.totalPurchaseValue,
    required this.totalCurrentValue,
    required this.totalGainLoss,
    required this.totalReturnPercentage,
    required this.items,
  });

  factory AssetsOverviewSummary.fromItems(List<AssetItem> items) {
    var totalPurchase = 0;
    var totalCurrent = 0;
    for (final item in items) {
      totalPurchase += item.purchaseValue;
      totalCurrent += item.currentValue;
    }
    final totalGainLoss = totalCurrent - totalPurchase;
    final totalReturnPercentage = totalPurchase > 0
        ? (totalGainLoss / totalPurchase) * 100
        : 0.0;
    return AssetsOverviewSummary(
      totalPurchaseValue: totalPurchase,
      totalCurrentValue: totalCurrent,
      totalGainLoss: totalGainLoss,
      totalReturnPercentage: totalReturnPercentage,
      items: items,
    );
  }

  final int totalPurchaseValue;
  final int totalCurrentValue;
  final int totalGainLoss;
  final double totalReturnPercentage;
  final List<AssetItem> items;

  int get assetCount => items.length;
  bool get isTotalGain => totalGainLoss >= 0;
}

/// Reactively computes the full portfolio overview summary across all assets.
final assetsOverviewSummaryProvider =
    Provider<AsyncValue<AssetsOverviewSummary>>((ref) {
      final assetsAsync = ref.watch(assetsStreamProvider);
      return assetsAsync.whenData((assets) {
        var totalPurchase = 0;
        var totalCurrent = 0;
        final items = <AssetItem>[];

        for (final asset in assets) {
          totalPurchase += asset.purchaseValue;
          totalCurrent += asset.currentValue;
          items.add(AssetItem(asset));
        }

        final totalGainLoss = totalCurrent - totalPurchase;
        final totalReturnPercentage = totalPurchase > 0
            ? (totalGainLoss / totalPurchase) * 100
            : 0.0;

        return AssetsOverviewSummary(
          totalPurchaseValue: totalPurchase,
          totalCurrentValue: totalCurrent,
          totalGainLoss: totalGainLoss,
          totalReturnPercentage: totalReturnPercentage,
          items: items,
        );
      });
    });
