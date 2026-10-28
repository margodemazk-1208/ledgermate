import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/features/goals/application/goals_providers.dart';

void main() {
  group('GoalProjection (FR-06, BR-03 formulas)', () {
    test(
      'calculates dailyAllocation = ceil(remainingAmount / remainingDays)',
      () {
        final referenceNow = DateTime(2026, 10, 1);
        final targetDate = DateTime(2026, 10, 11); // 10 days remaining
        final goal = FinancialGoal()
          ..targetAmount = 1000000
          ..currentAmount = 0
          ..targetDate = targetDate;

        final proj = GoalProjection.fromGoal(goal, referenceNow: referenceNow);
        expect(proj.remainingAmount, 1000000);
        expect(proj.remainingDays, 10);
        expect(proj.dailyAllocation, 100000); // 1,000,000 / 10
        expect(proj.progressPercent, 0.0);
        expect(proj.isCompleted, isFalse);
      },
    );

    test('rounds up with ceil for uneven division', () {
      final referenceNow = DateTime(2026, 10, 1);
      final targetDate = DateTime(2026, 10, 4); // 3 days
      final goal = FinancialGoal()
        ..targetAmount = 10000
        ..currentAmount = 0
        ..targetDate = targetDate;

      final proj = GoalProjection.fromGoal(goal, referenceNow: referenceNow);
      expect(proj.remainingDays, 3);
      expect(proj.dailyAllocation, 3334); // ceil(10000 / 3) = 3334
    });

    test('respects manualDailyAllocation override when set', () {
      final referenceNow = DateTime(2026, 10, 1);
      final targetDate = DateTime(2026, 10, 11); // 10 days
      final goal = FinancialGoal()
        ..targetAmount = 1000000
        ..currentAmount = 0
        ..targetDate = targetDate
        ..manualDailyAllocation = 50000;

      final proj = GoalProjection.fromGoal(goal, referenceNow: referenceNow);
      expect(proj.dailyAllocation, 50000);
      // With 50,000/day, 1,000,000 needs 20 days -> Oct 21, 2026
      expect(proj.estimatedCompletionDate, DateTime(2026, 10, 21));
    });

    test('handles already completed goal', () {
      final goal = FinancialGoal()
        ..targetAmount = 5000000
        ..currentAmount = 5000000
        ..targetDate = DateTime(2026, 12, 31);

      final proj = GoalProjection.fromGoal(goal);
      expect(proj.isCompleted, isTrue);
      expect(proj.remainingAmount, 0);
      expect(proj.dailyAllocation, 0);
      expect(proj.progressPercent, 1.0);
    });
  });

  group('checkGoalRealism (FR-06b, BR-03)', () {
    test('realistic goal does not trigger warning (safe-to-spend >= 0)', () {
      final referenceNow = DateTime(2026, 10, 1);
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.periodic
        ..fixedSalary = 15000000;

      final cycle = PayCycle()
        ..startDate = DateTime(2026, 10, 1)
        ..paydayDate = DateTime(2026, 10, 31)
        ..fixedSalary = 15000000
        ..mandatoryExpenses = [
          MandatoryExpenseItem()
            ..name = 'Rent'
            ..amount = 3000000,
        ]
        ..variableIncomeTotal = 0;

      final candidate = FinancialGoal()
        ..goalName = 'Dana Darurat'
        ..targetAmount = 3000000
        ..currentAmount = 0
        ..targetDate = DateTime(2026, 12, 31); // ~91 days -> ~32,968/day

      final result = checkGoalRealism(
        candidateGoal: candidate,
        existingGoals: const [],
        profile: profile,
        latestCycle: cycle,
        transactions: const [],
        referenceNow: referenceNow,
      );

      expect(result.isUnrealistic, isFalse);
      expect(result.projectedUangJajanAmanHariIni, greaterThanOrEqualTo(0));
    });

    test(
      'overly ambitious goal triggers realism warning (safe-to-spend < 0)',
      () {
        final referenceNow = DateTime(2026, 10, 1);
        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..fixedSalary = 3000000;

        final cycle = PayCycle()
          ..startDate = DateTime(2026, 10, 1)
          ..paydayDate = DateTime(2026, 10, 31)
          ..fixedSalary = 3000000
          ..mandatoryExpenses = [
            MandatoryExpenseItem()
              ..name = 'Mandatory'
              ..amount = 2500000,
          ]
          ..variableIncomeTotal = 0;

        // Daily variable allowance is roughly 500,000 / 31 = ~16,129/day
        // A candidate demanding 100,000/day will drive safe-to-spend negative!
        final candidate = FinancialGoal()
          ..goalName = 'Mobil Impian'
          ..targetAmount = 10000000
          ..currentAmount = 0
          ..targetDate =
              DateTime(2026, 10, 11) // 10 days -> 1,000,000/day!
          ..manualDailyAllocation = 100000;

        final result = checkGoalRealism(
          candidateGoal: candidate,
          existingGoals: const [],
          profile: profile,
          latestCycle: cycle,
          transactions: const [],
          referenceNow: referenceNow,
        );

        expect(result.isUnrealistic, isTrue);
        expect(result.projectedUangJajanAmanHariIni, lessThan(0));
        expect(result.projectedDailySavingsReserve, 100000);
      },
    );
  });
}
