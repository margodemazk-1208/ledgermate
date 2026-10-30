// M18 Performance Optimization (docs/ROADMAP.md M18, item 2): the single
// shared Isar watch over the entire `transactions` collection, reused by
// every repository that needs the full reverse-chronological list
// (`TransactionRepository`, `BudgetRepository`, `AnalyticsRepository`).
//
// Before this fix, each of those 3 repositories opened its OWN independent
// `isar.transactions.where().sortByDateDesc().watch(fireImmediately: true)`
// subscription — 3 separate native Isar watches, each re-querying and
// re-sorting the ENTIRE table on every single transaction write (save,
// edit, delete, transfer, goal withdraw, Mode B bekel rollover, ...).
// Caching the watcher per [Isar] instance (keyed by object identity via
// [Expando], since tests open many short-lived [Isar] instances) means
// every repository shares the exact same underlying native watch.
import 'dart:async';

import 'package:isar_community/isar.dart';

import 'transaction.dart' as db;

final Expando<_SharedTransactionsWatcher> _watchers = Expando();

/// Returns the shared reverse-chronological transactions stream for
/// [isar]. Safe to call from multiple repository instances wrapping the
/// SAME [Isar] instance — the underlying native `.watch()` subscription is
/// created at most once per [Isar] instance and kept alive for its
/// lifetime (never torn down just because one caller unsubscribes), since
/// `StreamProvider`s built on top of this are themselves kept alive for
/// the whole app lifetime.
Stream<List<db.Transaction>> watchAllTransactionsShared(Isar isar) {
  final watcher = _watchers[isar] ??= _SharedTransactionsWatcher(isar);
  return watcher.stream;
}

class _SharedTransactionsWatcher {
  _SharedTransactionsWatcher(Isar isar) {
    _subscription = isar.transactions
        .where()
        .sortByDateDesc()
        .watch(fireImmediately: true)
        .listen((data) {
          _latest = data;
          _controller.add(data);
        }, onError: _controller.addError);
  }

  List<db.Transaction>? _latest;
  // Intentionally retained (never cancelled): this watcher lives for the
  // whole Isar instance's lifetime (see class doc comment), so there is no
  // "dispose" path that reads this field back — it exists purely so the
  // subscription itself isn't eligible for garbage collection.
  // ignore: unused_field
  late final StreamSubscription<List<db.Transaction>> _subscription;
  final _controller = StreamController<List<db.Transaction>>.broadcast();

  /// Each call returns a FRESH [Stream] instance that immediately replays
  /// the most recently seen value (matching `watch(fireImmediately: true)`
  /// 's per-subscriber semantics) before forwarding subsequent live
  /// updates. A plain `StreamController.broadcast()` on its own would NOT
  /// replay anything to a listener that subscribes after the first value
  /// already fired — e.g. `BudgetHomeScreen` subscribing after
  /// `TransactionsScreen` already triggered the initial emission would
  /// otherwise be stuck on `AsyncValue.loading()` until the next write.
  Stream<List<db.Transaction>> get stream async* {
    final cached = _latest;
    if (cached != null) {
      yield cached;
    }
    yield* _controller.stream;
  }
}
