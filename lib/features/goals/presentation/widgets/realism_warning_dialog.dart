// FR-06b Realism Warning dialog per PRD §7.3 BR-03.
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rupiah_formatter.dart';

enum RealismWarningAction { extendDate, proceed }

/// Dialog triggered when a proposed goal's daily savings allocation pushes
/// Uang Jajan Aman Hari Ini into the negative (FR-06b, BR-03).
///
/// Features the two explicit actions required by PRD BR-03:
/// - "Perpanjang tanggal target"
/// - "Lanjut, saya paham risikonya"
class RealismWarningDialog extends StatelessWidget {
  const RealismWarningDialog({
    super.key,
    required this.projectedUangJajanAman,
    required this.projectedDailyReserve,
  });

  final int projectedUangJajanAman;
  final int projectedDailyReserve;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: AppColors.warningAmber,
            size: 28,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Target Mungkin Terlalu Berat',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jika target ini disimpan, total alokasi tabungan harian Anda menjadi ${formatRupiah(projectedDailyReserve)}/hari.',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Hal ini akan mendorong Uang Jajan Aman Hari Ini ke angka negatif: ${formatRupiah(projectedUangJajanAman)}/hari.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.expenseRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningAmber.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.warningAmber.withValues(alpha: 0.3),
              ),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 18,
                  color: AppColors.warningAmber,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Memperpanjang tanggal target akan menurunkan porsi tabungan harian sehingga anggaran harian tetap aman.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.end,
      actionsOverflowButtonSpacing: 8,
      actions: [
        TextButton(
          key: const ValueKey('realism_extend_date_button'),
          onPressed: () =>
              Navigator.of(context).pop(RealismWarningAction.extendDate),
          child: const Text('Perpanjang tanggal target'),
        ),
        FilledButton(
          key: const ValueKey('realism_proceed_button'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.warningAmber,
            foregroundColor: Colors.black,
          ),
          onPressed: () =>
              Navigator.of(context).pop(RealismWarningAction.proceed),
          child: const Text('Lanjut, saya paham risikonya'),
        ),
      ],
    );
  }
}
