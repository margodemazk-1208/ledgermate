import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/wallet.dart';
import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/navigation/slide_page_route.dart';
import '../../../core/presentation/widgets/icon_circle.dart';
import '../../../core/presentation/widgets/press_scale.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.walletsScreenDeleteDialogTitle),
        content: Text(l10n.walletsScreenDeleteDialogMessage(wallet.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.walletsScreenCancelButton),
          ),
          PressScale(
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.expenseRed,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.walletsScreenDeleteButton),
            ),
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
              content: Text(l10n.walletsScreenDeleteSuccessToast(wallet.name)),
              backgroundColor: AppColors.savingsGreen,
            ),
          );
        }
      } on WalletDeleteRestrictedException catch (e) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            l10n.walletsScreenDeleteRejectedTitle,
            e.message,
          );
        }
      } on WalletHasTransactionsException catch (e) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            l10n.walletsScreenDeleteRejectedTitle,
            e.message,
          );
        }
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            l10n.walletsScreenDeleteFailedTitle,
            e.toString(),
          );
        }
      }
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    final l10n = AppLocalizations.of(context)!;
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
            child: Text(l10n.walletsScreenUnderstoodButton),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final walletsAsync = ref.watch(walletsStreamProvider);
    final balancesAsync = ref.watch(walletBalancesProvider);
    final totalSaldoAsync = ref.watch(totalSaldoProvider);

    final balances = balancesAsync.value ?? const <int, int>{};
    final totalSaldo = totalSaldoAsync.value ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.walletsScreenTitle,
          style: AppTypography.script(fontSize: 20),
        ),
        actions: [
          IconButton(
            key: const ValueKey('wallets_transfer_appbar_button'),
            tooltip: l10n.walletsScreenTransferTooltip,
            icon: const Icon(Icons.swap_horiz),
            onPressed: () {
              Navigator.of(context).push(
                SlidePageRoute(builder: (_) => const TransferFormScreen()),
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
                        l10n.walletsScreenTotalBalanceLabel,
                        style: AppTypography.mono(
                          fontSize: 13,
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        formatRupiah(totalSaldo),
                        // M19/D18 font-rule fix: this is numeric data, so it
                        // must use Space Mono (AppTypography.mono), not the
                        // Playfair-backed `headlineMedium` text style — see
                        // docs/DESIGN.md's typography rule (display/script
                        // for brand+labels, mono for ALL numeric/data text).
                        style: AppTypography.mono(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          // M19/D18 contrast fix: see AppColors.burgundyText
                          // doc — this is the one deliberate focal-number
                          // accent moment on this screen (parallels Home's
                          // identity motif), kept, just lightened for dark
                          // mode.
                          color: AppColors.burgundyText(theme.brightness),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.walletsScreenTotalBalanceSubtitle(wallets.length),
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
                                  SlidePageRoute(
                                    builder: (_) => const TransferFormScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.swap_horiz, size: 18),
                              label: Text(l10n.walletsScreenTransferButton),
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
                                  SlidePageRoute(
                                    builder: (_) => const WalletFormScreen(),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.add, size: 18),
                              label: Text(l10n.walletsScreenAddButton),
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
                    l10n.walletsScreenListTitle(wallets.length),
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
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          size: 48,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.walletsScreenEmptyTitle,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          l10n.walletsScreenEmptyMessage,
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
                        SlidePageRoute(
                          builder: (_) => WalletFormScreen(wallet: w),
                        ),
                      );
                    },
                    onDelete: () => _confirmDelete(context, ref, w),
                    onTransfer: () {
                      Navigator.of(context).push(
                        SlidePageRoute(
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
              l10n.walletsScreenLoadError(err),
              style: TextStyle(
                color: AppColors.expenseRedText(theme.brightness),
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add_wallet_fab'),
        onPressed: () {
          Navigator.of(context)
              .push(SlidePageRoute(builder: (_) => const WalletFormScreen()));
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
    final l10n = AppLocalizations.of(context)!;

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
              // M19/D18: pulled the burgundy tint — every wallet card
              // using it made Wallets the clearest case of the "accent
              // used too heavily" audit finding (docs/DESIGN.md's
              // ~10-15%-of-visible-area guidance). Matches the neutral
              // icon-circle treatment already used for Asset cards.
              IconCircle(icon: getWalletIcon(wallet.icon), size: 48),
              const SizedBox(width: 14),

              // Name + Budget status badge
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      wallet.name,
                      style: AppTypography.script(fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              // M19/D18: "included in budget" is status
                              // information, not a brand/action moment —
                              // uses the semantic green (positive/active),
                              // not the burgundy accent.
                              color: wallet.includeInDailyBudget
                                  ? AppColors.savingsGreenText(theme.brightness)
                                        .withValues(alpha: 0.12)
                                  : theme.dividerColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              wallet.includeInDailyBudget
                                  ? l10n.walletCardIncludedInBudgetBadge
                                  : l10n.walletCardExcludedFromBudgetBadge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: wallet.includeInDailyBudget
                                    ? AppColors.savingsGreenText(
                                        theme.brightness,
                                      )
                                    : theme.textTheme.bodySmall?.color,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
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
                    // M19/D18 font-rule fix: numeric data uses Space Mono,
                    // not the Playfair-backed `titleMedium` style.
                    style: AppTypography.mono(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.walletCardCurrentBalanceLabel,
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
                  PopupMenuItem(
                    value: 'transfer',
                    child: Row(
                      children: [
                        const Icon(Icons.swap_horiz, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.walletCardTransferMenuItem),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text(l10n.walletCardEditMenuItem),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline,
                          size: 18,
                          color: AppColors.expenseRedText(theme.brightness),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          l10n.walletCardDeleteMenuItem,
                          style: TextStyle(
                            color: AppColors.expenseRedText(theme.brightness),
                          ),
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
