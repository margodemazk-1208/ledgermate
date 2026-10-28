import 'dart:async';

import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/features/goals/data/goals_repository.dart';

/// In-memory test double for [GoalsRepositoryBase] to avoid Isar async
/// hangs under `testWidgets()`.
class FakeGoalsRepository implements GoalsRepositoryBase {
  FakeGoalsRepository({List<FinancialGoal>? initialGoals}) {
    if (initialGoals != null) {
      _goals.addAll(initialGoals);
    }
  }

  final List<FinancialGoal> _goals = [];
  final _goalsController = StreamController<List<FinancialGoal>>.broadcast();
  int _nextId = 1;

  void dispose() {
    _goalsController.close();
  }

  void _notify() {
    _goalsController.add([..._goals]);
  }

  @override
  Stream<List<FinancialGoal>> watchGoals() {
    final current = [..._goals];
    return Stream<List<FinancialGoal>>.value(current)
        .concatWith(_goalsController.stream);
  }

  @override
  Future<List<FinancialGoal>> getGoals() async => [..._goals];

  @override
  Future<List<FinancialGoal>> getAllGoals() async => [..._goals];

  @override
  Future<FinancialGoal?> getGoal(int id) async {
    try {
      return _goals.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
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

    FinancialGoal goal;
    if (id != null && id > 0) {
      final index = _goals.indexWhere((g) => g.id == id);
      if (index >= 0) {
        goal = _goals[index];
      } else {
        goal = FinancialGoal()..id = id;
        _goals.add(goal);
      }
    } else {
      goal = FinancialGoal()..id = _nextId++;
      _goals.add(goal);
    }

    goal.goalName = name.trim();
    goal.targetAmount = targetAmount;
    goal.currentAmount = currentAmount;
    goal.targetDate = targetDate;
    goal.manualDailyAllocation = manualDailyAllocation;

    _notify();
    return goal;
  }

  @override
  Future<bool> deleteGoal(int id) async {
    _goals.removeWhere((g) => g.id == id);
    _notify();
    return true;
  }

  @override
  Future<FinancialGoal> withdrawFromGoal({
    required int goalId,
    required int amount,
    DateTime? referenceNow,
  }) async {
    if (amount <= 0) {
      throw ArgumentError.value(
        amount,
        'amount',
        'Nominal penarikan harus lebih besar dari 0.',
      );
    }
    final goal = await getGoal(goalId);
    if (goal == null) {
      throw ArgumentError('Target dengan ID $goalId tidak ditemukan.');
    }
    if (amount > goal.currentAmount) {
      throw ArgumentError(
        'Nominal penarikan melebihi saldo tabungan saat ini.',
      );
    }

    goal.currentAmount -= amount;
    _notify();
    return goal;
  }
}

extension<T> on Stream<T> {
  Stream<T> concatWith(Stream<T> other) async* {
    yield* this;
    yield* other;
  }
}
