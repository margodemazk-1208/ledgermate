import 'dart:async';

import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/analytics/data/analytics_repository.dart';
import 'package:ledgermate/features/transactions/data/transaction_repository.dart';

/// In-memory test double for [AnalyticsRepositoryBase] to avoid Isar async
/// hangs under `testWidgets()`.
class FakeAnalyticsRepository implements AnalyticsRepositoryBase {
  FakeAnalyticsRepository({
    List<Category>? initialCategories,
    List<db.Transaction>? initialTransactions,
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

  void _notifyTransactions() {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    _transactionsController.add(sorted);
  }

  void _notifyCategories() {
    _categoriesController.add([..._categories]);
  }

  void addTransaction(db.Transaction tx) {
    _transactions.add(tx);
    _notifyTransactions();
  }

  void setTransactions(List<db.Transaction> txs) {
    _transactions
      ..clear()
      ..addAll(txs);
    _notifyTransactions();
  }

  @override
  Stream<List<db.Transaction>> watchTransactions() {
    final sorted = [..._transactions]..sort((a, b) => b.date.compareTo(a.date));
    return Stream<List<db.Transaction>>.value(sorted)
        .concatWith(_transactionsController.stream);
  }

  @override
  Future<List<db.Transaction>> getTransactionsInRange(
    DateTime start,
    DateTime end,
  ) async {
    final filtered =
        _transactions
            .where((t) => !t.date.isBefore(start) && !t.date.isAfter(end))
            .toList()
          ..sort((a, b) => b.date.compareTo(a.date));
    return filtered;
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
