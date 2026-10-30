import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../accrual/daily_accrual_service.dart';
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

/// Name of the dedicated system-generated category used to attribute
/// bookkeeping transactions the app itself creates (goal withdrawals, Mode B
/// bekel rollover entries) — never the arbitrary "first category found"
/// (which happened to be "Makan" in practice, D18/M16 bug #2 & #3).
const String systemCategoryName = 'Penyesuaian Sistem';

/// Resolves a real, existing wallet id to attribute a system-generated
/// transaction to (goal withdrawals, Mode B bekel rollover — D18/M16 bug
/// #2 & #3). Deliberately NEVER returns `0`/a placeholder: writing a
/// transaction with `walletId == 0` is exactly what caused those bugs
/// (the amount never reached any real wallet's computed balance, and
/// [migrateIsarSchema] would treat it as pre-v1.1 orphaned data on next
/// app open, creating a stray duplicate "Dompet Utama" wallet if the
/// user had since renamed their original one).
///
/// Prefers the oldest wallet with `includeInDailyBudget == true` (so the
/// credited amount actually reaches the Smart Daily Budget Engine, which is
/// the entire point of FR-06c/BR-03's withdraw-feeds-back-into-balance
/// behavior); falls back to the oldest wallet overall; creates the default
/// wallet as a last resort (should not normally happen post-onboarding,
/// since FR-01 requires at least 1 wallet to exist).
Future<int> resolveDefaultWalletId(Isar isar) async {
  final budgetWallet = await isar.wallets
      .filter()
      .includeInDailyBudgetEqualTo(true)
      .sortByCreatedAt()
      .findFirst();
  if (budgetWallet != null) return budgetWallet.id;

  final anyWallet = await isar.wallets.where().sortByCreatedAt().findFirst();
  if (anyWallet != null) return anyWallet.id;

  final created = Wallet()
    ..name = defaultWalletName
    ..icon = defaultWalletIcon
    ..startingBalance = 0
    ..includeInDailyBudget = true
    ..createdAt = DateTime.now();
  // Matches the established pattern elsewhere in this codebase (see
  // `TransactionRepository.saveTransaction`'s own default-wallet fallback):
  // this helper is called OUTSIDE/BEFORE the caller's own `writeTxn` block,
  // never nested inside one, so it opens its own transaction here.
  await isar.writeTxn(() async {
    final id = await isar.wallets.put(created);
    created.id = id;
  });
  return created.id;
}

/// Resolves the dedicated system-generated [Category] id, creating it if it
/// doesn't exist yet. Used instead of "whichever category happens to be
/// first" (D18/M16 bug #2 & #3, which in practice always picked "Makan").
///
/// Like [resolveDefaultWalletId], call this BEFORE opening the caller's own
/// `writeTxn` block — it opens its own transaction for the creation path.
Future<int> resolveSystemCategoryId(Isar isar) async {
  final existing = await isar.categorys
      .filter()
      .isSystemGeneratedEqualTo(true)
      .findFirst();
  if (existing != null) return existing.id;

  final created = Category()
    ..name = systemCategoryName
    ..isDefault = false
    ..isSystemGenerated = true;
  await isar.writeTxn(() async {
    final id = await isar.categorys.put(created);
    created.id = id;
  });
  return created.id;
}

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
  await runDailyAccrualCatchUp(isar);
  return isar;
}

/// Exposes the already-opened Isar instance to the widget tree via Riverpod.
final isarProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarProvider must be overridden with openLedgerMateIsar() result '
    'when the ProviderScope is created (app boot or test setup).',
  );
});
