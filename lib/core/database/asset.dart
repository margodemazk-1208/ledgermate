import 'package:isar_community/isar.dart';

part 'asset.g.dart';

/// A manually-valued net-worth asset (FR-10) — emas/saham/reksadana/tanah/
/// etc. Entirely separate from the budget engine: per PRD §8 and D8,
/// nothing here ever feeds `UangJajanAmanHariIni`/`DailySavingsReserve`.
@collection
class Asset {
  Id id = Isar.autoIncrement;

  String assetName = '';

  /// Free-form type string (emas/saham/reksadana/tanah/dll per PRD §8) —
  /// not an enum, since the PRD explicitly leaves this open-ended.
  String assetType = '';

  /// Modal awal/harga beli. Whole-Rupiah int. See decimal-representation
  /// note in `lib/core/database/isar_provider.dart`.
  int purchaseValue = 0;

  /// Updated manually by the user at any time (FR-10 — never fetched from
  /// an API, see D8).
  int currentValue = 0;

  DateTime lastUpdatedAt = DateTime.now();

  // gainLoss (currentValue - purchaseValue) is deliberately NOT a stored
  // field — PRD §8 computes it on the fly.
}
