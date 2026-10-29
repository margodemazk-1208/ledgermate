import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/transaction.dart' as db;
import '../../../core/presentation/widgets/app_bottom_nav.dart';
import '../../../core/presentation/widgets/icon_circle.dart';
import '../../../core/presentation/widgets/filter_pill.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/transaction_providers.dart';
import 'transaction_form_screen.dart';

/// Screen displaying a reverse-chronological list of transactions (FR-02, FR-03),
/// with an add button and tap-to-edit interactions.
///
/// Visuals rebuilt for M13 (v1.2) per `docs/design/mockups/02_transaksi.html`:
/// date-grouped cards, filter pills, icon-circle per row, color-coded amounts.
class TransactionsScreen extends ConsumerStatefulWidget {
  const TransactionsScreen({super.key});

  @override
  ConsumerState<TransactionsScreen> createState() => _TransactionsScreenState();
}

/// Null = "Semua" (no filter).
class _TransactionsScreenState extends ConsumerState<TransactionsScreen> {
  db.TransactionType? _filter;

  String _groupLabel(DateTime date) {
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

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final categoriesMap = ref.watch(categoriesMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Daftar Transaksi',
          style: AppTypography.script(fontSize: 20),
        ),
      ),
      body: transactionsAsync.when(
        data: (allTransactions) {
          if (allTransactions.isEmpty) {
            return _buildEmptyState(context);
          }
          final transactions = _filter == null
              ? allTransactions
              : allTransactions.where((t) => t.type == _filter).toList();

          return ListView(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            children: [
              _FilterRow(
                selected: _filter,
                onSelected: (f) => setState(() => _filter = f),
              ),
              const SizedBox(height: 16),
              if (transactions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      'Tidak ada transaksi untuk filter ini.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                )
              else
                ..._buildGroupedCards(context, transactions, categoriesMap),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }

  List<Widget> _buildGroupedCards(
    BuildContext context,
    List<db.Transaction> transactions,
    Map<int, dynamic> categoriesMap,
  ) {
    final theme = Theme.of(context);
    final groups = <String, List<db.Transaction>>{};
    for (final tx in transactions) {
      groups.putIfAbsent(_groupLabel(tx.date), () => []).add(tx);
    }

    final widgets = <Widget>[];
    groups.forEach((label, txs) {
      widgets.add(
        Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  label,
                  style: AppTypography.mono(
                    fontSize: 12,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                ),
              ),
              for (var i = 0; i < txs.length; i++)
                _TransactionTile(
                  key: ValueKey('transaction_item_${txs[i].id}'),
                  transaction: txs[i],
                  categoryName: txs[i].type == db.TransactionType.transfer
                      ? 'Transfer'
                      : (categoriesMap[txs[i].categoryId]?.name ??
                            'Kategori #${txs[i].categoryId}'),
                  showDivider: i != txs.length - 1,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            TransactionFormScreen(transaction: txs[i]),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      );
    });
    return widgets;
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
                  MaterialPageRoute(
                    builder: (_) => const TransactionFormScreen(),
                  ),
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.onTap,
    required this.showDivider,
  });

  final db.Transaction transaction;
  final String categoryName;
  final VoidCallback onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isExpense = transaction.type == db.TransactionType.expense;
    final isTransfer = transaction.type == db.TransactionType.transfer;
    final amountFormatted = formatRupiah(transaction.amount);
    final timeFormatted = DateFormat('HH:mm').format(transaction.date);

    final color = isTransfer
        ? theme.textTheme.bodySmall?.color
        : (isExpense ? AppColors.expenseRed : AppColors.savingsGreen);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: showDivider
              ? Border(bottom: BorderSide(color: theme.dividerColor))
              : null,
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
                    categoryName,
                    style: AppTypography.mono(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    transaction.notes != null && transaction.notes!.isNotEmpty
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
    );
  }
}
