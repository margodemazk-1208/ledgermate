// Goals list and projection tracker screen (FR-06, FR-06b, FR-06c, BR-03).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/app_bottom_nav.dart';
import '../../../core/presentation/widgets/dashed_add_card.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/rupiah_formatter.dart';
import '../application/goals_providers.dart';
import 'goal_form_screen.dart';
import 'widgets/goal_card.dart';

class GoalsScreen extends ConsumerWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final summaryAsync = ref.watch(goalsOverviewSummaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Target Tabungan',
          style: AppTypography.script(fontSize: 20),
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            key: ValueKey('goals_loading_indicator'),
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
                  'Gagal memuat target tabungan: $err',
                  style: theme.textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        data: (summary) {
          if (summary.goalCount == 0) {
            // Empty state (antislop R-27)
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.brandTeal.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.savings_outlined,
                        size: 56,
                        color: AppColors.brandTeal,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Belum Ada Target Tabungan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Buat target finansial untuk melacak estimasi tercapai dan menyisihkan dana harian secara otomatis.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      key: const ValueKey('create_first_goal_button'),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const GoalFormScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Buat Target Pertama'),
                    ),
                  ],
                ),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 90),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Aggregate overview card
                _GoalsOverviewCard(summary: summary),
                const SizedBox(height: 24),

                // Section header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Daftar Target Aktif (${summary.goalCount})',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                    if (summary.completedCount > 0) ...[
                      Text(
                        '${summary.completedCount} selesai',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.savingsGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),

                // Goals list
                for (final proj in summary.projections)
                  GoalCard(projection: proj),
                const SizedBox(height: 4),
                DashedAddCard(
                  key: const ValueKey('goals_dashed_add_card'),
                  label: 'Tambah Goal Baru',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GoalFormScreen()),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const ValueKey('add_goal_fab'),
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => const GoalFormScreen()));
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
    );
  }
}

class _GoalsOverviewCard extends StatelessWidget {
  const _GoalsOverviewCard({required this.summary});

  final GoalsOverviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final percent = (summary.overallProgress * 100).toInt();

    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.15)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Progres Tabungan',
                  style: AppTypography.script(fontSize: 16),
                ),
                Text(
                  '$percent%',
                  style: AppTypography.mono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.burgundy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: summary.overallProgress,
                minHeight: 8,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.12),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.brandTeal,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _StatColumn(
                  label: 'Terkumpul',
                  value: formatRupiah(summary.totalCurrentAmount),
                  valueColor: AppColors.savingsGreen,
                ),
                _StatColumn(
                  label: 'Total Target',
                  value: formatRupiah(summary.totalTargetAmount),
                ),
                _StatColumn(
                  label: 'Cadangan/Hari',
                  value: '${formatRupiah(summary.totalDailySavingsReserve)}/h',
                  valueColor: AppColors.brandTeal,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? theme.textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }
}
