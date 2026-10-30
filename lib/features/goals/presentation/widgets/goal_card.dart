// Goal item card displaying progress, estimated completion, and actions (FR-06, FR-06c).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/presentation/navigation/slide_page_route.dart';
import '../../../../core/presentation/widgets/animated_progress_bar.dart';
import '../../../../core/presentation/widgets/press_scale.dart';
import '../../../../core/utils/rupiah_formatter.dart';
import '../../application/goals_providers.dart';
import '../goal_form_screen.dart';
import 'withdraw_dialog.dart';

class GoalCard extends ConsumerWidget {
  const GoalCard({super.key, required this.projection});

  final GoalProjection projection;

  String _formatDate(DateTime date) {
    return DateFormat('d MMM yyyy', 'id_ID').format(date);
  }

  Future<void> _handleDelete(BuildContext context, WidgetRef ref) async {
    final goal = projection.goal;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Target?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus target "${goal.goalName}"? '
          'Tindakan ini tidak dapat dibatalkan.',
        ),
        actions: [
          TextButton(
            key: const ValueKey('delete_confirm_cancel_button'),
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          PressScale(
            child: FilledButton(
              key: const ValueKey('delete_confirm_submit_button'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.expenseRed,
              ),
              onPressed: () => Navigator.of(ctx).pop(true),
              child: const Text('Hapus'),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(goalsRepositoryProvider).deleteGoal(goal.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final goal = projection.goal;
    final isCompleted = projection.isCompleted;
    final percentInt = (projection.progressPercent * 100).toInt();

    return Card(
      key: ValueKey('goal_card_${goal.id}'),
      margin: const EdgeInsets.only(bottom: 16),
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
            // Header row: Title + badges
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.goalName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Target: ${_formatDate(goal.targetDate)}',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (isCompleted) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.savingsGreenText(theme.brightness)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.savingsGreenText(theme.brightness)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: AppColors.savingsGreenText(theme.brightness),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Tercapai',
                          style: TextStyle(
                            color: AppColors.savingsGreenText(theme.brightness),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else if (goal.manualDailyAllocation != null) ...[
                  // M19/D18: "Override Manual" is informational, not a
                  // brand/action moment — pulled the burgundy tint per
                  // docs/DESIGN.md's "~10-15% of visible area" guidance
                  // (every goal card showing this badge in burgundy was
                  // part of the Goals-screen overuse the audit flagged).
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.dividerColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Override Manual',
                      style: TextStyle(
                        color: theme.textTheme.bodySmall?.color,
                        fontWeight: FontWeight.w600,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar and amounts
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    formatRupiah(goal.currentAmount),
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isCompleted
                          ? AppColors.savingsGreenText(theme.brightness)
                          : theme.textTheme.titleSmall?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    '${formatRupiah(goal.targetAmount)} ($percentInt%)',
                    style: theme.textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.end,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: AnimatedProgressBar(
                key: ValueKey('goal_progress_bar_${goal.id}'),
                value: projection.progressPercent,
                minHeight: 8,
                backgroundColor: theme.dividerColor.withValues(alpha: 0.12),
                valueColor: isCompleted
                    ? AppColors.savingsGreen
                    : AppColors.brandTeal,
              ),
            ),
            const SizedBox(height: 14),

            // Projection info row
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.3,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  // M19/D18: pulled burgundy off this purely decorative
                  // icon — part of the Goals-screen burgundy-overuse fix
                  // (every goal card repeated this icon).
                  Icon(
                    Icons.trending_up,
                    size: 16,
                    color: theme.textTheme.bodySmall?.color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isCompleted
                          ? 'Target telah terpenuhi sepenuhnya!'
                          : projection.estimatedCompletionDate != null
                          ? 'Estimasi tercapai: ${_formatDate(projection.estimatedCompletionDate!)}'
                          : 'Belum ada estimasi (alokasi 0)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Flexible(
                    child: Text(
                      isCompleted
                          ? 'Selesai'
                          : '${formatRupiah(projection.dailyAllocation)}/hari',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.savingsGreenText(theme.brightness),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Actions row (R-26: every interactive element has real behavior)
            // Two full-width pill actions per 04_goals.html: outlined
            // "Tarik dari Goal" + filled burgundy "Edit".
            Row(
              children: [
                Expanded(
                  child: PressScale(
                    enabled: goal.currentAmount > 0,
                    child: OutlinedButton(
                      key: ValueKey('withdraw_goal_button_${goal.id}'),
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      onPressed: goal.currentAmount > 0
                          ? () {
                              showDialog(
                                context: context,
                                builder: (_) => WithdrawDialog(goal: goal),
                              );
                            }
                          : null,
                      child: const Text('Tarik dari Goal'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    key: ValueKey('edit_goal_button_${goal.id}'),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.burgundy,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        SlidePageRoute(
                          builder: (_) => GoalFormScreen(goal: goal),
                        ),
                      );
                    },
                    child: const Text('Edit'),
                  ),
                ),
                PressScale(
                  child: IconButton(
                    key: ValueKey('delete_goal_button_${goal.id}'),
                    tooltip: 'Hapus Target',
                    color: AppColors.expenseRedText(theme.brightness),
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () => _handleDelete(context, ref),
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
