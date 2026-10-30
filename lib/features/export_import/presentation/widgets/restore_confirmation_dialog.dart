import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/backup_data.dart';

/// Confirmation dialog shown before executing a destructive database restore (FR-08).
class RestoreConfirmationDialog extends StatelessWidget {
  const RestoreConfirmationDialog({
    super.key,
    required this.summary,
    required this.onConfirm,
    required this.onCancel,
  });

  final BackupSummary summary;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(summary.exportedAt);

    return AlertDialog(
      key: const ValueKey('restore_confirmation_dialog'),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.warningAmber,
        size: 40,
      ),
      title: Text(
        l10n.restoreConfirmationDialogTitle,
        textAlign: TextAlign.center,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.expenseRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.expenseRed.withValues(alpha: 0.4),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.expenseRed,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.restoreConfirmationDialogWarningMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.expenseRed,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.restoreConfirmationDialogSummaryTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              l10n.restoreConfirmationDialogBackupTimeLabel,
              formattedDate,
            ),
            _buildSummaryRow(
              context,
              l10n.restoreConfirmationDialogUserProfileLabel,
              summary.hasProfile
                  ? l10n.restoreConfirmationDialogAvailableValue
                  : l10n.restoreConfirmationDialogNotAvailableValue,
            ),
            _buildSummaryRow(
              context,
              l10n.restoreConfirmationDialogPayCycleLabel,
              l10n.restoreConfirmationDialogPayCycleCountValue(
                summary.payCycleCount,
              ),
            ),
            _buildSummaryRow(
              context,
              l10n.restoreConfirmationDialogCategoryLabel,
              l10n.restoreConfirmationDialogCategoryCountValue(
                summary.categoryCount,
              ),
            ),
            _buildSummaryRow(
              context,
              l10n.restoreConfirmationDialogTransactionLabel,
              l10n.restoreConfirmationDialogTransactionCountValue(
                summary.transactionCount,
              ),
            ),
            _buildSummaryRow(
              context,
              l10n.restoreConfirmationDialogGoalLabel,
              l10n.restoreConfirmationDialogGoalCountValue(summary.goalCount),
            ),
            _buildSummaryRow(
              context,
              l10n.restoreConfirmationDialogAssetLabel,
              l10n.restoreConfirmationDialogAssetCountValue(summary.assetCount),
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          key: const ValueKey('restore_cancel_button'),
          onPressed: onCancel,
          child: Text(l10n.restoreConfirmationDialogCancelButton),
        ),
        FilledButton(
          key: const ValueKey('restore_confirm_button'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.expenseRed,
            foregroundColor: Colors.white,
          ),
          onPressed: onConfirm,
          child: Text(l10n.restoreConfirmationDialogConfirmButton),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
