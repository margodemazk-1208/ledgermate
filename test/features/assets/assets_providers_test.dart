import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/asset.dart';
import 'package:ledgermate/features/assets/application/assets_providers.dart';

void main() {
  group('AssetItem (FR-10, DECISIONS.md D8 dynamic gain/loss computation)', () {
    test('computes positive gain and return percentage correctly', () {
      final asset = Asset()
        ..id = 1
        ..assetName = 'Emas Antam 10g'
        ..assetType = 'Emas'
        ..purchaseValue = 10000000
        ..currentValue = 12500000
        ..lastUpdatedAt = DateTime(2026, 10, 28);

      final item = AssetItem(asset);

      expect(item.name, 'Emas Antam 10g');
      expect(item.type, 'Emas');
      expect(item.purchaseValue, 10000000);
      expect(item.currentValue, 12500000);
      expect(item.gainLoss, 2500000); // 12.5M - 10M
      expect(item.gainLossPercentage, 25.0); // +25.0%
      expect(item.isGain, isTrue);
      expect(item.isLoss, isFalse);
      expect(item.isBreakEven, isFalse);
    });

    test('computes negative loss and negative return percentage correctly', () {
      final asset = Asset()
        ..id = 2
        ..assetName = 'Kripto Token X'
        ..assetType = 'Kripto'
        ..purchaseValue = 5000000
        ..currentValue = 4000000
        ..lastUpdatedAt = DateTime(2026, 10, 28);

      final item = AssetItem(asset);

      expect(item.gainLoss, -1000000); // 4M - 5M
      expect(item.gainLossPercentage, -20.0); // -20.0%
      expect(item.isGain, isFalse);
      expect(item.isLoss, isTrue);
      expect(item.isBreakEven, isFalse);
    });

    test('handles break even condition (current == purchase)', () {
      final asset = Asset()
        ..id = 3
        ..assetName = 'Deposito 1 Bulan'
        ..assetType = 'Deposito'
        ..purchaseValue = 10000000
        ..currentValue = 10000000
        ..lastUpdatedAt = DateTime(2026, 10, 28);

      final item = AssetItem(asset);

      expect(item.gainLoss, 0);
      expect(item.gainLossPercentage, 0.0);
      expect(item.isGain, isTrue); // gainLoss >= 0
      expect(item.isLoss, isFalse);
      expect(item.isBreakEven, isTrue);
    });

    test('guards against division by zero if purchaseValue is 0', () {
      final asset = Asset()
        ..id = 4
        ..assetName = 'Aset Hibah'
        ..assetType = 'Lainnya'
        ..purchaseValue = 0
        ..currentValue = 500000
        ..lastUpdatedAt = DateTime(2026, 10, 28);

      final item = AssetItem(asset);

      expect(item.gainLoss, 500000);
      expect(item.gainLossPercentage, 0.0); // no NaN or Infinity
    });
  });

  group('AssetsOverviewSummary aggregation', () {
    test('aggregates empty asset list', () {
      final summary = AssetsOverviewSummary.fromItems([]);

      expect(summary.assetCount, 0);
      expect(summary.totalPurchaseValue, 0);
      expect(summary.totalCurrentValue, 0);
      expect(summary.totalGainLoss, 0);
      expect(summary.totalReturnPercentage, 0.0);
      expect(summary.isTotalGain, isTrue);
    });

    test('aggregates multiple assets portfolio correctly', () {
      final a1 = Asset()
        ..id = 1
        ..assetName = 'BBCA'
        ..assetType = 'Saham'
        ..purchaseValue = 10000000
        ..currentValue = 12000000
        ..lastUpdatedAt = DateTime(2026, 10, 1);

      final a2 = Asset()
        ..id = 2
        ..assetName = 'Emas'
        ..assetType = 'Emas'
        ..purchaseValue = 5000000
        ..currentValue = 4500000
        ..lastUpdatedAt = DateTime(2026, 10, 2);

      final summary = AssetsOverviewSummary.fromItems([
        AssetItem(a1),
        AssetItem(a2),
      ]);

      expect(summary.assetCount, 2);
      expect(summary.totalPurchaseValue, 15000000);
      expect(summary.totalCurrentValue, 16500000);
      expect(summary.totalGainLoss, 1500000); // 16.5M - 15M = +1.5M
      expect(summary.totalReturnPercentage, 10.0); // 1.5M / 15M = 10%
      expect(summary.isTotalGain, isTrue);
    });

    test('aggregates portfolio with overall loss', () {
      final a1 = Asset()
        ..id = 1
        ..assetName = 'Kripto A'
        ..assetType = 'Kripto'
        ..purchaseValue = 10000000
        ..currentValue = 5000000
        ..lastUpdatedAt = DateTime(2026, 10, 1);

      final summary = AssetsOverviewSummary.fromItems([AssetItem(a1)]);

      expect(summary.totalGainLoss, -5000000);
      expect(summary.totalReturnPercentage, -50.0);
      expect(summary.isTotalGain, isFalse);
    });
  });
}
