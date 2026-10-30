// Budget data layer (M4): reactive queries across Isar collections
// (LocalProfile, PayCycle, Transaction, FinancialGoal).
import 'package:isar_community/isar.dart';

import '../../../core/database/financial_goal.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/database/transactions_watch.dart';

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

  /// M18/D18 perf item 2: delegates to the SHARED watch helper in
  /// `core/database/transactions_watch.dart` instead of opening its own
  /// independent Isar subscription — see that file's header for why.
  @override
  Stream<List<db.Transaction>> watchTransactions() {
    return watchAllTransactionsShared(_isar);
  }

  @override
  Stream<List<FinancialGoal>> watchGoals() {
    return _isar.financialGoals.where().watch(fireImmediately: true);
  }
}
