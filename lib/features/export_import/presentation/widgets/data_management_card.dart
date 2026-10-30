import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../application/export_import_providers.dart';
import 'restore_confirmation_dialog.dart';

/// UI card managing export and import actions for FR-08.
class DataManagementCard extends ConsumerWidget {
  const DataManagementCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final state = ref.watch(exportImportNotifierProvider);
    final notifier = ref.read(exportImportNotifierProvider.notifier);

    return Card(
      key: const ValueKey('data_management_card'),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.brandTeal.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cloud_sync_outlined,
                    color: AppColors.brandTeal,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dataManagementCardTitle,
                        style: AppTypography.script(fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.dataManagementCardSubtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              l10n.dataManagementCardDescription,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),

            // Status Feedback Banners
            if (state.isLoading) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.brandTeal.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        key: ValueKey('export_import_progress_indicator'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.dataManagementCardProcessingMessage),
                  ],
                ),
              ),
            ],

            if (state.lastExportedPath != null) ...[
              Container(
                key: const ValueKey('export_success_banner'),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.savingsGreen.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.savingsGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppColors.savingsGreen,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.dataManagementCardExportSuccessTitle,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.savingsGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.lastExportedPath!,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (state.errorMessage != null) ...[
              Container(
                key: const ValueKey('export_error_banner'),
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.errorMessage!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.expenseRed,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action 1: Export JSON
            _buildActionTile(
              context: context,
              icon: Icons.data_object_outlined,
              title: l10n.dataManagementCardExportJsonTitle,
              subtitle: l10n.dataManagementCardExportJsonSubtitle,
              buttonKey: const ValueKey('export_json_button'),
              buttonLabel: l10n.dataManagementCardExportJsonButton,
              isLoading: state.isLoading,
              onPressed: () async {
                final path = await notifier.exportJson();
                if (path != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.dataManagementCardExportJsonSuccessToast(path),
                      ),
                    ),
                  );
                }
              },
            ),
            const Divider(height: 28),

            // Action 2: Export CSV
            _buildActionTile(
              context: context,
              icon: Icons.table_chart_outlined,
              title: l10n.dataManagementCardExportCsvTitle,
              subtitle: l10n.dataManagementCardExportCsvSubtitle,
              buttonKey: const ValueKey('export_csv_button'),
              buttonLabel: l10n.dataManagementCardExportCsvButton,
              isLoading: state.isLoading,
              onPressed: () async {
                final path = await notifier.exportCsv();
                if (path != null && context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        l10n.dataManagementCardExportCsvSuccessToast(path),
                      ),
                    ),
                  );
                }
              },
            ),
            const Divider(height: 28),

            // Action 3: Restore JSON
            _buildActionTile(
              context: context,
              icon: Icons.settings_backup_restore_outlined,
              title: l10n.dataManagementCardRestoreTitle,
              subtitle: l10n.dataManagementCardRestoreSubtitle,
              buttonKey: const ValueKey('restore_backup_button'),
              buttonLabel: l10n.dataManagementCardRestoreButton,
              isLoading: state.isLoading,
              isDestructive: true,
              onPressed: () async {
                final backupData = await notifier.pickAndValidateBackup();
                if (backupData != null && context.mounted) {
                  await showDialog<void>(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogCtx) => RestoreConfirmationDialog(
                      summary: backupData.summary,
                      onCancel: () {
                        notifier.cancelPendingRestore();
                        Navigator.of(dialogCtx).pop();
                      },
                      onConfirm: () async {
                        Navigator.of(dialogCtx).pop();
                        final success = await notifier.confirmRestore(
                          backupData,
                        );
                        if (success && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.dataManagementCardRestoreSuccessToast,
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Key buttonKey,
    required String buttonLabel,
    required bool isLoading,
    required VoidCallback onPressed,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.brandTeal),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.75),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: isDestructive
              ? OutlinedButton.icon(
                  key: buttonKey,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandTeal,
                    side: const BorderSide(color: AppColors.brandTeal),
                  ),
                  onPressed: isLoading ? null : onPressed,
                  icon: const Icon(Icons.upload_file_outlined),
                  label: Text(buttonLabel),
                )
              : FilledButton.tonalIcon(
                  key: buttonKey,
                  onPressed: isLoading ? null : onPressed,
                  icon: const Icon(Icons.file_download_outlined),
                  label: Text(buttonLabel),
                ),
        ),
      ],
    );
  }
}
