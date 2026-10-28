import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'asset.dart';
import 'category.dart';
import 'financial_goal.dart';
import 'local_profile.dart';
import 'pay_cycle.dart';
import 'transaction.dart';

// ============================================================================
// Decimal representation decision (M1) — flagged for M4 (Smart Daily Budget
// Engine), which owns the actual division/precision work:
//
// Isar has no native Decimal/BigDecimal type. Every monetary field across
// all 6 collections (LocalProfile.fixedSalary/carryOverBalance,
// PayCycle.fixedSalary/variableIncomeTotal, MandatoryExpenseItem.amount,
// Transaction.amount, FinancialGoal.targetAmount/currentAmount/
// manualDailyAllocation, Asset.purchaseValue/currentValue) is stored as a
// plain Dart `int` representing a **whole Indonesian Rupiah amount** — not
// `double`, and not "integer cents" scaled by 100, because IDR has no
// sub-unit in everyday use (the smallest circulating denomination already
// is Rp 1). This is the same pattern as "integer cents" with a scale factor
// of 1 instead of 100.
//
// Why not double: binary floating point cannot represent every Rupiah
// amount exactly, and repeated add/subtract across many transactions over a
// pay cycle would drift. Storing as int makes every *persisted* amount
// exact — verified by the round-trip tests in
// test/core/database/isar_collections_test.dart.
//
// Impact flagged for M4: BR-01 divides money by days
// (`RemainingBalance / RemainingDays`) and goal allocation divides by
// `SisaHariKeTargetDate` (BR-03) — these divisions will not always land on
// a whole Rupiah. The formula engine must pick and document its own
// rounding/truncation strategy for the *displayed*
// `UangJajanAmanHariIni`/`DailySavingsReserve` figures; this milestone only
// guarantees the *stored* amounts round-trip exactly. Whichever rounding M4
// picks, it should be applied consistently (e.g. always floor, never up) so
// the self-balancing property in BR-01/D6 can't let a user overspend money
// that was actually reserved.
// ============================================================================

/// Opens the single Isar instance that stores all 6 PRD §8 collections.
/// Idempotent for the default instance name — returns the already-open
/// instance instead of throwing, so it's safe to call defensively without
/// hand-rolled guards.
///
/// [directory] must be supplied by the caller: the real app passes a path
/// from `path_provider`'s `getApplicationDocumentsDirectory()` (wiring that
/// into `main.dart`'s boot sequence is left to whichever milestone first
/// needs the DB live in the UI — this task is schemas + persistence only,
/// no boot-sequence/UI work per its scope). Tests pass a temp directory,
/// e.g. `Directory.systemTemp.createTempSync()`.
Future<Isar> openLedgerMateIsar({
  required String directory,
  String name = Isar.defaultName,
}) async {
  final existing = Isar.getInstance(name);
  if (existing != null) {
    return existing;
  }
  return Isar.open(
    [
      LocalProfileSchema,
      PayCycleSchema,
      TransactionSchema,
      CategorySchema,
      FinancialGoalSchema,
      AssetSchema,
    ],
    directory: directory,
    name: name,
  );
}

/// Exposes the already-opened Isar instance to the widget tree via
/// Riverpod. Must be overridden with the real instance (from
/// [openLedgerMateIsar]) when the app's `ProviderScope` is created — there
/// is deliberately no lazy/async default, since every feature reading this
/// provider expects a synchronously-available Isar instance once the app
/// is running past boot.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden with openLedgerMateIsar()\'s result '
    'when the ProviderScope is created (app boot or test setup).',
  );
});
