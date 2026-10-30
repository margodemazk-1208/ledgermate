// Assets & Investment tracker list screen (FR-10, DECISIONS.md D8).
// Displays asset portfolio, computed on-the-fly gain/loss, and update interactions.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/navigation/slide_page_route.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(assetsOverviewSummaryProvider);

    return summaryAsync.when(
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
                l10n.assetsScreenLoadError(err),
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
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
              l10n.assetsScreenEmptyTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.assetsScreenEmptyMessage,
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
              label: Text(l10n.assetsScreenAddFirstButton),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssetsList(BuildContext context, AssetsOverviewSummary summary) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isTotalGain = summary.isTotalGain;
    final totalGainColor = isTotalGain
        ? AppColors.savingsGreenText(theme.brightness)
        : AppColors.expenseRedText(theme.brightness);
    final sign = isTotalGain ? '+' : '';

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
                    Flexible(
                      child: Text(
                        l10n.assetsScreenPortfolioTotalLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        // M19/D18: pulled the burgundy tint on this purely
                        // decorative count badge — `05_aset.html`'s overview
                        // card has no such badge at all, and burgundy is
                        // meant for deliberate accent moments, not every
                        // small label (docs/DESIGN.md §Palette).
                        color: theme.dividerColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.assetsScreenAssetCountBadge(summary.assetCount),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color,
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
                    // M19/D18 font-rule fix: numeric data uses Space Mono,
                    // not the Playfair-backed `headlineMedium` style.
                    style: AppTypography.mono(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: theme.textTheme.headlineMedium?.color,
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
                            l10n.assetsScreenTotalPurchaseLabel,
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
                            l10n.assetsScreenTotalGainLabel,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.assetsScreenGainLossSummary(
                              sign,
                              formatRupiah(summary.totalGainLoss),
                              summary.totalReturnPercentage.toStringAsFixed(1),
                            ),
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
          l10n.assetsScreenListHeader(summary.assetCount),
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
          label: l10n.assetsScreenAddCardLabel,
          onTap: () {
            Navigator.of(context)
                .push(SlidePageRoute(builder: (_) => const AssetFormScreen()));
          },
        ),
      ],
    );
  }
}
