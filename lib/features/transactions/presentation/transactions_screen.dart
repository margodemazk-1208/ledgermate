import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/transaction.dart' as db;
import '../../../core/presentation/navigation/slide_page_route.dart';
import '../../../core/presentation/widgets/app_bottom_nav.dart';
import '../../../core/presentation/widgets/icon_circle.dart';
import '../../../core/presentation/widgets/filter_pill.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../core/presentation/widgets/slide_fade_in_once.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/transaction_grouping.dart';
import '../application/transaction_providers.dart';
import 'transaction_form_screen.dart';

/// Screen displaying a reverse-chronological list of transactions (FR-02, FR-03),
/// with an add button and tap-to-edit interactions.
///
/// Visuals rebuilt for M13 (v1.2) per `docs/design/mockups/02_transaksi.html`:
/// date-grouped cards, filter pills, icon-circle per row, color-coded amounts.
///
/// M18 (v1.3 perf): grouping now lives in `groupedTransactionsProvider`
/// (computed once per data/filter change, not per frame — item 3) and the
/// list itself is a `ListView.builder` over the FLATTENED row list, which
/// genuinely virtualizes at per-transaction granularity rather than
/// per-date-group (item 4) — see `docs/PERFORMANCE.md` for the measured
/// before/after and why M15's earlier group-level attempt showed no
/// improvement.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rowsAsync = ref.watch(groupedTransactionsProvider);
    final filter = ref.watch(transactionTypeFilterProvider);
    // Only used to distinguish "database genuinely has zero transactions"
    // (show the full empty state) from "filter matched zero rows" (show
    // the lighter inline message) — `groupedTransactionsProvider` alone
    // can't tell these apart once filtered.
    final isDatabaseEmpty =
        ref.watch(transactionsStreamProvider).value?.isEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Transaksi',
          style: AppTypography.script(fontSize: 20),
        ),
      ),
      body: rowsAsync.when(
        data: (rows) {
          if (isDatabaseEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            // +1 for the filter-pill header row always at index 0.
            itemCount: rows.length + 1 + (rows.isEmpty ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _FilterRow(
                    selected: filter,
                    onSelected: (f) => ref
                        .read(transactionTypeFilterProvider.notifier)
                        .select(f),
                  ),
                );
              }
              if (rows.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text('Tidak ada transaksi untuk filter ini.'),
                  ),
                );
              }
              final row = rows[index - 1];
              return switch (row) {
                TransactionGroupHeaderRow() => _GroupHeaderTile(
                  label: row.label,
                ),
                TransactionItemRow() => _TransactionRowTile(row: row),
              };
            },
          );
        },
        loading: () => const TransactionsSkeletonList(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat transaksi: $err',
              style: const TextStyle(color: AppColors.expenseRed),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add_transaction_fab'),
        onPressed: () {
          Navigator.of(
            context,
          ).push(SlidePageRoute(builder: (_) => const TransactionFormScreen()));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.receipt_long_outlined,
              size: 64,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
            const SizedBox(height: 16),
            Text(
              'Belum Ada Transaksi',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Catat pengeluaran atau pemasukan pertamamu dengan tombol di bawah.',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const ValueKey('empty_state_add_button'),
              onPressed: () {
                Navigator.of(context).push(
                  SlidePageRoute(builder: (_) => const TransactionFormScreen()),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('Tambah Transaksi Pertama'),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.selected, required this.onSelected});

  final db.TransactionType? selected;
  final ValueChanged<db.TransactionType?> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FilterPill(
          label: 'Semua',
          selected: selected == null,
          onTap: () => onSelected(null),
        ),
        const SizedBox(width: 8),
        FilterPill(
          label: 'Pemasukan',
          selected: selected == db.TransactionType.income,
          onTap: () => onSelected(db.TransactionType.income),
        ),
        const SizedBox(width: 8),
        FilterPill(
          label: 'Pengeluaran',
          selected: selected == db.TransactionType.expense,
          onTap: () => onSelected(db.TransactionType.expense),
        ),
      ],
    );
  }
}

/// Top of a date-group "card" — recreates the rounded-top/bordered look a
/// single enclosing `Container` used to provide, now split across
/// individually-virtualized `ListView.builder` rows (M18 item 4).
class _GroupHeaderTile extends StatelessWidget {
  const _GroupHeaderTile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
        border: Border(
          top: BorderSide(color: theme.dividerColor),
          left: BorderSide(color: theme.dividerColor),
          right: BorderSide(color: theme.dividerColor),
        ),
      ),
      child: Text(
        label,
        style: AppTypography.mono(
          fontSize: 12,
          color: theme.textTheme.bodySmall?.color,
        ),
      ),
    );
  }
}

/// One transaction row within a date-group "card". [TransactionItemRow.
/// isLastInGroup] closes the card's bottom border/rounded corners and adds
/// breathing room before the next group's header (M18 item 4).
class _TransactionRowTile extends StatelessWidget {
  const _TransactionRowTile({required this.row});

  final TransactionItemRow row;

  static final _timeFormat = DateFormat('HH:mm');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final transaction = row.transaction;
    final isExpense = transaction.type == db.TransactionType.expense;
    final isTransfer = transaction.type == db.TransactionType.transfer;
    final amountFormatted = formatRupiah(transaction.amount);
    final timeFormatted = _timeFormat.format(transaction.date);

    final color = isTransfer
        ? theme.textTheme.bodySmall?.color
        : (isExpense
              ? AppColors.expenseRedText(theme.brightness)
              : AppColors.savingsGreenText(theme.brightness));

    return Container(
      margin: EdgeInsets.only(bottom: row.isLastInGroup ? 16 : 0),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: row.isLastInGroup
            ? const BorderRadius.vertical(bottom: Radius.circular(18))
            : null,
        border: Border(
          left: BorderSide(color: theme.dividerColor),
          right: BorderSide(color: theme.dividerColor),
          bottom: row.isLastInGroup
              ? BorderSide(color: theme.dividerColor)
              : BorderSide.none,
        ),
      ),
      child: SlideFadeInOnce(
        key: ValueKey('transaction_slide_${transaction.id}'),
        child: InkWell(
          key: ValueKey('transaction_item_${transaction.id}'),
          onTap: () {
            Navigator.of(context).push(
              SlidePageRoute(
                builder: (_) => TransactionFormScreen(transaction: transaction),
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              border: row.isLastInGroup
                  ? null
                  : Border(bottom: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                IconCircle(
                  icon: isTransfer
                      ? Icons.swap_horiz
                      : (isExpense ? Icons.arrow_upward : Icons.arrow_downward),
                  size: 36,
                  color: color,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.categoryName,
                        style: AppTypography.mono(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        transaction.notes != null &&
                                transaction.notes!.isNotEmpty
                            ? '$timeFormatted • ${transaction.notes}'
                            : timeFormatted,
                        style: AppTypography.mono(
                          fontSize: 11,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${isTransfer ? '' : (isExpense ? '- ' : '+ ')}$amountFormatted',
                  style: AppTypography.mono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
