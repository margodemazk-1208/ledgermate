// Asset item card displaying details, computed gain/loss, and update/edit actions (FR-10).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/presentation/navigation/slide_page_route.dart';
import '../../../../core/presentation/widgets/icon_circle.dart';
import '../../../../core/presentation/widgets/press_scale.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../application/assets_providers.dart';
import '../asset_form_screen.dart';
import 'update_value_dialog.dart';

class AssetCard extends ConsumerWidget {
  const AssetCard({super.key, required this.item});

  final AssetItem item;

  String _formatDateTime(DateTime dt) {
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
  }

  /// Maps the free-text asset type to a representative icon for the
  /// `.icon-circle` badge — purely cosmetic, never used for business logic.
  IconData _iconForType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('emas') || lower.contains('logam')) {
      return Icons.hourglass_bottom;
    }
    if (lower.contains('saham') ||
        lower.contains('reksadana') ||
        lower.contains('investasi')) {
      return Icons.show_chart;
    }
    if (lower.contains('properti') || lower.contains('tanah')) {
      return Icons.home_work_outlined;
    }
    if (lower.contains('kripto')) {
      return Icons.currency_bitcoin;
    }
    return Icons.inventory_2_outlined;
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.assetCardDeleteDialogTitle),
        content: Text(l10n.assetCardDeleteDialogMessage(item.name)),
        actions: [
          TextButton(
            key: const ValueKey('delete_asset_cancel_button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(l10n.assetCardCancelButton),
          ),
          PressScale(
            child: FilledButton(
              key: const ValueKey('delete_asset_confirm_button'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.expenseRed,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(l10n.assetCardDeleteButton),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(assetsRepositoryProvider).deleteAsset(item.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isGain = item.isGain;
    final sign = isGain ? '+' : '';
    final gainColor = isGain
        ? AppColors.savingsGreenText(theme.brightness)
        : AppColors.expenseRedText(theme.brightness);

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Icon, Name, Type Badge, and Actions
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconCircle(icon: _iconForType(item.type), size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        key: ValueKey('asset_name_${item.id}'),
                        item.name,
                        style: AppTypography.script(fontSize: 15),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: theme.dividerColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          item.type,
                          style: theme.textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: ValueKey('edit_asset_button_${item.id}'),
                  tooltip: l10n.assetCardEditTooltip,
                  icon: const Icon(Icons.edit_outlined, size: 20),
                  onPressed: () {
                    Navigator.of(context).push(
                      SlidePageRoute(
                        builder: (_) => AssetFormScreen(asset: item.asset),
                      ),
                    );
                  },
                ),
                PressScale(
                  child: IconButton(
                    key: ValueKey('delete_asset_button_${item.id}'),
                    tooltip: l10n.assetCardDeleteTooltip,
                    icon: const Icon(
                      Icons.delete_outline,
                      size: 20,
                      color: AppColors.expenseRed,
                    ),
                    onPressed: () => _handleDelete(context, ref),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),

            // Values Grid
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.assetCardPurchaseValueLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(item.purchaseValue),
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
                        l10n.assetCardCurrentValueLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formatRupiah(item.currentValue),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Computed Gain/Loss row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: gainColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: gainColor.withValues(alpha: 0.25)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      l10n.assetCardGainLossLabel,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      l10n.assetCardGainLossValue(
                        sign,
                        formatRupiah(item.gainLoss),
                        item.returnPercentage.toStringAsFixed(1),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: gainColor,
                      ),
                      textAlign: TextAlign.right,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Footer: Last updated & Quick Update Value button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    l10n.assetCardLastUpdatedLabel(
                      _formatDateTime(item.lastUpdatedAt),
                    ),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.6,
                      ),
                    ),
                  ),
                ),
                FilledButton.tonalIcon(
                  key: ValueKey('update_value_button_${item.id}'),
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      builder: (_) => UpdateValueDialog(asset: item.asset),
                    );
                  },
                  icon: const Icon(Icons.sync_alt, size: 16),
                  label: Text(l10n.assetCardUpdateValueButton),
                  style: FilledButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
