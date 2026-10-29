import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/database/transaction.dart' as db;
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/transaction_providers.dart';
import 'transaction_form_screen.dart';

/// Screen displaying a reverse-chronological list of transactions (FR-02, FR-03),
/// with an add button and tap-to-edit interactions.
class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsStreamProvider);
    final categoriesMap = ref.watch(categoriesMapProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Transaksi')),
      body: transactionsAsync.when(
        data: (transactions) {
          if (transactions.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              return _TransactionTile(
                key: ValueKey('transaction_item_${tx.id}'),
                transaction: tx,
                categoryName: tx.type == db.TransactionType.transfer
                    ? 'Transfer'
                    : (categoriesMap[tx.categoryId]?.name ??
                          'Kategori #${tx.categoryId}'),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => TransactionFormScreen(transaction: tx),
                    ),
                  );
                },
              );
            },
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
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('add_transaction_fab'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Transaksi'),
      ),
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

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    super.key,
    required this.transaction,
    required this.categoryName,
    required this.onTap,
  });

  final db.Transaction transaction;
  final String categoryName;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == db.TransactionType.expense;
    final isTransfer = transaction.type == db.TransactionType.transfer;
    final amountFormatted = formatRupiah(transaction.amount);
    final dateFormatted = DateFormat('d MMM yyyy').format(transaction.date);

    final color = isTransfer
        ? AppColors.brandTeal
        : (isExpense ? AppColors.expenseRed : AppColors.savingsGreen);

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(
          isTransfer
              ? Icons.swap_horiz
              : (isExpense ? Icons.arrow_upward : Icons.arrow_downward),
          color: color,
          size: 20,
        ),
      ),
      title: Text(categoryName, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(
        transaction.notes != null && transaction.notes!.isNotEmpty
            ? '$dateFormatted • ${transaction.notes}'
            : dateFormatted,
        style: Theme.of(context).textTheme.bodyMedium,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Text(
        '${isTransfer ? '⇄ ' : (isExpense ? '- ' : '+ ')}$amountFormatted',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: color,
        ),
      ),
    );
  }
}
