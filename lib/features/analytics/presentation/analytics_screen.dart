// Main Visual Analytics Screen (FR-07, M8).
// Displays category breakdown (pie/bar), period filter (harian/mingguan/bulanan),
// total expense vs total income ratio, and Month-over-Month (MoM) trend.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/widgets/filter_pill.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../core/theme/app_colors.dart';
import '../application/analytics_providers.dart';
import '../domain/analytics_models.dart';
import 'widgets/analytics_empty_state.dart';
import 'widgets/category_breakdown_card.dart';
import 'widgets/income_expense_ratio_card.dart';
import 'widgets/month_over_month_section.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;

    final periodFilter = ref.watch(periodFilterProvider);
    final summaryAsync = ref.watch(periodAnalyticsSummaryProvider);
    final momAsync = ref.watch(monthOverMonthSummaryProvider);

    return summaryAsync.when(
      loading: () => const AnalyticsSkeletonList(),
      error: (err, _) => Center(
        child: SingleChildScrollView(
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
                l10n.analyticsScreenLoadError(err),
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      data: (summary) {
        return momAsync.when(
          loading: () => const AnalyticsSkeletonList(),
          error: (err, _) =>
              Center(child: Text(l10n.analyticsScreenTrendLoadError(err))),
          data: (momSummary) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
              children: [
                // Period Filter Control
                _PeriodFilterSelector(
                  selectedFilter: periodFilter,
                  onFilterChanged: (filter) {
                    ref.read(periodFilterProvider.notifier).setFilter(filter);
                  },
                ),
                const SizedBox(height: 8),

                // Active Date Range Label
                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : AppColors.lightSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.1),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: AppColors.brandTeal,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          summary.dateRange.label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Empty State or Data Content
                if (summary.isEmpty && momSummary.isEmpty) ...[
                  const AnalyticsEmptyState(
                    key: ValueKey('analytics_empty_state'),
                  ),
                ] else ...[
                  // Total Expense vs Total Income Ratio
                  IncomeExpenseRatioCard(summary: summary),
                  const SizedBox(height: 16),

                  // Category Breakdown (Pie or Bar Chart)
                  CategoryBreakdownCard(summary: summary),
                  const SizedBox(height: 16),

                  // Month-over-Month Trend Comparison
                  MonthOverMonthSection(summary: momSummary),
                ],
              ],
            );
          },
        );
      },
    );
  }
}

class _PeriodFilterSelector extends StatelessWidget {
  const _PeriodFilterSelector({
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final PeriodFilter selectedFilter;
  final ValueChanged<PeriodFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FilterPill(
          label: l10n.analyticsScreenFilterDaily,
          selected: selectedFilter == PeriodFilter.daily,
          onTap: () => onFilterChanged(PeriodFilter.daily),
        ),
        const SizedBox(width: 8),
        FilterPill(
          label: l10n.analyticsScreenFilterWeekly,
          selected: selectedFilter == PeriodFilter.weekly,
          onTap: () => onFilterChanged(PeriodFilter.weekly),
        ),
        const SizedBox(width: 8),
        FilterPill(
          label: l10n.analyticsScreenFilterMonthly,
          selected: selectedFilter == PeriodFilter.monthly,
          onTap: () => onFilterChanged(PeriodFilter.monthly),
        ),
      ],
    );
  }
}
