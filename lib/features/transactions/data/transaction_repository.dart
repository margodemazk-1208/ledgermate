// Transaction data layer (M3): handles CRUD for [Transaction] and
// queries/seeds [Category] in Isar (FR-02, FR-03).
import 'package:isar_community/isar.dart';

import '../../../core/database/category.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/database/transactions_watch.dart';
import '../../../core/database/wallet.dart';

/// Exception thrown when attempting to delete a transaction that is not
/// dated today (FR-03: "Delete dibatasi hanya untuk transaksi tanggal hari ini").
class TransactionDeleteRestrictedException implements Exception {
  const TransactionDeleteRestrictedException([
    this.message =
        'Hanya transaksi bertanggal hari ini yang dapat dihapus (FR-03).',
  ]);

  final String message;

  @override
  String toString() => message;
}

/// Checks whether [transactionDate] falls on the exact same calendar day
/// (year, month, day) as [referenceNow] (defaults to `DateTime.now()`).
/// FR-03 restricts transaction deletion to today-only to protect historical data.
bool isTransactionDeletable(
  DateTime transactionDate, [
  DateTime? referenceNow,
]) {
  final now = referenceNow ?? DateTime.now();
  return transactionDate.year == now.year &&
      transactionDate.month == now.month &&
      transactionDate.day == now.day;
}

/// Default built-in categories seeded on first run (M3, PRD FR-02/FR-09).
const List<String> defaultCategoryNames = [
  'Makan',
  'Transport',
  'Hiburan',
  'Tagihan',
  'Lainnya',
];

/// Interface extracted so UI and widget tests can use a fake in-memory
/// implementation without hitting real Isar, which hangs under `testWidgets()`
/// (see doc comment in `onboarding_repository.dart`).
abstract class TransactionRepositoryBase {
  Stream<List<db.Transaction>> watchTransactions();

  Future<List<db.Transaction>> getTransactions();

  Future<db.Transaction?> getTransaction(int id);

  Future<db.Transaction> saveTransaction({
    int? id,
    required db.TransactionType type,
    required int amount,
    required int categoryId,
    required DateTime date,
    String? notes,
    int? payCycleId,
    int? walletId,
    int? transferPeerWalletId,
    String? transferGroupId,
  });

  Future<void> deleteTransaction(int id, {DateTime? referenceDate});

  Stream<List<Category>> watchCategories();

  Future<List<Category>> getCategories();

  Future<void> seedDefaultCategories();

  /// Resolves the dedicated system-generated income category ID (M23).
  Future<int> resolveSystemIncomeCategoryId();
}

class TransactionRepository implements TransactionRepositoryBase {
  TransactionRepository(this._isar);

  final Isar _isar;

  /// Reactive stream of all transactions sorted reverse-chronologically
  /// (newest first) per FR-02/FR-03.
  ///
  /// M18/D18 perf item 2: delegates to the SHARED watch helper in
  /// `core/database/transactions_watch.dart` instead of opening its own
  /// independent Isar subscription — see that file's header for why.
  @override
  Stream<List<db.Transaction>> watchTransactions() {
    return watchAllTransactionsShared(_isar);
  }

  @override
  Future<List<db.Transaction>> getTransactions() {
    return _isar.transactions.where().sortByDateDesc().findAll();
  }

  @override
  Future<db.Transaction?> getTransaction(int id) {
    return _isar.transactions.get(id);
  }

  /// Persists a new or updated transaction.
  ///
  /// Performance guarantee (PRD §6.1, <50ms save):
  /// Isar transactions run against an in-process, memory-mapped MDBX engine with
  /// zero network or IPC overhead. Storing a single 6-field Transaction object
  /// takes ~1-3ms in practice on flash storage. No structural bottlenecks (e.g.
  /// secondary table cascades or foreign key constraint locks) exist.
  @override
  Future<db.Transaction> saveTransaction({
    int? id,
    required db.TransactionType type,
    required int amount,
    required int categoryId,
    required DateTime date,
    String? notes,
    int? payCycleId,
    int? walletId,
    int? transferPeerWalletId,
    String? transferGroupId,
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Jumlah transaksi harus lebih besar dari nol.',
      );
    }
    int effectiveCategoryId = categoryId;
    if (type == db.TransactionType.transfer) {
      effectiveCategoryId = 0;
    } else if (type == db.TransactionType.income && effectiveCategoryId <= 0) {
      effectiveCategoryId = await resolveSystemIncomeCategoryId();
    }

    if (type != db.TransactionType.transfer && effectiveCategoryId <= 0) {
      throw ArgumentError.value(
        categoryId,
        'categoryId',
        'Kategori transaksi harus dipilih.',
      );
    }

    final isEditing = id != null && id > 0;
    final existingTx = isEditing ? await _isar.transactions.get(id) : null;

    int? effectivePayCycleId = payCycleId;
    if (effectivePayCycleId == null) {
      // For Mode A (periodic income), associate with whichever PayCycle's
      // date range actually covers [date] — NOT unconditionally "the latest
      // cycle" (D18/M16 bug #5: that previously silently re-homed an edited
      // historical transaction into the CURRENT cycle just because the edit
      // didn't touch the date field). Editing a transaction without
      // changing its date naturally resolves back to the SAME cycle it was
      // always in; explicitly moving the date into a different cycle's
      // range correctly re-homes it there instead.
      final profile = await _isar.localProfiles.where().findFirst();
      if (profile?.incomeFrequency == IncomeFrequency.periodic) {
        effectivePayCycleId = await _resolveCycleIdForDate(date);
      }
    }

    int effectiveWalletId = walletId ?? 0;
    if (effectiveWalletId <= 0) {
      final firstWallet = await _isar.wallets
          .where()
          .sortByCreatedAt()
          .findFirst();
      if (firstWallet != null) {
        effectiveWalletId = firstWallet.id;
      } else {
        final defaultWallet = Wallet()
          ..name = defaultWalletName
          ..icon = defaultWalletIcon
          ..startingBalance = 0
          ..includeInDailyBudget = true
          ..createdAt = DateTime.now();
        await _isar.writeTxn(() async {
          final wid = await _isar.wallets.put(defaultWallet);
          defaultWallet.id = wid;
        });
        effectiveWalletId = defaultWallet.id;
      }
    }

    return _isar.writeTxn(() async {
      final tx = existingTx ?? db.Transaction();

      if (isEditing) {
        tx.id = id;
      }
      tx.type = type;
      tx.amount = amount;
      tx.categoryId = effectiveCategoryId;
      tx.date = date;
      tx.notes = notes?.trim().isEmpty == true ? null : notes?.trim();
      tx.payCycleId = effectivePayCycleId;
      tx.walletId = effectiveWalletId;

      // D18/M16 bug #10: a transaction's `transferPeerWalletId`/
      // `transferGroupId` must never survive once its type is no longer
      // `transfer` — otherwise the old peer wallet can never be deleted
      // again (a dangling FK reference to it persists forever). Transfers
      // in this codebase are modeled as a SINGLE row with a peer-wallet
      // reference (see `WalletRepository.transfer`), not two physically
      // linked rows, so there is no second row to delete/convert here —
      // clearing this row's own fields is the complete fix.
      if (type == db.TransactionType.transfer) {
        tx.transferPeerWalletId = transferPeerWalletId;
        tx.transferGroupId = transferGroupId;
      } else {
        tx.transferPeerWalletId = null;
        tx.transferGroupId = null;
      }

      // D18/M16 bug #6: `createdAt` is set ONCE at first save and never
      // touched again on edit — this is what delete-eligibility checks
      // against (see `deleteTransaction` below), so editing a historical
      // transaction's user-facing [date] can never resurrect its delete
      // eligibility.
      tx.createdAt ??= DateTime.now();

      final savedId = await _isar.transactions.put(tx);
      tx.id = savedId;
      return tx;
    });
  }

  /// Finds which [PayCycle]'s date range covers [date] — the most recent
  /// cycle whose `startDate` is on or before [date]. Falls back to the
  /// oldest known cycle if [date] predates every cycle, or `null` if no
  /// cycle exists at all yet.
  Future<int?> _resolveCycleIdForDate(DateTime date) async {
    final cycles = await _isar.payCycles
        .where()
        .sortByStartDateDesc()
        .findAll();
    if (cycles.isEmpty) return null;
    for (final cycle in cycles) {
      if (!date.isBefore(cycle.startDate)) {
        return cycle.id;
      }
    }
    return cycles.last.id; // date predates every known cycle
  }

  /// Deletes a transaction, strictly enforcing the FR-03 restriction:
  /// Only transactions ORIGINALLY CREATED today can be deleted.
  ///
  /// D18/M16 bug #6: this previously checked the user-editable [db.
  /// Transaction.date] field, which meant editing an old transaction's date
  /// to today — then deleting it — bypassed the "can't delete historical
  /// transactions" rule entirely. Checking [db.Transaction.createdAt]
  /// (never touched by edits) closes that loophole. Pre-M16 legacy rows
  /// with no recorded `createdAt` fall back to the old (bypassable)
  /// [db.Transaction.date] check, since there is no way to recover their
  /// true creation date.
  @override
  Future<void> deleteTransaction(int id, {DateTime? referenceDate}) async {
    final tx = await _isar.transactions.get(id);
    if (tx == null) {
      return; // Already deleted or doesn't exist
    }

    if (!isTransactionDeletable(tx.createdAt ?? tx.date, referenceDate)) {
      throw TransactionDeleteRestrictedException();
    }

    await _isar.writeTxn(() async {
      await _isar.transactions.delete(id);
    });
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _isar.categorys.where().watch(fireImmediately: true);
  }

  @override
  Future<List<Category>> getCategories() async {
    await seedDefaultCategories();
    return _isar.categorys.where().findAll();
  }

  /// Seeds default categories if no category exists in the collection yet,
  /// and ensures the system income category exists (M23).
  @override
  Future<void> seedDefaultCategories() async {
    final count = await _isar.categorys.count();
    if (count == 0) {
      await _isar.writeTxn(() async {
        final existingCount = await _isar.categorys.count();
        if (existingCount > 0) return;

        for (final name in defaultCategoryNames) {
          final cat = Category()
            ..name = name
            ..isDefault = true;
          await _isar.categorys.put(cat);
        }
      });
    }

    // Ensure the system income category exists (M23).
    await resolveSystemIncomeCategoryId();
  }

  @override
  Future<int> resolveSystemIncomeCategoryId() {
    return resolveSystemIncomeCategoryId(_isar);
  }
}
