// Budget data layer (M4): reactive queries across Isar collections
// (LocalProfile, PayCycle, Transaction, FinancialGoal).
import 'package:isar_community/isar.dart';

import '../../../core/database/financial_goal.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;

abstract class BudgetRepositoryBase {
  Stream<LocalProfile?> watchProfile();
  Stream<PayCycle?> watchLatestPayCycle();
  Stream<List<db.Transaction>> watchTransactions();
  Stream<List<FinancialGoal>> watchGoals();
}

class BudgetRepository implements BudgetRepositoryBase {
  BudgetRepository(this._isar);

  final Isar _isar;

  @override
  Stream<LocalProfile?> watchProfile() {
    return _isar.localProfiles
        .where()
        .watch(fireImmediately: true)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  @override
  Stream<PayCycle?> watchLatestPayCycle() {
    return _isar.payCycles
        .where()
        .sortByStartDateDesc()
        .watch(fireImmediately: true)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  @override
  Stream<List<db.Transaction>> watchTransactions() {
    return _isar.transactions.where().sortByDateDesc().watch(
      fireImmediately: true,
    );
  }

  @override
  Stream<List<FinancialGoal>> watchGoals() {
    return _isar.financialGoals.where().watch(fireImmediately: true);
  }
}
