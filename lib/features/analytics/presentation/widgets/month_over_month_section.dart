import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/analytics_models.dart';
import '../analytics_chart_colors.dart';

/// Widget displaying Month-over-Month (MoM) trend comparison (PRD FR-07).
/// Compares current month's totals (overall and per-category) against the previous month.
class MonthOverMonthSection extends StatelessWidget {
  const MonthOverMonthSection({super.key, required this.summary});

  final MonthOverMonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final currMonthName = summary.currentMonthRange.label;
    final prevMonthName = summary.previousMonthRange.label;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.monthOverMonthSectionTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.monthOverMonthSectionComparisonLabel(
                          currMonthName,
                          prevMonthName,
                        ),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.textTheme.bodySmall?.color?.withValues(
                            alpha: 0.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Legend
                Row(
                  children: [
                    _LegendIndicator(
                      color: AnalyticsChartColors.previousMonthBar(isDark),
                      label: l10n.monthOverMonthSectionLastMonthLegend,
                    ),
                    const SizedBox(width: 12),
                    _LegendIndicator(
                      color: AnalyticsChartColors.currentMonthBar,
                      label: l10n.monthOverMonthSectionThisMonthLegend,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (summary.isEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.monthOverMonthSectionEmptyMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ] else ...[
              // Overall Monthly Comparison Cards
              _OverallComparisonRow(summary: summary),
              const SizedBox(height: 20),

              // Bar Chart Comparison (Side-by-side per category)
              if (summary.categoryComparisons.isNotEmpty) ...[
                Text(
                  l10n.monthOverMonthSectionCategoryComparisonTitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 190,
                  child: _buildComparisonBarChart(
                    context,
                    summary,
                    isDark,
                    theme,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(height: 1),
                const SizedBox(height: 12),

                // Detail per category list
                ...summary.categoryComparisons.map((item) {
                  return _CategoryComparisonRow(item: item);
                }),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonBarChart(
    BuildContext context,
    MonthOverMonthSummary summary,
    bool isDark,
    ThemeData theme,
  ) {
    final l10n = AppLocalizations.of(context)!;
    // Limit chart to top 5 categories for legibility
    final items = summary.categoryComparisons.take(5).toList();
    double maxVal = 0;
    for (final it in items) {
      if (it.currentMonthExpense > maxVal) {
        maxVal = it.currentMonthExpense.toDouble();
      }
      if (it.previousMonthExpense > maxVal) {
        maxVal = it.previousMonthExpense.toDouble();
      }
    }
    final maxY = maxVal > 0 ? maxVal * 1.15 : 100.0;

    return BarChart(
      BarChartData(
        maxY: maxY,
        alignment: BarChartAlignment.spaceAround,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cat = items[group.x.toInt()];
              final isCurrent = rodIndex == 1;
              final amount = isCurrent
                  ? cat.currentMonthExpense
                  : cat.previousMonthExpense;
              final periodName = isCurrent
                  ? l10n.monthOverMonthSectionThisMonthLegend
                  : l10n.monthOverMonthSectionLastMonthLegend;
              return BarTooltipItem(
                l10n.monthOverMonthSectionTooltipLabel(
                  cat.categoryName,
                  periodName,
                  formatRupiah(amount),
                ),
                TextStyle(
                  color: theme.textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= items.length) {
                  return const SizedBox.shrink();
                }
                final name = items[idx].categoryName;
                final shortName = name.length > 6
                    ? '${name.substring(0, 5)}..'
                    : name;
                return SideTitleWidget(
                  meta: meta,
                  space: 4,
                  child: Text(
                    shortName,
                    style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AnalyticsChartColors.gridLineColor(isDark),
            strokeWidth: 1,
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: List.generate(items.length, (i) {
          final item = items[i];
          return BarChartGroupData(
            x: i,
            barsSpace: 4,
            barRods: [
              // Previous Month Bar (muted)
              BarChartRodData(
                toY: item.previousMonthExpense.toDouble(),
                color: AnalyticsChartColors.previousMonthBar(isDark),
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
              // Current Month Bar (brand teal)
              BarChartRodData(
                toY: item.currentMonthExpense.toDouble(),
                color: AnalyticsChartColors.currentMonthBar,
                width: 12,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _OverallComparisonRow extends StatelessWidget {
  const _OverallComparisonRow({required this.summary});

  final MonthOverMonthSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final expDiff = summary.expenseDifference;
    final expPct = summary.expenseChangePercentage;
    final isExpenseUp = expDiff > 0;
    final isExpenseDown = expDiff < 0;

    // For expense: going UP is negative/red, going DOWN is positive/green
    final expenseBadgeColor = isExpenseUp
        ? AppColors.expenseRed
        : (isExpenseDown
              ? AppColors.savingsGreen
              : theme.textTheme.bodySmall?.color);

    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.monthOverMonthSectionExpenseLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(summary.currentMonthExpense),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      isExpenseUp
                          ? Icons.arrow_upward
                          : (isExpenseDown
                                ? Icons.arrow_downward
                                : Icons.remove),
                      size: 12,
                      color: expenseBadgeColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      expPct != null
                          ? '${expDiff >= 0 ? '+' : ''}${expPct.toStringAsFixed(1)}%'
                          : (summary.currentMonthExpense > 0
                                ? l10n.monthOverMonthSectionNewBadge
                                : '0%'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: expenseBadgeColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.scaffoldBackgroundColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.monthOverMonthSectionIncomeLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  formatRupiah(summary.currentMonthIncome),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      summary.incomeDifference > 0
                          ? Icons.arrow_upward
                          : (summary.incomeDifference < 0
                                ? Icons.arrow_downward
                                : Icons.remove),
                      size: 12,
                      color: summary.incomeDifference >= 0
                          ? AppColors.savingsGreen
                          : AppColors.expenseRed,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      summary.incomeChangePercentage != null
                          ? '${summary.incomeDifference >= 0 ? '+' : ''}${summary.incomeChangePercentage!.toStringAsFixed(1)}%'
                          : (summary.currentMonthIncome > 0
                                ? l10n.monthOverMonthSectionNewBadge
                                : '0%'),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: summary.incomeDifference >= 0
                            ? AppColors.savingsGreen
                            : AppColors.expenseRed,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryComparisonRow extends StatelessWidget {
  const _CategoryComparisonRow({required this.item});

  final CategoryMonthComparison item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final diff = item.difference;
    final pct = item.changePercentage;
    final isUp = diff > 0;
    final isDown = diff < 0;

    final diffColor = isUp
        ? AppColors.expenseRed
        : (isDown ? AppColors.savingsGreen : theme.textTheme.bodySmall?.color);

    final color = AnalyticsChartColors.getCategoryColor(
      item.categoryId,
      item.categoryName,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.monthOverMonthSectionPreviousAmountLabel(
                    formatRupiah(item.previousMonthExpense),
                  ),
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 11,
                    color: theme.textTheme.bodySmall?.color?.withValues(
                      alpha: 0.6,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatRupiah(item.currentMonthExpense),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                pct != null
                    ? '${diff >= 0 ? '+' : ''}${pct.toStringAsFixed(1)}%'
                    : (item.currentMonthExpense > 0
                          ? l10n.monthOverMonthSectionNewBadge
                          : '0%'),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: diffColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendIndicator extends StatelessWidget {
  const _LegendIndicator({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall?.copyWith(fontSize: 11)),
      ],
    );
  }
}
