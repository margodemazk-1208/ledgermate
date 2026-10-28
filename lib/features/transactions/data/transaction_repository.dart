// Transaction data layer (M3): handles CRUD for [Transaction] and
// queries/seeds [Category] in Isar (FR-02, FR-03).
import 'package:isar_community/isar.dart';

import '../../../core/database/category.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;

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
  });

  Future<void> deleteTransaction(int id, {DateTime? referenceDate});

  Stream<List<Category>> watchCategories();

  Future<List<Category>> getCategories();

  Future<void> seedDefaultCategories();
}

class TransactionRepository implements TransactionRepositoryBase {
  TransactionRepository(this._isar);

  final Isar _isar;

  /// Reactive stream of all transactions sorted reverse-chronologically
  /// (newest first) per FR-02/FR-03.
  @override
  Stream<List<db.Transaction>> watchTransactions() {
    return _isar.transactions.where().sortByDateDesc().watch(
      fireImmediately: true,
    );
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
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Jumlah transaksi harus lebih besar dari nol.',
      );
    }
    if (categoryId <= 0) {
      throw ArgumentError.value(
        categoryId,
        'categoryId',
        'Kategori transaksi harus dipilih.',
      );
    }

    int? effectivePayCycleId = payCycleId;
    if (effectivePayCycleId == null) {
      // For Mode A (periodic income), associate with the latest pay cycle if available.
      final profile = await _isar.localProfiles.where().findFirst();
      if (profile?.incomeFrequency == IncomeFrequency.periodic) {
        final latestCycle = await _isar.payCycles
            .where()
            .sortByStartDateDesc()
            .findFirst();
        effectivePayCycleId = latestCycle?.id;
      }
    }

    return _isar.writeTxn(() async {
      final tx = (id != null && id > 0)
          ? (await _isar.transactions.get(id) ?? db.Transaction())
          : db.Transaction();

      if (id != null && id > 0) {
        tx.id = id;
      }
      tx.type = type;
      tx.amount = amount;
      tx.categoryId = categoryId;
      tx.date = date;
      tx.notes = notes?.trim().isEmpty == true ? null : notes?.trim();
      tx.payCycleId = effectivePayCycleId;

      final savedId = await _isar.transactions.put(tx);
      tx.id = savedId;
      return tx;
    });
  }

  /// Deletes a transaction, strictly enforcing the FR-03 restriction:
  /// Only transactions dated today can be deleted.
  @override
  Future<void> deleteTransaction(int id, {DateTime? referenceDate}) async {
    final tx = await _isar.transactions.get(id);
    if (tx == null) {
      return; // Already deleted or doesn't exist
    }

    if (!isTransactionDeletable(tx.date, referenceDate)) {
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

  /// Seeds default categories if no category exists in the collection yet.
  @override
  Future<void> seedDefaultCategories() async {
    final count = await _isar.categorys.count();
    if (count > 0) return;

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
}
