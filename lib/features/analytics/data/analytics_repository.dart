// Analytics data layer (M8): queries transactions and categories for
// visual breakdown and month-over-month trend analysis (FR-07).
import 'package:isar_community/isar.dart';

import '../../../core/database/category.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/database/transactions_watch.dart';

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

  /// M18/D18 perf item 2: delegates to the SHARED watch helper in
  /// `core/database/transactions_watch.dart` instead of opening its own
  /// independent Isar subscription — see that file's header for why.
  @override
  Stream<List<db.Transaction>> watchTransactions() {
    return watchAllTransactionsShared(_isar);
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
