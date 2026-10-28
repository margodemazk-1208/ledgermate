// Analytics data layer (M8): queries transactions and categories for
// visual breakdown and month-over-month trend analysis (FR-07).
import 'package:isar_community/isar.dart';

import '../../../core/database/category.dart';
import '../../../core/database/transaction.dart' as db;

abstract class AnalyticsRepositoryBase {
  /// Reactive stream of all transactions sorted reverse-chronologically.
  /// Emits whenever any transaction is created, updated, or removed.
  Stream<List<db.Transaction>> watchTransactions();

  /// Queries transactions within a specific [start] and [end] date window.
  /// Uses Isar's query engine to filter by date boundary.
  Future<List<db.Transaction>> getTransactionsInRange(
    DateTime start,
    DateTime end,
  );

  /// Reactive stream of available categories.
  Stream<List<Category>> watchCategories();

  /// Gets all available categories from Isar.
  Future<List<Category>> getCategories();
}

class AnalyticsRepository implements AnalyticsRepositoryBase {
  AnalyticsRepository(this._isar);

  final Isar _isar;

  @override
  Stream<List<db.Transaction>> watchTransactions() {
    return _isar.transactions.where().sortByDateDesc().watch(
      fireImmediately: true,
    );
  }

  @override
  Future<List<db.Transaction>> getTransactionsInRange(
    DateTime start,
    DateTime end,
  ) {
    return _isar.transactions
        .filter()
        .dateBetween(start, end)
        .sortByDateDesc()
        .findAll();
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _isar.categorys.where().watch(fireImmediately: true);
  }

  @override
  Future<List<Category>> getCategories() {
    return _isar.categorys.where().findAll();
  }
}
