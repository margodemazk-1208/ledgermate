import 'dart:async';

import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/transactions/data/transaction_repository.dart';

/// In-memory test double for [TransactionRepositoryBase] to avoid Isar async
/// hangs under `testWidgets()`.
class FakeTransactionRepository implements TransactionRepositoryBase {
  FakeTransactionRepository({
    List<Category>? initialCategories,
    List<db.Transaction>? initialTransactions,
    this.referenceDate,
  }) {
    if (initialCategories != null) {
      _categories.addAll(initialCategories);
    } else {
      for (var i = 0; i < defaultCategoryNames.length; i++) {
        _categories.add(
          Category()
            ..id = i + 1
            ..name = defaultCategoryNames[i]
            ..isDefault = true,
        );
      }
      _categories.add(
        Category()
          ..id = ++_nextId
          ..name = systemIncomeCategoryName
          ..isDefault = false
          ..isSystemGenerated = true,
      );
    }
    if (initialTransactions != null) {
      _transactions.addAll(initialTransactions);
    }
    _notifyCategories();
    _notifyTransactions();
  }

  final List<Category> _categories = [];
  final List<db.Transaction> _transactions = [];
  final _transactionsController =
      StreamController<List<db.Transaction>>.broadcast();
  final _categoriesController = StreamController<List<Category>>.broadcast();

  DateTime? referenceDate;
  int _nextId = 100;
  Object? failNextSaveWith;
  Object? failNextDeleteWith;

  final List<db.Transaction> savedCalls = [];
  final List<int> deletedIds = [];

  void _notifyTransactions() {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    _transactionsController.add(sorted);
  }

  void _notifyCategories() {
    _categoriesController.add([..._categories]);
  }

  @override
  Stream<List<db.Transaction>> watchTransactions() {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return Stream<List<db.Transaction>>.value(sorted)
        .concatWith(_transactionsController.stream);
  }

  @override
  Future<List<db.Transaction>> getTransactions() async {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return sorted;
  }

  @override
  Future<db.Transaction?> getTransaction(int id) async {
    try {
      return _transactions.firstWhere((t) => t.id == id);
    } catch (_) {
      return null;
    }
  }

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
    if (failNextSaveWith != null) {
      final err = failNextSaveWith!;
      failNextSaveWith = null;
      throw err;
    }
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

    db.Transaction tx;
    if (id != null && id > 0) {
      final index = _transactions.indexWhere((t) => t.id == id);
      if (index >= 0) {
        tx = _transactions[index];
      } else {
        tx = db.Transaction()..id = id;
        _transactions.add(tx);
      }
    } else {
      tx = db.Transaction()..id = ++_nextId;
      _transactions.add(tx);
    }

    tx.type = type;
    tx.amount = amount;
    tx.categoryId = effectiveCategoryId;
    tx.date = date;
    tx.notes = notes;
    tx.payCycleId = payCycleId;
    tx.walletId = walletId ?? 1;
    tx.transferPeerWalletId = transferPeerWalletId;
    tx.transferGroupId = transferGroupId;

    savedCalls.add(tx);
    _notifyTransactions();
    return tx;
  }

  @override
  Future<void> deleteTransaction(int id, {DateTime? referenceDate}) async {
    if (failNextDeleteWith != null) {
      final err = failNextDeleteWith!;
      failNextDeleteWith = null;
      throw err;
    }

    final tx = await getTransaction(id);
    if (tx == null) return;

    final ref = referenceDate ?? this.referenceDate ?? DateTime.now();
    if (!isTransactionDeletable(tx.date, ref)) {
      throw const TransactionDeleteRestrictedException();
    }

    _transactions.removeWhere((t) => t.id == id);
    deletedIds.add(id);
    _notifyTransactions();
  }

  @override
  Stream<List<Category>> watchCategories() {
    return Stream<List<Category>>.value([..._categories])
        .concatWith(_categoriesController.stream);
  }

  @override
  Future<List<Category>> getCategories() async {
    return [..._categories];
  }

  @override
  Future<void> seedDefaultCategories() async {
    if (_categories.isEmpty) {
      for (var i = 0; i < defaultCategoryNames.length; i++) {
        _categories.add(
          Category()
            ..id = i + 1
            ..name = defaultCategoryNames[i]
            ..isDefault = true,
        );
      }
    }
    final hasIncome = _categories.any(
      (c) => c.name == systemIncomeCategoryName && c.isSystemGenerated,
    );
    if (!hasIncome) {
      _categories.add(
        Category()
          ..id = ++_nextId
          ..name = systemIncomeCategoryName
          ..isDefault = false
          ..isSystemGenerated = true,
      );
    }
    _notifyCategories();
  }

  @override
  Future<int> resolveSystemIncomeCategoryId() async {
    for (final c in _categories) {
      if (c.name == systemIncomeCategoryName && c.isSystemGenerated) {
        return c.id;
      }
    }
    final cat = Category()
      ..id = ++_nextId
      ..name = systemIncomeCategoryName
      ..isDefault = false
      ..isSystemGenerated = true;
    _categories.add(cat);
    _notifyCategories();
    return cat.id;
  }

  void dispose() {
    _transactionsController.close();
    _categoriesController.close();
  }
}

extension<T> on Stream<T> {
  Stream<T> concatWith(Stream<T> other) async* {
    yield* this;
    yield* other;
  }
}
