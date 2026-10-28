// Goals data layer (M6): handles CRUD, reactive queries, and withdrawal
// feeding back into active PayCycle or LocalProfile carry-over (FR-06, FR-06b, FR-06c, BR-03).
import 'package:isar_community/isar.dart';

import '../../../core/database/category.dart';
import '../../../core/database/financial_goal.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;

abstract class GoalsRepositoryBase {
  Stream<List<FinancialGoal>> watchGoals();

  Future<List<FinancialGoal>> getGoals();

  Future<List<FinancialGoal>> getAllGoals();

  Future<FinancialGoal?> getGoal(int id);

  Future<FinancialGoal?> getGoalById(int id);

  Future<FinancialGoal> saveGoal({
    int? id,
    required String name,
    required int targetAmount,
    int currentAmount = 0,
    required DateTime targetDate,
    int? manualDailyAllocation,
  });

  Future<bool> deleteGoal(int id);

  /// FR-06c Withdraw: takes an amount from [goalId], decreases `currentAmount`,
  /// and feeds the withdrawn amount back into available balance for current period:
  /// - Mode A: records an income transaction linked to the active PayCycle
  ///   and increments `variableIncomeTotal`, increasing `RemainingBalance`.
  /// - Mode B: increases `LocalProfile.carryOverBalance`.
  Future<FinancialGoal> withdrawFromGoal({
    required int goalId,
    required int amount,
    DateTime? referenceNow,
  });
}

class GoalsRepository implements GoalsRepositoryBase {
  GoalsRepository(this._isar);

  final Isar _isar;

  @override
  Stream<List<FinancialGoal>> watchGoals() {
    return _isar.financialGoals.where().watch(fireImmediately: true);
  }

  @override
  Future<List<FinancialGoal>> getGoals() {
    return _isar.financialGoals.where().findAll();
  }

  @override
  Future<List<FinancialGoal>> getAllGoals() => getGoals();

  @override
  Future<FinancialGoal?> getGoal(int id) {
    return _isar.financialGoals.get(id);
  }

  @override
  Future<FinancialGoal?> getGoalById(int id) => getGoal(id);

  @override
  Future<FinancialGoal> saveGoal({
    int? id,
    required String name,
    required int targetAmount,
    int currentAmount = 0,
    required DateTime targetDate,
    int? manualDailyAllocation,
  }) async {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(
        name,
        'name',
        'Nama target tidak boleh kosong.',
      );
    }
    if (targetAmount <= 0) {
      throw ArgumentError.value(
        targetAmount,
        'targetAmount',
        'Target nominal harus lebih besar dari 0.',
      );
    }
    if (currentAmount < 0) {
      throw ArgumentError.value(
        currentAmount,
        'currentAmount',
        'Saldo saat ini tidak boleh negatif.',
      );
    }
    if (manualDailyAllocation != null && manualDailyAllocation <= 0) {
      throw ArgumentError.value(
        manualDailyAllocation,
        'manualDailyAllocation',
        'Alokasi harian manual harus lebih besar dari 0.',
      );
    }

    return _isar.writeTxn(() async {
      final goal = (id != null && id > 0)
          ? (await _isar.financialGoals.get(id) ?? FinancialGoal())
          : FinancialGoal();

      if (id != null && id > 0) {
        goal.id = id;
      }
      goal.goalName = name.trim();
      goal.targetAmount = targetAmount;
      goal.currentAmount = currentAmount;
      goal.targetDate = targetDate;
      goal.manualDailyAllocation = manualDailyAllocation;

      final savedId = await _isar.financialGoals.put(goal);
      goal.id = savedId;
      return goal;
    });
  }

  @override
  Future<bool> deleteGoal(int id) async {
    return _isar.writeTxn(() async {
      return _isar.financialGoals.delete(id);
    });
  }

  @override
  Future<FinancialGoal> withdrawFromGoal({
    required int goalId,
    required int amount,
    DateTime? referenceNow,
  }) async {
    final now = referenceNow ?? DateTime.now();
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Nominal penarikan harus lebih besar dari 0.',
      );
    }

    return _isar.writeTxn(() async {
      final goal = await _isar.financialGoals.get(goalId);
      if (goal == null) {
        throw ArgumentError('Target dengan ID $goalId tidak ditemukan.');
      }
      if (amount > goal.currentAmount) {
        throw ArgumentError(
          'Nominal penarikan melebihi saldo tabungan saat ini.',
        );
      }

      // 1. Decrement goal currentAmount
      goal.currentAmount -= amount;
      await _isar.financialGoals.put(goal);

      // 2. Feed withdrawn amount back into available balance for the current period (FR-06c)
      final profile = await _isar.localProfiles.where().findFirst();
      final latestCycle = await _isar.payCycles
          .where()
          .sortByStartDateDesc()
          .findFirst();

      final isPeriodic =
          profile?.incomeFrequency == IncomeFrequency.periodic ||
          (profile == null && latestCycle != null);

      final categories = await _isar.categorys.where().findAll();
      final catId = categories.isNotEmpty ? categories.first.id : 1;

      final tx = db.Transaction()
        ..type = db.TransactionType.income
        ..amount = amount
        ..categoryId = catId
        ..date = now
        ..notes = 'Tarik dari goal: ${goal.goalName}'
        ..payCycleId = isPeriodic ? latestCycle?.id : null;

      await _isar.transactions.put(tx);

      if (isPeriodic) {
        // Mode A: increases RemainingBalance for the active PayCycle
        if (latestCycle != null) {
          latestCycle.variableIncomeTotal += amount;
          await _isar.payCycles.put(latestCycle);
        }
      } else {
        // Mode B: increases SaldoCarryOver
        if (profile != null) {
          profile.carryOverBalance += amount;
          await _isar.localProfiles.put(profile);
        }
      }

      return goal;
    });
  }
}
