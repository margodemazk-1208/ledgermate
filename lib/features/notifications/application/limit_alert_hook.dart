import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/financial_goal.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../budget_engine/application/budget_providers.dart';
import '../data/notification_service.dart';

/// Hook triggered whenever a transaction is saved, to check if daily budget limit
/// has been exceeded (PRD FR-11 reminder type 2).
abstract class LimitAlertHook {
  Future<void> onTransactionSaved();
}

class RealLimitAlertHook implements LimitAlertHook {
  RealLimitAlertHook(this._ref);

  final Ref _ref;

  @override
  Future<void> onTransactionSaved() async {
    try {
      final isar = _ref.read(isarProvider);
      final profile = await isar.localProfiles.where().findFirst();
      if (profile == null || !profile.notifLimitAlertEnabled) return;

      final latestCycle = await isar.payCycles
          .where()
          .sortByStartDateDesc()
          .findFirst();
      final txs = await isar.transactions.where().findAll();
      final goals = await isar.financialGoals.where().findAll();

      // Wire to the EXACT same formula M4 Home reads
      final summary = computeDailyBudgetSummary(
        profile: profile,
        latestCycle: latestCycle,
        transactions: txs,
        goals: goals,
      );

      if (summary.uangJajanAmanHariIni <= 0) {
        final notifService = _ref.read(notificationServiceProvider);
        await notifService.showLimitExceededAlert(
          uangJajanAmanHariIni: summary.uangJajanAmanHariIni,
        );
      }
    } catch (_) {
      // Ignore in-memory or transient DB error
    }
  }
}

final limitAlertHookProvider = Provider<LimitAlertHook>((ref) {
  return RealLimitAlertHook(ref);
});
