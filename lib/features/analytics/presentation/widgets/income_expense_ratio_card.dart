import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/analytics_models.dart';
import '../analytics_chart_colors.dart';

/// Card displaying total income, total expense, net savings, and expense-to-income ratio
/// for the selected period (PRD FR-07).
class IncomeExpenseRatioCard extends StatelessWidget {
  const IncomeExpenseRatioCard({super.key, required this.summary});

  final PeriodAnalyticsSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final totalIncome = summary.totalIncome;
    final totalExpense = summary.totalExpense;
    final netBalance = summary.netBalance;
    final isPositiveNet = netBalance >= 0;
    final ratio = summary.expenseToIncomeRatio;

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ringkasan Keuangan Periode',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            // Income & Expense Metrics
            Row(
              children: [
                Expanded(
                  child: _MetricItem(
                    label: 'Total Pemasukan',
                    amount: totalIncome,
                    amountColor: AnalyticsChartColors.incomeColor,
                    icon: Icons.arrow_downward_rounded,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: theme.dividerColor.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: _MetricItem(
                    label: 'Total Pengeluaran',
                    amount: totalExpense,
                    amountColor: AnalyticsChartColors.expenseColor,
                    icon: Icons.arrow_upward_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Net Balance & Ratio
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Tabungan Bersih',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${isPositiveNet ? '+' : ''}${formatRupiah(netBalance)}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isPositiveNet
                            ? AnalyticsChartColors.incomeColor
                            : AnalyticsChartColors.expenseColor,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Rasio Pengeluaran',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(
                          alpha: 0.7,
                        ),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ratio != null
                          ? '${(ratio * 100).toStringAsFixed(1)}%'
                          : totalExpense > 0
                          ? '> 100%'
                          : '0%',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color:
                            (ratio != null && ratio > 1.0) ||
                                (ratio == null && totalExpense > 0)
                            ? AppColors.expenseRed
                            : AppColors.brandTeal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Visual Ratio Progress Bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: _buildRatioBar(totalIncome, totalExpense, ratio),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatioBar(int income, int expense, double? ratio) {
    if (income <= 0 && expense <= 0) {
      return Container(color: Colors.grey.withValues(alpha: 0.2));
    }
    if (income <= 0 && expense > 0) {
      return Container(color: AnalyticsChartColors.expenseColor);
    }
    if (expense <= 0 && income > 0) {
      return Container(color: AnalyticsChartColors.incomeColor);
    }

    final total = income + expense;
    final expenseFlex = ((expense / total) * 100).round().clamp(1, 99);
    final incomeFlex = 100 - expenseFlex;

    return Row(
      children: [
        Expanded(
          flex: expenseFlex,
          child: Container(color: AnalyticsChartColors.expenseColor),
        ),
        Expanded(
          flex: incomeFlex,
          child: Container(color: AnalyticsChartColors.incomeColor),
        ),
      ],
    );
  }
}

class _MetricItem extends StatelessWidget {
  const _MetricItem({
    required this.label,
    required this.amount,
    required this.amountColor,
    required this.icon,
  });

  final String label;
  final int amount;
  final Color amountColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: amountColor),
              const SizedBox(width: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.7,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            formatRupiah(amount),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
