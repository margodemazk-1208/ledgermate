import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../domain/analytics_models.dart';
import '../analytics_chart_colors.dart';

/// Widget displaying expense totals per Category in Pie or Bar chart mode (PRD FR-07).
class CategoryBreakdownCard extends StatefulWidget {
  const CategoryBreakdownCard({super.key, required this.summary});

  final PeriodAnalyticsSummary summary;

  @override
  State<CategoryBreakdownCard> createState() => _CategoryBreakdownCardState();
}

class _CategoryBreakdownCardState extends State<CategoryBreakdownCard> {
  int _touchedIndex = -1;
  bool _showBarChart = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final breakdowns = widget.summary.categoryBreakdowns;
    final totalExpense = widget.summary.totalExpense;

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
                        l10n.categoryBreakdownCardTitle,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        l10n.categoryBreakdownCardTotalLabel(
                          formatRupiah(totalExpense),
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
                IconButton(
                  key: const ValueKey('toggle_chart_type_button'),
                  tooltip: _showBarChart
                      ? l10n.categoryBreakdownCardShowPieTooltip
                      : l10n.categoryBreakdownCardShowBarTooltip,
                  icon: Icon(
                    _showBarChart ? Icons.pie_chart : Icons.bar_chart,
                    size: 20,
                    color: AppColors.brandTeal,
                  ),
                  onPressed: () {
                    setState(() {
                      _showBarChart = !_showBarChart;
                      _touchedIndex = -1;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (breakdowns.isEmpty || totalExpense <= 0) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    l10n.categoryBreakdownCardEmptyMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodySmall?.color?.withValues(
                        alpha: 0.7,
                      ),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Chart visualization
              SizedBox(
                height: 200,
                child: _showBarChart
                    ? _buildBarChart(breakdowns, isDark, theme)
                    : _buildPieChart(breakdowns, isDark, theme),
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Category list with amounts & percentages
              ...breakdowns.map((cat) {
                final color = AnalyticsChartColors.getCategoryColor(
                  cat.categoryId,
                  cat.categoryName,
                );
                return _CategoryBreakdownRow(breakdown: cat, color: color);
              }),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPieChart(
    List<CategoryExpenseBreakdown> breakdowns,
    bool isDark,
    ThemeData theme,
  ) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                _touchedIndex = -1;
                return;
              }
              _touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 36,
        sections: List.generate(breakdowns.length, (i) {
          final cat = breakdowns[i];
          final isTouched = i == _touchedIndex;
          final radius = isTouched ? 56.0 : 48.0;
          final color = AnalyticsChartColors.getCategoryColor(
            cat.categoryId,
            cat.categoryName,
          );

          // Only show percentage on slice if > 9% to prevent crowding
          final showTitle = cat.percentage >= 9.0;
          return PieChartSectionData(
            color: color,
            value: cat.totalExpense.toDouble(),
            title: showTitle ? '${cat.percentage.toStringAsFixed(0)}%' : '',
            radius: radius,
            titleStyle: TextStyle(
              fontSize: isTouched ? 13 : 11,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBarChart(
    List<CategoryExpenseBreakdown> breakdowns,
    bool isDark,
    ThemeData theme,
  ) {
    final maxExpense = breakdowns.first.totalExpense.toDouble();
    final maxY = maxExpense > 0 ? maxExpense * 1.15 : 100.0;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipColor: (_) =>
                isDark ? AppColors.darkSurface : AppColors.lightSurface,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final cat = breakdowns[group.x.toInt()];
              return BarTooltipItem(
                '${cat.categoryName}\n${formatRupiah(cat.totalExpense)} (${cat.percentage.toStringAsFixed(1)}%)',
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
                if (idx < 0 || idx >= breakdowns.length) {
                  return const SizedBox.shrink();
                }
                final name = breakdowns[idx].categoryName;
                final shortName = name.length > 5
                    ? '${name.substring(0, 4)}..'
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
        barGroups: List.generate(breakdowns.length, (i) {
          final cat = breakdowns[i];
          final color = AnalyticsChartColors.getCategoryColor(
            cat.categoryId,
            cat.categoryName,
          );
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: cat.totalExpense.toDouble(),
                color: color,
                width: 16,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(4),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _CategoryBreakdownRow extends StatelessWidget {
  const _CategoryBreakdownRow({required this.breakdown, required this.color});

  final CategoryExpenseBreakdown breakdown;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  breakdown.categoryName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  l10n.categoryBreakdownCardTransactionCountLabel(
                    breakdown.transactionCount,
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
                formatRupiah(breakdown.totalExpense),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${breakdown.percentage.toStringAsFixed(1)}%',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: theme.textTheme.bodySmall?.color?.withValues(
                    alpha: 0.8,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
