import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/formulas/daily_budget_formulas.dart';

void main() {
  group('Smart Daily Budget Engine (BR-01, BR-02, BR-03)', () {
    final today = DateTime(2026, 10, 20);

    test('Case 1: Mode A normal case (periodic monthly/biweekly)', () {
      // Fixed income = 6,000,000, additional income = 500,000
      // Mandatory expenses = 2,000,000, recorded expenses = 1,500,000
      // Remaining days = 15, daily savings reserve = 50,000
      final result = calculateModeABudget(
        fixedIncome: 6000000,
        additionalIncome: 500000,
        mandatoryExpenses: 2000000,
        recordedExpenses: 1500000,
        remainingDays: 15,
        dailySavingsReserve: 50000,
      );

      expect(result.remainingBalance, 3000000);
      expect(result.remainingDays, 15);
      // 3,000,000 / 15 = 200,000
      expect(result.dailySpendingAllowance, 200000);
      expect(result.dailySavingsReserve, 50000);
      // 200,000 - 50,000 = 150,000
      expect(result.uangJajanAmanHariIni, 150000);

      // Dynamic re-calculation after an extra expense (self-balancing, D6):
      final updated = calculateModeABudget(
        fixedIncome: 6000000,
        additionalIncome: 500000,
        mandatoryExpenses: 2000000,
        recordedExpenses: 1650000, // spent 150,000 more
        remainingDays: 15,
        dailySavingsReserve: 50000,
      );
      expect(updated.remainingBalance, 2850000);
      expect(updated.dailySpendingAllowance, 190000);
      expect(updated.uangJajanAmanHariIni, 140000);
    });

    test('Case 2: Mode B normal case (daily/bekel)', () {
      // SaldoCarryOver = 100,000, BekelHariIni = 50,000
      // PengeluaranWajibHariIni = 10,000, PengeluaranHariIni = 20,000
      // DailySavingsReserve = 15,000
      final result = calculateModeBBudget(
        saldoCarryOver: 100000,
        bekelHariIni: 50000,
        pengeluaranWajibHariIni: 10000,
        pengeluaranHariIni: 20000,
        dailySavingsReserve: 15000,
      );

      expect(result.saldoCarryOver, 100000);
      expect(result.bekelHariIni, 50000);
      expect(result.pengeluaranWajibHariIni, 10000);
      expect(result.pengeluaranHariIni, 20000);
      expect(result.dailySavingsReserve, 15000);
      // 100,000 + 50,000 - 10,000 - 20,000 - 15,000 = 105,000
      expect(result.uangJajanAmanHariIni, 105000);
    });

    test('Case 3: Zero-goals case (DailySavingsReserve is 0)', () {
      final reserve = calculateDailySavingsReserve(
        goals: const [],
        today: today,
      );
      expect(reserve, 0);

      final modeA = calculateModeABudget(
        fixedIncome: 3000000,
        additionalIncome: 0,
        mandatoryExpenses: 1000000,
        recordedExpenses: 500000,
        remainingDays: 10,
        dailySavingsReserve: reserve,
      );
      expect(modeA.dailySavingsReserve, 0);
      // 1,500,000 / 10 = 150,000 - 0 = 150,000
      expect(modeA.uangJajanAmanHariIni, 150000);

      final modeB = calculateModeBBudget(
        saldoCarryOver: 50000,
        bekelHariIni: 30000,
        pengeluaranWajibHariIni: 5000,
        pengeluaranHariIni: 10000,
        dailySavingsReserve: reserve,
      );
      expect(modeB.dailySavingsReserve, 0);
      // 50,000 + 30,000 - 5,000 - 10,000 - 0 = 65,000
      expect(modeB.uangJajanAmanHariIni, 65000);
    });

    test('Case 4: Multiple-goals case', () {
      final goals = [
        GoalAllocationInput(
          targetAmount: 1000000,
          currentAmount: 200000,
          targetDate: today.add(const Duration(days: 10)),
        ),
        GoalAllocationInput(
          targetAmount: 300000,
          currentAmount: 0,
          targetDate: today.add(const Duration(days: 30)),
        ),
        // Fulfilled goal should contribute 0
        GoalAllocationInput(
          targetAmount: 500000,
          currentAmount: 500000,
          targetDate: today.add(const Duration(days: 5)),
        ),
      ];

      // Goal 1: (1,000,000 - 200,000) / 10 = 80,000
      // Goal 2: 300,000 / 30 = 10,000
      // Goal 3: 0 (fulfilled)
      // Total = 90,000
      final reserve = calculateDailySavingsReserve(goals: goals, today: today);
      expect(reserve, 90000);
    });

    test('Case 5: Goal with manualDailyAllocation override (BR-03)', () {
      final goals = [
        GoalAllocationInput(
          targetAmount: 1000000,
          currentAmount: 200000,
          targetDate: today.add(const Duration(days: 10)),
          manualDailyAllocation: 50000, // overrides auto 80,000
        ),
        GoalAllocationInput(
          targetAmount: 300000,
          currentAmount: 0,
          targetDate: today.add(const Duration(days: 30)),
          manualDailyAllocation: null, // auto: 10,000
        ),
      ];

      final reserve = calculateDailySavingsReserve(goals: goals, today: today);
      // 50,000 (manual) + 10,000 (auto) = 60,000
      expect(reserve, 60000);
    });

    test('Case 6: Mode B after several days of carry-over accumulation', () {
      // Day 1: start with 50,000 carry-over
      final day1 = calculateModeBBudget(
        saldoCarryOver: 50000,
        bekelHariIni: 40000,
        pengeluaranWajibHariIni: 10000,
        pengeluaranHariIni: 20000,
        dailySavingsReserve: 5000,
      );
      // 50,000 + 40,000 - 10,000 - 20,000 - 5,000 = 55,000
      expect(day1.uangJajanAmanHariIni, 55000);

      // Day 2: carries over unspent 55,000 from day 1
      final carryOverDay2 = calculateNextDayCarryOver(
        day1.uangJajanAmanHariIni,
      );
      expect(carryOverDay2, 55000);

      final day2 = calculateModeBBudget(
        saldoCarryOver: carryOverDay2,
        bekelHariIni: 40000,
        pengeluaranWajibHariIni: 10000,
        pengeluaranHariIni: 60000, // spent more today
        dailySavingsReserve: 5000,
      );
      // 55,000 + 40,000 - 10,000 - 60,000 - 5,000 = 20,000
      expect(day2.uangJajanAmanHariIni, 20000);

      // Day 3: carries over 20,000
      final carryOverDay3 = calculateNextDayCarryOver(
        day2.uangJajanAmanHariIni,
      );
      expect(carryOverDay3, 20000);

      final day3 = calculateModeBBudget(
        saldoCarryOver: carryOverDay3,
        bekelHariIni: 0, // weekend / no pocket money
        pengeluaranWajibHariIni: 5000,
        pengeluaranHariIni: 10000,
        dailySavingsReserve: 5000,
      );
      // 20,000 + 0 - 5,000 - 10,000 - 5,000 = 0
      expect(day3.uangJajanAmanHariIni, 0);

      // Day 4: overspent day produces negative carryOver
      final carryOverDay4 = calculateNextDayCarryOver(
        day3.uangJajanAmanHariIni,
      );
      final day4 = calculateModeBBudget(
        saldoCarryOver: carryOverDay4,
        bekelHariIni: 20000,
        pengeluaranWajibHariIni: 0,
        pengeluaranHariIni: 30000, // overspent by 10,000
        dailySavingsReserve: 0,
      );
      // 0 + 20,000 - 0 - 30,000 - 0 = -10,000
      expect(day4.uangJajanAmanHariIni, -10000);

      // Day 5: carry-over preserves the -10,000 deficit, tightening future budget
      final carryOverDay5 = calculateNextDayCarryOver(
        day4.uangJajanAmanHariIni,
      );
      expect(carryOverDay5, -10000);
    });

    test('Edge Case A: RemainingDays=1 for Mode A (last day of cycle)', () {
      final nextPayday = today.add(const Duration(days: 1));
      final remainingDays = calculateRemainingDays(today, nextPayday);
      expect(remainingDays, 1);

      final result = calculateModeABudget(
        fixedIncome: 3000000,
        additionalIncome: 0,
        mandatoryExpenses: 1000000,
        recordedExpenses: 1750000,
        remainingDays: remainingDays,
        dailySavingsReserve: 50000,
      );
      // Remaining balance = 250,000
      // Daily allowance = 250,000 / 1 = 250,000
      // Uang jajan aman = 250,000 - 50,000 = 200,000
      expect(result.remainingBalance, 250000);
      expect(result.dailySpendingAllowance, 250000);
      expect(result.uangJajanAmanHariIni, 200000);
    });

    test('Edge Case A2: Today is payday or past (clamped to 1, no division by zero)', () {
      final remainingDays = calculateRemainingDays(today, today);
      expect(remainingDays, 1);

      final pastPayday = today.subtract(const Duration(days: 2));
      final remainingPast = calculateRemainingDays(today, pastPayday);
      expect(remainingPast, 1);
    });

    test('Edge Case B: BekelHariIni=0 for Mode B (irregular schedule)', () {
      final result = calculateModeBBudget(
        saldoCarryOver: 80000,
        bekelHariIni: 0, // no income logged on this day
        pengeluaranWajibHariIni: 0,
        pengeluaranHariIni: 30000,
        dailySavingsReserve: 10000,
      );
      // 80,000 + 0 - 0 - 30,000 - 10,000 = 40,000
      expect(result.uangJajanAmanHariIni, 40000);
    });

    test(
      'Integer-money discipline: floor for spending, ceil for savings reserve',
      () {
        // RemainingBalance = 100,000, RemainingDays = 3
        // Exact division: 33,333.333...
        // Floor: 33,333 (conservative, avoids spending fractional Rupiah)
        final budget = calculateModeABudget(
          fixedIncome: 100000,
          additionalIncome: 0,
          mandatoryExpenses: 0,
          recordedExpenses: 0,
          remainingDays: 3,
          dailySavingsReserve: 0,
        );
        expect(budget.dailySpendingAllowance, 33333);
        expect(budget.uangJajanAmanHariIni, 33333);

        // Goal: 100,000 in 3 days
        // Exact: 33,333.333...
        // Ceil: 33,334 (reaches 100,002 in 3 days, fulfilling the goal)
        final goalAllocation = calculateGoalDailyAllocation(
          targetAmount: 100000,
          currentAmount: 0,
          targetDate: today.add(const Duration(days: 3)),
          today: today,
        );
        expect(goalAllocation, 33334);
      },
    );
  });
}
