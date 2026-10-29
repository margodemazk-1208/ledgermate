import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import 'asset.dart';
import 'category.dart';
import 'financial_goal.dart';
import 'local_profile.dart';
import 'pay_cycle.dart';
import 'transaction.dart';
import 'wallet.dart';

// ============================================================================
// Decimal representation decision (M1) — flagged for M4 (Smart Daily Budget
// Engine), which owns the actual division/precision work:
//
// Isar has no native Decimal/BigDecimal type. Every monetary field across
// all collections is stored as a plain Dart `int` representing a whole IDR
// Rupiah amount.
// ============================================================================

/// Default wallet name used for backfilling pre-v1.1 transaction data (D16, FR-12).
const String defaultWalletName = 'Dompet Utama';
const String defaultWalletIcon = 'account_balance_wallet';

/// Schema migration for v1.1 Multi-Wallet system (PRD §8, DECISIONS.md D16).
///
/// If any [Transaction] exists with `walletId == 0`,
/// this automatically creates a default "Dompet Utama" [Wallet] (startingBalance=0,
/// includeInDailyBudget=true) and backfills every pre-existing transaction's
/// `walletId` to point at it before any UI loads.
///
/// Idempotent: safe to run on every database open.
Future<void> migrateIsarSchema(Isar isar) async {
  final unassignedCount = await isar.transactions
      .filter()
      .walletIdEqualTo(0)
      .count();

  if (unassignedCount == 0) {
    return;
  }

  await isar.writeTxn(() async {
    final unassigned = await isar.transactions
        .filter()
        .walletIdEqualTo(0)
        .findAll();

    if (unassigned.isEmpty) {
      return;
    }

    var defaultWallet = await isar.wallets
        .filter()
        .nameEqualTo(defaultWalletName)
        .findFirst();

    if (defaultWallet == null) {
      defaultWallet = Wallet()
        ..name = defaultWalletName
        ..icon = defaultWalletIcon
        ..startingBalance = 0
        ..includeInDailyBudget = true
        ..createdAt = DateTime.now();
      final newId = await isar.wallets.put(defaultWallet);
      defaultWallet.id = newId;
    }

    for (final tx in unassigned) {
      tx.walletId = defaultWallet.id;
      await isar.transactions.put(tx);
    }
  });
}

/// Opens the single Isar instance that stores all PRD §8 collections (including Wallet for v1.1).
/// Automatically executes schema migrations before returning.
Future<Isar> openLedgerMateIsar({
  required String directory,
  String name = Isar.defaultName,
}) async {
  final existing = Isar.getInstance(name);
  if (existing != null) {
    return existing;
  }
  final isar = await Isar.open(
    [
      LocalProfileSchema,
      PayCycleSchema,
      TransactionSchema,
      CategorySchema,
      FinancialGoalSchema,
      AssetSchema,
      WalletSchema,
    ],
    directory: directory,
    name: name,
  );

  await migrateIsarSchema(isar);
  return isar;
}

/// Exposes the already-opened Isar instance to the widget tree via Riverpod.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden with openLedgerMateIsar() result '
    'when the ProviderScope is created (app boot or test setup).',
  );
});
