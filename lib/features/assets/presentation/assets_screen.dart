// Assets & Investment tracker list screen (FR-10, DECISIONS.md D8).
// Displays asset portfolio, computed on-the-fly gain/loss, and update interactions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/navigation/slide_page_route.dart';
import '../../../core/presentation/widgets/app_bottom_nav.dart';
import '../../../core/presentation/widgets/dashed_add_card.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/assets_providers.dart';
import 'asset_form_screen.dart';
import 'widgets/asset_card.dart';

class AssetsScreen extends ConsumerWidget {
  const AssetsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(assetsOverviewSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Aset & Investasi',
          style: AppTypography.script(fontSize: 20),
        ),
        actions: [
          IconButton(
            key: const ValueKey('appbar_add_asset_button'),
            tooltip: 'Tambah Aset',
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.of(
                context,
              ).push(SlidePageRoute(builder: (_) => const AssetFormScreen()));
            },
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const AssetsSkeletonList(),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: AppColors.expenseRed,
                ),
                const SizedBox(height: 16),
                Text(
                  'Gagal memuat data aset: $err',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (summary) {
          if (summary.assetCount == 0) {
            return _buildEmptyState(context);
          }
          return _buildAssetsList(context, summary);
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add_asset_fab'),
        onPressed: () {
          Navigator.of(context)
              .push(SlidePageRoute(builder: (_) => const AssetFormScreen()));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(
        key: ValueKey('assets_bottom_nav_bar'),
        currentIndex: 3,
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.brandTeal.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.account_balance_wallet_outlined,
                size: 56,
                color: AppColors.brandTeal,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Belum Ada Aset Terdaftar',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Pantau nilai kekayaan bersih (net-worth) Anda secara mandiri. '
              'Catat aset seperti emas, saham, reksadana, atau kripto dengan pembaruan manual 100% offline.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodyMedium?.color?.withValues(
                  alpha: 0.7,
                ),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              key: const ValueKey('empty_add_asset_button'),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(SlidePageRoute(builder: (_) => const AssetFormScreen()));
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.brandTeal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Tambah Aset Pertama'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsList(BuildContext context, AssetsOverviewSummary summary) {
    final theme = Theme.of(context);
    final isTotalGain = summary.isTotalGain;
    final totalGainColor = isTotalGain
        ? AppColors.savingsGreen
        : AppColors.expenseRed;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      children: [
        // Portfolio Overview Card
        Card(
          elevation: 0,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Portofolio Aset',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.brandTeal.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${summary.assetCount} Aset',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: AppColors.brandTeal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    key: const ValueKey('total_assets_value'),
                    formatRupiah(summary.totalCurrentValue),
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Divider(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Modal Awal',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatRupiah(summary.totalPurchaseValue),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Total Keuntungan',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${isTotalGain ? '+' : ''}${formatRupiah(summary.totalGainLoss)} (${isTotalGain ? '+' : ''}${summary.totalReturnPercentage.toStringAsFixed(1)}%)',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: totalGainColor,
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
        const SizedBox(height: 16),

        // Section Header
        Text(
          'Daftar Aset (${summary.assetCount})',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // List of Asset Cards
        ...summary.items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: AssetCard(item: item),
          ),
        ),
        DashedAddCard(
          key: const ValueKey('assets_dashed_add_card'),
          label: 'Tambah Aset Baru',
          onTap: () {
            Navigator.of(context)
                .push(SlidePageRoute(builder: (_) => const AssetFormScreen()));
          },
        ),
      ],
    );
  }
}
