// M18 Performance Optimization (docs/ROADMAP.md M18, item 3): date-grouping
// of the transaction list previously happened inline inside
// `TransactionsScreen.build()` (`_buildGroupedCards`), re-running on EVERY
// rebuild (including rebuilds that have nothing to do with the transaction
// list itself, e.g. a parent theme change) and re-constructing a
// `DateFormat` per call. Moving it into a `Provider` means Riverpod only
// recomputes it when `transactionsStreamProvider`/the type filter actually
// change — not once per frame — and the `DateFormat` instances below are
// constructed exactly once (module-level `final`s), not once per group
// label or per list item.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/transaction.dart' as db;
import 'transaction_providers.dart';

/// Hoisted out of per-row/per-label builders (M18 item 3) — `DateFormat` is
/// safe to construct once and reuse across calls.
final _groupHeaderWeekdayDateFormat = DateFormat('EEEE, d MMM', 'id_ID');
final _groupHeaderFullDateFormat = DateFormat('EEEE, d MMM yyyy', 'id_ID');

/// Which [db.TransactionType] filter is active on `TransactionsScreen`.
/// `null` means "Semua" (no filter). Lifted out of the screen's local
/// `State` into a provider so the derived [groupedTransactionsProvider]
/// below can watch it and recompute only when it actually changes.
class TransactionTypeFilterNotifier extends Notifier<db.TransactionType?> {
  @override
  db.TransactionType? build() => null;

  void select(db.TransactionType? type) => state = type;
}

final transactionTypeFilterProvider =
    NotifierProvider<TransactionTypeFilterNotifier, db.TransactionType?>(
      TransactionTypeFilterNotifier.new,
    );

/// One flattened row in the virtualized transaction list
/// (`ListView.builder`, M18 item 4) — either a date-group header or a
/// single transaction within that group. Flattening to row-granularity
/// (instead of one `Column` of transactions per date, M15's abandoned
/// attempt — see `docs/PERFORMANCE.md`) is what actually lets
/// `ListView.builder` lazily build/mount only the rows near the viewport,
/// since Flutter's Sliver protocol virtualizes per `itemBuilder` call, not
/// per nested child inside a non-virtualized `Column`.
sealed class TransactionListRow {
  const TransactionListRow();
}

class TransactionGroupHeaderRow extends TransactionListRow {
  const TransactionGroupHeaderRow(this.label);
  final String label;
}

class TransactionItemRow extends TransactionListRow {
  const TransactionItemRow({
    required this.transaction,
    required this.categoryName,
    required this.isFirstInGroup,
    required this.isLastInGroup,
  });

  final db.Transaction transaction;
  final String categoryName;

  /// Drives the rounded-top/border styling that recreates the single
  /// bordered "day card" look across multiple flattened `ListView.builder`
  /// rows (see `_TransactionRowTile` in `transactions_screen.dart`).
  final bool isFirstInGroup;
  final bool isLastInGroup;
}

String _groupLabelFor(DateTime date, DateTime now) {
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) {
    return 'Hari Ini — ${_groupHeaderWeekdayDateFormat.format(date)}';
  }
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Kemarin — ${_groupHeaderWeekdayDateFormat.format(date)}';
  }
  return _groupHeaderFullDateFormat.format(date);
}

/// Pure grouping function — computes the flattened, display-ready row list
/// from raw transactions. Exposed standalone (not just via the provider
/// below) so it stays unit-testable without a widget/Riverpod harness.
List<TransactionListRow> groupTransactionsForDisplay({
  required List<db.Transaction> transactions,
  required Map<int, String> categoryNames,
  db.TransactionType? filter,
  DateTime? referenceNow,
}) {
  final now = referenceNow ?? DateTime.now();
  final filtered = filter == null
      ? transactions
      : transactions.where((t) => t.type == filter).toList();

  final groups = <String, List<db.Transaction>>{};
  for (final tx in filtered) {
    groups.putIfAbsent(_groupLabelFor(tx.date, now), () => []).add(tx);
  }

  final rows = <TransactionListRow>[];
  groups.forEach((label, txs) {
    rows.add(TransactionGroupHeaderRow(label));
    for (var i = 0; i < txs.length; i++) {
      final tx = txs[i];
      rows.add(
        TransactionItemRow(
          transaction: tx,
          categoryName: tx.type == db.TransactionType.transfer
              ? 'Transfer'
              : (categoryNames[tx.categoryId] ?? 'Kategori #${tx.categoryId}'),
          isFirstInGroup: i == 0,
          isLastInGroup: i == txs.length - 1,
        ),
      );
    }
  });
  return rows;
}

/// Reactively recomputed ONLY when the transaction stream, category map, or
/// active type filter change — never on an unrelated rebuild (M18 item 3).
final groupedTransactionsProvider =
    Provider<AsyncValue<List<TransactionListRow>>>((ref) {
      final txsAsync = ref.watch(transactionsStreamProvider);
      final categoriesMap = ref.watch(categoriesMapProvider);
      final filter = ref.watch(transactionTypeFilterProvider);

      return txsAsync.whenData((transactions) {
        return groupTransactionsForDisplay(
          transactions: transactions,
          categoryNames: {
            for (final entry in categoriesMap.entries)
              entry.key: entry.value.name,
          },
          filter: filter,
        );
      });
    });
