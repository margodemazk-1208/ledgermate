import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/navigation/slide_page_route.dart';
import '../../../transactions/presentation/transaction_form_screen.dart';

/// Empty state widget per AGENTS.md antislop R-27:
/// Clear, informative state with an actionable CTA instead of a blank/broken chart.
class AnalyticsEmptyState extends StatelessWidget {
  const AnalyticsEmptyState({
    super.key,
    this.message = 'Belum ada transaksi pada periode ini.',
    this.submessage = 'Catat pengeluaran atau pemasukan untuk melihat visualisasi grafik dan tren keuangan.',
  });

  final String message;
  final String submessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: theme.dividerColor.withValues(alpha: 0.15),
                ),
              ),
              child: const Icon(
                Icons.pie_chart_outline,
                size: 36,
                color: AppColors.brandTeal,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              submessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              key: const ValueKey('analytics_empty_catat_button'),
              onPressed: () {
                Navigator.of(context).push(
                  SlidePageRoute(builder: (_) => const TransactionFormScreen()),
                );
              },
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Catat Transaksi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandTeal,
                side: const BorderSide(color: AppColors.brandTeal),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
