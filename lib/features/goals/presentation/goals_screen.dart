// Goals list and projection tracker screen (FR-06, FR-06b, FR-06c, BR-03).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../../core/presentation/navigation/slide_page_route.dart';
import '../../../core/presentation/widgets/animated_progress_bar.dart';
import '../../../core/presentation/widgets/dashed_add_card.dart';
import '../../../core/presentation/widgets/skeleton_loader.dart';
import '../../../core/presentation/widgets/slide_fade_in_once.dart';
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
    final l10n = AppLocalizations.of(context)!;
    final summaryAsync = ref.watch(goalsOverviewSummaryProvider);

    return summaryAsync.when(
      loading: () => const GoalsSkeletonList(),
      error: (err, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.expenseRedText(theme.brightness),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.goalsScreenLoadError(err),
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
                      color: theme.dividerColor.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.savings_outlined,
                      size: 56,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    l10n.goalsScreenEmptyTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.goalsScreenEmptyMessage,
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
                        SlidePageRoute(builder: (_) => const GoalFormScreen()),
                      );
                    },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.goalsScreenCreateFirstButton),
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
                  Flexible(
                    child: Text(
                      l10n.goalsScreenActiveListHeader(summary.goalCount),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (summary.completedCount > 0) ...[
                    const SizedBox(width: 8),
                    Text(
                      l10n.goalsScreenCompletedCountLabel(
                        summary.completedCount,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.savingsGreenText(theme.brightness),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),

              // Goals list
              for (final proj in summary.projections)
                SlideFadeInOnce(
                  key: ValueKey('goal_slide_${proj.goal.id}'),
                  child: GoalCard(projection: proj),
                ),
              const SizedBox(height: 4),
              DashedAddCard(
                key: const ValueKey('goals_dashed_add_card'),
                label: l10n.goalsScreenAddGoalCardLabel,
                onTap: () {
                  Navigator.of(context).push(
                    SlidePageRoute(builder: (_) => const GoalFormScreen()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GoalsOverviewCard extends StatelessWidget {
  const _GoalsOverviewCard({required this.summary});

  final GoalsOverviewSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
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
                Flexible(
                  child: Text(
                    l10n.goalsOverviewCardTitle,
                    style: AppTypography.script(fontSize: 16),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percent%',
                  style: AppTypography.mono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    // M19/D18 contrast fix: see AppColors.burgundyText doc.
                    color: AppColors.burgundyText(theme.brightness),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AnimatedProgressBar(
                value: summary.overallProgress,
                minHeight: 8,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.12),
                valueColor: AppColors.brandTeal,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _StatColumn(
                    label: l10n.goalsOverviewCardCollectedLabel,
                    value: formatRupiah(summary.totalCurrentAmount),
                    valueColor: AppColors.savingsGreenText(theme.brightness),
                  ),
                ),
                Expanded(
                  child: _StatColumn(
                    label: l10n.goalsOverviewCardTargetLabel,
                    value: formatRupiah(summary.totalTargetAmount),
                  ),
                ),
                Expanded(
                  // M19/D18: "Cadangan/Hari" is a plain data figure, not a
                  // brand/action moment — dropped the burgundy color-coding
                  // here (part of the Goals-screen burgundy-overuse fix),
                  // it now reads in the default body text color like
                  // "Total Target" next to it.
                  child: _StatColumn(
                    label: l10n.goalsOverviewCardDailyReserveLabel,
                    value:
                        '${formatRupiah(summary.totalDailySavingsReserve)}/h',
                  ),
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
        Text(
          label,
          style: theme.textTheme.bodySmall,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: valueColor ?? theme.textTheme.bodyMedium?.color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
