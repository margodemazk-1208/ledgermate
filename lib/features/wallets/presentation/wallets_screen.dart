import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/wallet.dart';
import '../../../core/presentation/widgets/icon_circle.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/wallet_providers.dart';
import '../data/wallet_repository.dart';
import '../utils/wallet_icons.dart';
import 'transfer_form_screen.dart';
import 'wallet_form_screen.dart';

/// Multi-Wallet Management Screen (FR-12, FR-13, D16).
class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Dompet?'),
        content: Text(
          'Apakah kamu yakin ingin menghapus dompet "${wallet.name}"?\n\n'
          'Catatan: Dompet tidak dapat dihapus jika masih memiliki transaksi atau transfer terkait (FR-12).',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.expenseRed,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        await ref.read(walletRepositoryProvider).deleteWallet(wallet.id);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dompet "${wallet.name}" berhasil dihapus.'),
              backgroundColor: AppColors.savingsGreen,
            ),
          );
        }
      } on WalletDeleteRestrictedException catch (e) {
        if (context.mounted) {
          _showErrorDialog(context, 'Hapus Ditolak', e.message);
        }
      } on WalletHasTransactionsException catch (e) {
        if (context.mounted) {
          _showErrorDialog(context, 'Hapus Ditolak', e.message);
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog(context, 'Gagal Menghapus Dompet', e.toString());
        }
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.error_outline,
          color: AppColors.expenseRed,
          size: 36,
        ),
        title: Text(title),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Mengerti'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final walletsAsync = ref.watch(walletsStreamProvider);
    final balancesAsync = ref.watch(walletBalancesProvider);
    final totalSaldoAsync = ref.watch(totalSaldoProvider);

    final balances = balancesAsync.value ?? const <int, int>{};
    final totalSaldo = totalSaldoAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Dompet', style: AppTypography.script(fontSize: 20)),
        actions: [
          IconButton(
            key: const ValueKey('wallets_transfer_appbar_button'),
            tooltip: 'Transfer Antar Dompet',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TransferFormScreen()),
              );
            },
          ),
        ],
      ),
      body: walletsAsync.when(
        data: (wallets) {
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            children: [
              // 1. Total Saldo Card (Net Worth)
              Card(
                key: const ValueKey('wallets_total_saldo_card'),
                elevation: 0,
                color: theme.colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: theme.dividerColor.withValues(alpha: 0.15),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Saldo (Kekayaan Bersih)',
                        style: AppTypography.mono(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatRupiah(totalSaldo),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.burgundy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total akumulasi dari ${wallets.length} dompet & rekening aktif.',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              key: const ValueKey(
                                'wallets_quick_transfer_button',
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const TransferFormScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.swap_horiz, size: 18),
                              label: const Text('Transfer'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FilledButton.icon(
                              key: const ValueKey('wallets_quick_add_button'),
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.burgundy,
                              ),
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const WalletFormScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: const Text('Tambah'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. Section Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Daftar Dompet (${wallets.length})',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (wallets.isEmpty) ...[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 48,
                          color: AppColors.brandTeal,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada dompet terdaftar.',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tambahkan dompet pertamamu untuk mulai mencatat.',
                          style: theme.textTheme.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                for (final w in wallets) ...[
                  _WalletItemCard(
                    key: ValueKey('wallet_card_${w.id}'),
                    wallet: w,
                    balance: balances[w.id] ?? w.startingBalance,
                    onEdit: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => WalletFormScreen(wallet: w),
                        ),
                      );
                    },
                    onDelete: () => _confirmDelete(context, ref, w),
                    onTransfer: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              TransferFormScreen(initialSourceWalletId: w.id),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                ],
              ],
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('wallets_loading_indicator'),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'Gagal memuat daftar dompet: $err',
              style: const TextStyle(color: AppColors.expenseRed),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add_wallet_fab'),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const WalletFormScreen()));
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WalletItemCard extends StatelessWidget {
  const _WalletItemCard({
    super.key,
    required this.wallet,
    required this.balance,
    required this.onEdit,
    required this.onDelete,
    required this.onTransfer,
  });

  final Wallet wallet;
  final int balance;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTransfer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Wallet Icon container
              IconCircle(
                icon: getWalletIcon(wallet.icon),
                size: 48,
                color: AppColors.burgundy,
                background: AppColors.burgundy.withValues(alpha: 0.12),
              ),
              const SizedBox(width: 14),

              // Name + Budget status badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: AppTypography.script(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: wallet.includeInDailyBudget
                                ? AppColors.brandTeal.withValues(alpha: 0.1)
                                : theme.dividerColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            wallet.includeInDailyBudget
                                ? 'Ikut Budget Harian'
                                : 'Di luar Budget',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: wallet.includeInDailyBudget
                                  ? AppColors.brandTeal
                                  : theme.textTheme.bodySmall?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Balance + Actions
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatRupiah(balance),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Saldo saat ini',
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(width: 4),

              // Popup Menu for actions
              PopupMenuButton<String>(
                key: ValueKey('wallet_menu_${wallet.id}'),
                icon: const Icon(Icons.more_vert, size: 20),
                onSelected: (val) {
                  if (val == 'transfer') {
                    onTransfer();
                  } else if (val == 'edit') {
                    onEdit();
                  } else if (val == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (ctx) => [
                  const PopupMenuItem(
                    value: 'transfer',
                    child: Row(
                      children: [
                        Icon(Icons.swap_horiz, size: 18),
                        SizedBox(width: 8),
                        Text('Transfer'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 18),
                        SizedBox(width: 8),
                        Text('Edit Dompet'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.expenseRed,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Hapus',
                          style: TextStyle(color: AppColors.expenseRed),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
