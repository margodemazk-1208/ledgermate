// M18 Performance Optimization (docs/ROADMAP.md M18, item 4): re-runs the
// SAME 800-transaction benchmark methodology M15 used (see
// `docs/PERFORMANCE.md`), comparing first-frame build cost of:
//   (a) the OLD structure — one eagerly-built `Column` of ALL transaction
//       tiles per date-group, inside an outer `ListView(children: [...])`
//       (reproduced here verbatim from the pre-M18 `transactions_screen.dart`
//       since that code no longer exists in the app after this fix)
//   (b) the NEW structure — the actual `TransactionsScreen` widget, now a
//       flat `ListView.builder` over individually-virtualized rows (M18
//       items 3+4)
//
// M15's own finding was "no measurable difference" for a GROUP-level
// `ListView.builder` (itemBuilder returning one Column-of-all-items
// Container per date, same eager-Column-per-group problem either way).
// This test specifically exercises the STRUCTURALLY DIFFERENT fix — row
// granularity, not group granularity — and reports the real, measured
// result honestly either way (see docs/PERFORMANCE.md for the verdict).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/core/theme/app_theme.dart';
import 'package:ledgermate/core/theme/app_typography.dart';
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';
import 'package:ledgermate/features/transactions/presentation/transactions_screen.dart';

import '../features/transactions/fake_transaction_repository.dart';

String _ms(Duration d) => '${(d.inMicroseconds / 1000).toStringAsFixed(3)}ms';

String _oldGroupLabel(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(date.year, date.month, date.day);
  if (day == today) {
    return 'Hari Ini — ${DateFormat('EEEE, d MMM', 'id_ID').format(date)}';
  }
  if (day == today.subtract(const Duration(days: 1))) {
    return 'Kemarin — ${DateFormat('EEEE, d MMM', 'id_ID').format(date)}';
  }
  return DateFormat('EEEE, d MMM yyyy', 'id_ID').format(date);
}

/// Faithful reconstruction of the PRE-M18 `TransactionsScreen` body: one
/// eagerly-built `Column` of every transaction tile per date-group inside
/// an outer non-virtualized `ListView(children: ...)` — the exact
/// structure M15 benchmarked and the task brief asks to re-verify with a
/// genuinely different (row-level) virtualization approach.
class _OldStyleTransactionsList extends StatelessWidget {
  const _OldStyleTransactionsList({required this.transactions});

  final List<db.Transaction> transactions;

  List<Widget> _buildGroupedCards(BuildContext context) {
    final groups = <String, List<db.Transaction>>{};
    for (final tx in transactions) {
      groups.putIfAbsent(_oldGroupLabel(tx.date), () => []).add(tx);
    }

    final widgets = <Widget>[];
    groups.forEach((label, txs) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(label, style: AppTypography.mono(fontSize: 12)),
              ),
              for (final tx in txs)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      Expanded(child: Text('Kategori #${tx.categoryId}')),
                      Text(
                        DateFormat('HH:mm').format(tx.date),
                        style: AppTypography.mono(fontSize: 11),
                      ),
                      Text('${tx.amount}'),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    });
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      children: _buildGroupedCards(context),
    );
  }
}

List<db.Transaction> _seedTransactions(int count) {
  final now = DateTime.now();
  return List.generate(count, (i) {
    final daysAgo = i % 180;
    return db.Transaction()
      ..id = i + 1
      ..type = i % 6 == 0
          ? db.TransactionType.income
          : db.TransactionType.expense
      ..amount = 10000 + (i * 137) % 490000
      ..categoryId = (i % 5) + 1
      ..date = now.subtract(Duration(days: daysAgo, hours: i % 24))
      ..notes = i % 7 == 0 ? 'Catatan transaksi #$i' : null;
  });
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  testWidgets('first-frame build time: old eager Column-per-group vs new '
      'ListView.builder row-level virtualization (M18/D18 perf item 4, '
      '800 transactions, same volume as M15)', (tester) async {
    const count = 800;
    final transactions = _seedTransactions(count);

    // --- OLD structure --------------------------------------------------
    final oldSw = Stopwatch()..start();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        home: _OldStyleTransactionsList(transactions: transactions),
      ),
    );
    oldSw.stop();
    await tester.pumpAndSettle();

    // --- NEW structure (actual, current TransactionsScreen) ------------
    final fakeRepository = FakeTransactionRepository(
      initialTransactions: transactions,
    );
    addTearDown(fakeRepository.dispose);

    final newSw = Stopwatch()..start();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp(
          theme: AppTheme.dark,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          // M21/Bug 1: `TransactionsScreen` is now bare body content — wrap
          // in a `Scaffold` for the `Material` ancestor its rows need,
          // matching what `AppShell` supplies in production.
          home: const Scaffold(body: TransactionsScreen()),
        ),
      ),
    );
    newSw.stop();
    await tester.pumpAndSettle();

    // ignore: avoid_print
    print(
      '[PERF][M18] TransactionsScreen first-frame build @ $count tx: '
      'OLD (eager Column-per-group)=${_ms(oldSw.elapsed)} vs '
      'NEW (ListView.builder, row-level)=${_ms(newSw.elapsed)}',
    );

    // Subsequent-rebuild cost (e.g. an unrelated theme/provider change
    // forcing a rebuild without new data) — the other half of M15's
    // original comparison.
    final oldRebuildSw = Stopwatch()..start();
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: _OldStyleTransactionsList(transactions: transactions),
      ),
    );
    oldRebuildSw.stop();

    final newRebuildSw = Stopwatch()..start();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: TransactionsScreen()),
        ),
      ),
    );
    newRebuildSw.stop();

    // ignore: avoid_print
    print(
      '[PERF][M18] TransactionsScreen subsequent rebuild @ $count tx: '
      'OLD=${_ms(oldRebuildSw.elapsed)} vs NEW=${_ms(newRebuildSw.elapsed)}',
    );
  });
}
