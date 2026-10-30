// Goals data layer (M6): handles CRUD, reactive queries, and withdrawal
// feeding back into active PayCycle or LocalProfile carry-over (FR-06, FR-06b, FR-06c, BR-03).
import 'package:isar_community/isar.dart';

import '../../../core/database/financial_goal.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../notifications/application/goal_notification_hook.dart';

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
  GoalsRepository(this._isar, [this._goalNotificationHook]);

  final Isar _isar;
  final GoalNotificationHook? _goalNotificationHook;

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

    int oldAmount = 0;
    if (id != null && id > 0) {
      final existing = await _isar.financialGoals.get(id);
      if (existing != null) {
        oldAmount = existing.currentAmount;
      }
    }

    final savedGoal = await _isar.writeTxn(() async {
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

    if (_goalNotificationHook != null) {
      await _goalNotificationHook.onGoalProgressChanged(
        goalName: savedGoal.goalName,
        targetAmount: savedGoal.targetAmount,
        oldCurrentAmount: oldAmount,
        newCurrentAmount: savedGoal.currentAmount,
      );
    }

    return savedGoal;
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

    // Resolved BEFORE opening the write transaction below (matches the
    // established pattern in `TransactionRepository.saveTransaction` — see
    // doc comments on these helpers in `core/database/isar_provider.dart`).
    // D18/M16 bug #2: previously this transaction was written with
    // `walletId == 0` (never reaches a real wallet's computed balance) and
    // category "Makan" (whatever category happened to be first) — both
    // replaced with real, resolved values.
    final walletId = await resolveDefaultWalletId(_isar);
    final catId = await resolveSystemCategoryId(_isar);

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

      final tx = db.Transaction()
        ..type = db.TransactionType.income
        ..amount = amount
        ..categoryId = catId
        ..walletId = walletId
        ..date = now
        ..createdAt = now
        ..notes = 'Tarik dari goal: ${goal.goalName}'
        ..payCycleId = isPeriodic ? latestCycle?.id : null;

      await _isar.transactions.put(tx);

      // D18/M16 bug #2 (Mode B double-count): the withdrawn amount must be
      // counted EXACTLY ONCE. For Mode B, `UangJajanAmanHariIni` sums
      // `carryOverBalance` (closed-out days) + today's budget-scoped income
      // transactions (open day) — see `computeDailyBudgetSummary`. The
      // transaction recorded above is dated `now` and already flows into
      // "today's bekel income" via that same mechanism, exactly like Mode
      // A's RemainingBalance is driven entirely by recorded transactions.
      // The OLD code ALSO incremented `carryOverBalance` directly here,
      // double-counting the exact same withdrawal (once via carryOverBalance
      // forever, once via the transaction for today only) — removed.
      // `carryOverBalance` itself only advances once the day actually closes
      // out, via the shared accrual/catch-up job
      // (`core/accrual/daily_accrual_service.dart`).
      if (isPeriodic) {
        // Mode A: decorative running total (NOT read by the budget formula —
        // `computeDailyBudgetSummary` sums recorded transactions directly —
        // kept for consistency with other income-recording call sites).
        if (latestCycle != null) {
          latestCycle.variableIncomeTotal += amount;
          await _isar.payCycles.put(latestCycle);
        }
      }

      return goal;
    });
  }
}
