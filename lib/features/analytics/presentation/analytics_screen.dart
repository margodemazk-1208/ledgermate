// Main Visual Analytics Screen (FR-07, M8).
// Displays category breakdown (pie/bar), period filter (harian/mingguan/bulanan),
// total expense vs total income ratio, and Month-over-Month (MoM) trend.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../transactions/presentation/transaction_form_screen.dart';
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
    final isDark = theme.brightness == Brightness.dark;

    final periodFilter = ref.watch(periodFilterProvider);
    final summaryAsync = ref.watch(periodAnalyticsSummaryProvider);
    final momAsync = ref.watch(monthOverMonthSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visual Analitik'),
        actions: [
          IconButton(
            key: const ValueKey('analytics_theme_toggle_button'),
            tooltip: isDark
                ? 'Beralih ke mode terang'
                : 'Beralih ke mode gelap',
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              ref
                  .read(themeModeProvider.notifier)
                  .set(isDark ? ThemeMode.light : ThemeMode.dark);
            },
          ),
        ],
      ),
      body: summaryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('analytics_loading_indicator'),
          ),
        ),
        error: (err, _) => Center(
          child: Padding(
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
                  'Gagal memuat analitik: $err',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (summary) {
          return momAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(
                key: ValueKey('analytics_mom_loading_indicator'),
              ),
            ),
            error: (err, _) => Center(child: Text('Gagal memuat tren: $err')),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const ValueKey('analytics_add_transaction_fab'),
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TransactionFormScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Catat Transaksi'),
      ),
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
    return Center(
      child: SegmentedButton<PeriodFilter>(
        key: const ValueKey('analytics_period_segmented_button'),
        segments: const [
          ButtonSegment(
            value: PeriodFilter.daily,
            label: Text('Harian'),
            icon: Icon(Icons.today, size: 16),
          ),
          ButtonSegment(
            value: PeriodFilter.weekly,
            label: Text('Mingguan'),
            icon: Icon(Icons.view_week_outlined, size: 16),
          ),
          ButtonSegment(
            value: PeriodFilter.monthly,
            label: Text('Bulanan'),
            icon: Icon(Icons.calendar_month_outlined, size: 16),
          ),
        ],
        selected: {selectedFilter},
        onSelectionChanged: (newSelection) {
          if (newSelection.isNotEmpty) {
            onFilterChanged(newSelection.first);
          }
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
