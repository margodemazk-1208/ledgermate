import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(summary.exportedAt);

    return AlertDialog(
      key: const ValueKey('restore_confirmation_dialog'),
      icon: const Icon(
        Icons.warning_amber_rounded,
        color: AppColors.warningAmber,
        size: 40,
      ),
      title: const Text(
        'Konfirmasi Pemulihan Data',
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
                      'PERHATIAN: Pemulihan akan menghapus dan menimpa SELURUH data lokal saat ini. Tindakan ini tidak dapat dibatalkan.',
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
              'Ringkasan Data Cadangan:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(context, 'Waktu Cadangan', formattedDate),
            _buildSummaryRow(
              context,
              'Profil Pengguna',
              summary.hasProfile ? 'Tersedia' : 'Tidak Ada',
            ),
            _buildSummaryRow(
              context,
              'Siklus Gaji',
              '${summary.payCycleCount} data',
            ),
            _buildSummaryRow(
              context,
              'Kategori',
              '${summary.categoryCount} kategori',
            ),
            _buildSummaryRow(
              context,
              'Riwayat Transaksi',
              '${summary.transactionCount} transaksi',
            ),
            _buildSummaryRow(
              context,
              'Target Finansial (Goals)',
              '${summary.goalCount} target',
            ),
            _buildSummaryRow(
              context,
              'Aset / Investasi',
              '${summary.assetCount} aset',
            ),
          ],
        ),
      ),
      actions: [
        OutlinedButton(
          key: const ValueKey('restore_cancel_button'),
          onPressed: onCancel,
          child: const Text('Batal'),
        ),
        FilledButton(
          key: const ValueKey('restore_confirm_button'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.expenseRed,
            foregroundColor: Colors.white,
          ),
          onPressed: onConfirm,
          child: const Text('Timpa & Pulihkan'),
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
