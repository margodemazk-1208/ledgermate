// Riverpod providers and domain helpers for M6 Goals & Projection Tracker
// (FR-06, FR-06b, FR-06c, BR-03).
import 'dart:math' as math;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/financial_goal.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/formulas/daily_budget_formulas.dart';
import '../../budget_engine/application/budget_providers.dart';
import '../../notifications/application/goal_notification_hook.dart';
import '../data/goals_repository.dart';

final goalsRepositoryProvider = Provider<GoalsRepositoryBase>((ref) {
  return GoalsRepository(
    ref.watch(isarProvider),
    ref.watch(goalNotificationHookProvider),
  );
});

final goalsStreamProvider = StreamProvider<List<FinancialGoal>>((ref) {
  return ref.watch(goalsRepositoryProvider).watchGoals();
});

/// Encapsulates projection metrics for a single [FinancialGoal] (FR-06).
class GoalProjection {
  const GoalProjection({
    required this.goal,
    required this.progressPercent,
    required this.dailyAllocation,
    required this.estimatedCompletionDate,
    required this.isCompleted,
    required this.isOverdue,
    required this.daysRemainingToTargetDate,
    required this.remainingAmount,
  });

  factory GoalProjection.fromGoal(
    FinancialGoal goal, {
    DateTime? referenceNow,
  }) {
    return computeGoalProjection(
      goal: goal,
      today: referenceNow ?? DateTime.now(),
    );
  }

  final FinancialGoal goal;

  /// Clamped progress ratio between 0.0 and 1.0.
  final double progressPercent;

  /// Daily amount allocated towards this goal by formula engine.
  final int dailyAllocation;

  /// Estimated calendar date when the goal will be reached based on the
  /// daily savings rate (FR-06). Null if no daily rate is active and goal is unfulfilled.
  final DateTime? estimatedCompletionDate;

  final bool isCompleted;
  final bool isOverdue;
  final int daysRemainingToTargetDate;
  final int remainingAmount;

  int get remainingDays => daysRemainingToTargetDate;
}

/// Pure helper calculating goal progress and projected completion date (FR-06).
///
/// Projection methodology:
/// - If `currentAmount >= targetAmount`, the goal is already achieved (completion date is today).
/// - If `manualDailyAllocation` is set and > 0, the user saves that exact fixed rate per day;
///   estimated days needed = `ceil((targetAmount - currentAmount) / manualDailyAllocation)`.
/// - Otherwise, the auto-computed allocation `calculateGoalDailyAllocation` is used;
///   estimated days needed = `ceil((targetAmount - currentAmount) / dailyAllocation)`.
/// - Target date is evaluated against midnight of [today].
GoalProjection computeGoalProjection({
  required FinancialGoal goal,
  required DateTime today,
}) {
  final nowMidnight = normalizeDate(today);
  final targetMidnight = normalizeDate(goal.targetDate);
  final diffDays = targetMidnight.difference(nowMidnight).inDays;
  final isOverdue = diffDays < 0;
  final isCompleted =
      goal.targetAmount > 0 && goal.currentAmount >= goal.targetAmount;
  final remainingAmount = math.max(0, goal.targetAmount - goal.currentAmount);

  final progressPercent = goal.targetAmount <= 0
      ? 1.0
      : (goal.currentAmount / goal.targetAmount).clamp(0.0, 1.0);

  final dailyAllocation = calculateGoalDailyAllocation(
    targetAmount: goal.targetAmount,
    currentAmount: goal.currentAmount,
    targetDate: goal.targetDate,
    today: today,
    manualDailyAllocation: goal.manualDailyAllocation,
  );

  DateTime? estimatedCompletionDate;
  if (isCompleted) {
    estimatedCompletionDate = nowMidnight;
  } else if (dailyAllocation > 0) {
    final daysNeeded = (remainingAmount / dailyAllocation).ceil();
    estimatedCompletionDate = nowMidnight.add(Duration(days: daysNeeded));
  }

  return GoalProjection(
    goal: goal,
    progressPercent: progressPercent,
    dailyAllocation: dailyAllocation,
    estimatedCompletionDate: estimatedCompletionDate,
    isCompleted: isCompleted,
    isOverdue: isOverdue,
    daysRemainingToTargetDate: math.max(0, diffDays),
    remainingAmount: remainingAmount,
  );
}

/// Aggregate summary across all active goals (multi-goal tracker).
class GoalsOverviewSummary {
  const GoalsOverviewSummary({
    required this.totalTargetAmount,
    required this.totalCurrentAmount,
    required this.totalDailySavingsReserve,
    required this.overallProgress,
    required this.projections,
  });

  final int totalTargetAmount;
  final int totalCurrentAmount;
  final int totalDailySavingsReserve;
  final double overallProgress;
  final List<GoalProjection> projections;

  int get goalCount => projections.length;
  int get completedCount => projections.where((p) => p.isCompleted).length;
}

/// Reactively computes the full goals overview summary for display.
final goalsOverviewSummaryProvider = Provider<AsyncValue<GoalsOverviewSummary>>(
  (ref) {
    final goalsAsync = ref.watch(goalsStreamProvider);
    return goalsAsync.whenData((goals) {
      final now = DateTime.now();
      var totalTarget = 0;
      var totalCurrent = 0;
      var totalDailyReserve = 0;

      final projections = <GoalProjection>[];
      for (final goal in goals) {
        final proj = computeGoalProjection(goal: goal, today: now);
        projections.add(proj);
        totalTarget += goal.targetAmount;
        totalCurrent += goal.currentAmount;
        totalDailyReserve += proj.dailyAllocation;
      }

      final overallProgress = totalTarget <= 0
          ? 0.0
          : (totalCurrent / totalTarget).clamp(0.0, 1.0);

      return GoalsOverviewSummary(
        totalTargetAmount: totalTarget,
        totalCurrentAmount: totalCurrent,
        totalDailySavingsReserve: totalDailyReserve,
        overallProgress: overallProgress,
        projections: projections,
      );
    });
  },
);

/// Result of realism check before saving or updating a goal (FR-06b, BR-03).
class RealismCheckResult {
  const RealismCheckResult({
    required this.isUnrealistic,
    required this.projectedUangJajanAmanHariIni,
    required this.projectedDailySavingsReserve,
    required this.currentUangJajanAmanHariIni,
  });

  /// True if the proposed goal's daily reserve would push daily safe spend negative (< 0).
  final bool isUnrealistic;
  final int projectedUangJajanAmanHariIni;
  final int projectedDailySavingsReserve;
  final int currentUangJajanAmanHariIni;
}

/// Evaluates whether a proposed goal change would cause Uang Jajan Aman to drop
/// into negative territory (FR-06b, BR-03).
///
/// Strictly calls M4's existing formula functions via `computeDailyBudgetSummary`,
/// preserving the single source of truth without duplicating formula logic.
RealismCheckResult checkGoalRealism({
  required FinancialGoal candidateGoal,
  required List<FinancialGoal> existingGoals,
  required LocalProfile profile,
  PayCycle? latestCycle,
  required List<db.Transaction> transactions,
  DateTime? referenceNow,
}) {
  final now = referenceNow ?? DateTime.now();

  final currentSummary = computeDailyBudgetSummary(
    profile: profile,
    latestCycle: latestCycle,
    transactions: transactions,
    goals: existingGoals,
    referenceNow: now,
  );

  // Replace existing goal if editing by ID, or append if new
  final candidateGoals = <FinancialGoal>[];
  var replaced = false;
  for (final g in existingGoals) {
    if (candidateGoal.id != 0 && g.id == candidateGoal.id) {
      candidateGoals.add(candidateGoal);
      replaced = true;
    } else {
      candidateGoals.add(g);
    }
  }
  if (!replaced) {
    candidateGoals.add(candidateGoal);
  }

  final projectedSummary = computeDailyBudgetSummary(
    profile: profile,
    latestCycle: latestCycle,
    transactions: transactions,
    goals: candidateGoals,
    referenceNow: now,
  );

  final isUnrealistic = projectedSummary.uangJajanAmanHariIni < 0;

  return RealismCheckResult(
    isUnrealistic: isUnrealistic,
    projectedUangJajanAmanHariIni: projectedSummary.uangJajanAmanHariIni,
    projectedDailySavingsReserve: projectedSummary.dailySavingsReserve,
    currentUangJajanAmanHariIni: currentSummary.uangJajanAmanHariIni,
  );
}
