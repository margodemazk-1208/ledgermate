import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/asset.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart';
import 'package:ledgermate/features/goals/data/goals_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late GoalsRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: false);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('goals_repo_test_');
    isar = await Isar.open([
      LocalProfileSchema,
      PayCycleSchema,
      TransactionSchema,
      CategorySchema,
      FinancialGoalSchema,
      AssetSchema,
    ], directory: tempDir.path);
    repository = GoalsRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('GoalsRepository CRUD (FR-06)', () {
    test('saveGoal creates new goal when id is null', () async {
      final targetDate = DateTime(2026, 12, 31);
      final goal = await repository.saveGoal(
        name: 'Dana Darurat',
        targetAmount: 5000000,
        currentAmount: 1000000,
        targetDate: targetDate,
        manualDailyAllocation: 50000,
      );

      expect(goal.id, greaterThan(0));
      expect(goal.goalName, 'Dana Darurat');
      expect(goal.targetAmount, 5000000);
      expect(goal.currentAmount, 1000000);
      expect(goal.targetDate, targetDate);
      expect(goal.manualDailyAllocation, 50000);

      final fetched = await repository.getGoalById(goal.id);
      expect(fetched, isNotNull);
      expect(fetched!.goalName, 'Dana Darurat');
    });

    test('saveGoal updates existing goal when id is provided', () async {
      final initial = await repository.saveGoal(
        name: 'Laptop Baru',
        targetAmount: 15000000,
        currentAmount: 2000000,
        targetDate: DateTime(2027, 1, 1),
      );

      final updated = await repository.saveGoal(
        id: initial.id,
        name: 'Laptop Gaming Baru',
        targetAmount: 18000000,
        currentAmount: 5000000,
        targetDate: DateTime(2027, 3, 1),
        manualDailyAllocation: 75000,
      );

      expect(updated.id, initial.id);
      expect(updated.goalName, 'Laptop Gaming Baru');
      expect(updated.targetAmount, 18000000);
      expect(updated.currentAmount, 5000000);
      expect(updated.manualDailyAllocation, 75000);

      final all = await repository.getAllGoals();
      expect(all.length, 1);
    });

    test('deleteGoal removes goal from database', () async {
      final goal = await repository.saveGoal(
        name: 'Liburan',
        targetAmount: 3000000,
        currentAmount: 500000,
        targetDate: DateTime(2026, 11, 30),
      );

      expect(await repository.getGoalById(goal.id), isNotNull);

      final deleted = await repository.deleteGoal(goal.id);
      expect(deleted, isTrue);
      expect(await repository.getGoalById(goal.id), isNull);
    });

    test('watchGoals emits updated goals stream', () async {
      final stream = repository.watchGoals();
      expectLater(
        stream,
        emitsInOrder([hasLength(0), hasLength(1), hasLength(2)]),
      );

      await repository.saveGoal(
        name: 'Goal 1',
        targetAmount: 1000000,
        targetDate: DateTime(2026, 12, 1),
      );

      await repository.saveGoal(
        name: 'Goal 2',
        targetAmount: 2000000,
        targetDate: DateTime(2027, 1, 1),
      );
    });
  });

  group('GoalsRepository Withdrawal (FR-06c)', () {
    test('Mode A: withdraws from goal and credits active PayCycle and creates income transaction', () async {
      // Seed active PayCycle (Mode A)
      final cycle = PayCycle()
        ..startDate = DateTime(2026, 10, 1)
        ..paydayDate = DateTime(2026, 10, 31)
        ..fixedSalary = 10000000
        ..mandatoryExpenses = [
          MandatoryExpenseItem()
            ..name = 'Mandatory'
            ..amount = 2000000,
        ]
        ..variableIncomeTotal = 100000;
      await isar.writeTxn(() => isar.payCycles.put(cycle));

      final goal = await repository.saveGoal(
        name: 'Dana Darurat',
        targetAmount: 5000000,
        currentAmount: 2000000,
        targetDate: DateTime(2027, 1, 1),
      );

      // Withdraw 500,000
      final updatedGoal = await repository.withdrawFromGoal(
        goalId: goal.id,
        amount: 500000,
      );

      expect(updatedGoal.currentAmount, 1500000);

      // Verify cycle was updated
      final updatedCycle = await isar.payCycles.get(cycle.id);
      expect(updatedCycle!.variableIncomeTotal, 100000 + 500000);

      // Verify income transaction was recorded
      final txs = await isar.transactions.where().findAll();
      expect(txs.length, 1);
      final tx = txs.first;
      expect(tx.type, TransactionType.income);
      expect(tx.amount, 500000);
      expect(tx.payCycleId, cycle.id);
      expect(tx.notes, contains('Dana Darurat'));
    });

    test('Mode B: withdraws from goal and increments LocalProfile.carryOverBalance when no active cycle exists', () async {
      // Seed profile with carryOverBalance (Mode B)
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.daily
        ..carryOverBalance = 250000;
      await isar.writeTxn(() => isar.localProfiles.put(profile));

      final goal = await repository.saveGoal(
        name: 'Modal Dagang',
        targetAmount: 3000000,
        currentAmount: 1000000,
        targetDate: DateTime(2027, 2, 1),
      );

      // Withdraw 400,000
      final updatedGoal = await repository.withdrawFromGoal(
        goalId: goal.id,
        amount: 400000,
      );

      expect(updatedGoal.currentAmount, 600000);

      // Verify profile carryOverBalance was incremented
      final updatedProfile = await isar.localProfiles.where().findFirst();
      expect(updatedProfile!.carryOverBalance, 250000 + 400000);

      // Verify income transaction was recorded (Mode B transaction has null payCycleId)
      final txs = await isar.transactions.where().findAll();
      expect(txs.length, 1);
      final tx = txs.first;
      expect(tx.type, TransactionType.income);
      expect(tx.amount, 400000);
      expect(tx.payCycleId, isNull);
    });

    test(
      'throws ArgumentError if withdrawal amount exceeds currentAmount',
      () async {
        final goal = await repository.saveGoal(
          name: 'Tabungan Kecil',
          targetAmount: 1000000,
          currentAmount: 300000,
          targetDate: DateTime(2027, 1, 1),
        );

        expect(
          () => repository.withdrawFromGoal(goalId: goal.id, amount: 500000),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('throws ArgumentError if withdrawal amount is <= 0', () async {
      final goal = await repository.saveGoal(
        name: 'Tabungan',
        targetAmount: 1000000,
        currentAmount: 300000,
        targetDate: DateTime(2027, 1, 1),
      );

      expect(
        () => repository.withdrawFromGoal(goalId: goal.id, amount: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repository.withdrawFromGoal(goalId: goal.id, amount: -10000),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
