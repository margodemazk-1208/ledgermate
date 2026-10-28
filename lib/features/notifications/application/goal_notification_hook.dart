import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../data/notification_service.dart';

/// Contract for handling goal milestone notification triggers (FR-11 reminder type 4).
abstract class GoalNotificationHook {
  Future<void> onGoalProgressChanged({
    required String goalName,
    required int targetAmount,
    required int oldCurrentAmount,
    required int newCurrentAmount,
  });
}

class RealGoalNotificationHook implements GoalNotificationHook {
  RealGoalNotificationHook(this._ref);

  final Ref _ref;

  @override
  Future<void> onGoalProgressChanged({
    required String goalName,
    required int targetAmount,
    required int oldCurrentAmount,
    required int newCurrentAmount,
  }) async {
    if (targetAmount <= 0) return;

    try {
      final isar = _ref.read(isarProvider);
      final profile = await isar.localProfiles.where().findFirst();
      if (profile == null || !profile.notifGoalMilestoneEnabled) return;

      final notifService = _ref.read(notificationServiceProvider);

      // Check milestones: 25%, 50%, 75%, 100%
      for (final milestone in [25, 50, 75, 100]) {
        final threshold = (targetAmount * milestone) / 100.0;
        if (oldCurrentAmount < threshold && newCurrentAmount >= threshold) {
          await notifService.showGoalMilestoneAlert(
            goalName: goalName,
            milestonePercent: milestone,
          );
        }
      }
    } catch (_) {
      // Ignore in-memory or transient DB error
    }
  }
}

final goalNotificationHookProvider = Provider<GoalNotificationHook>((ref) {
  return RealGoalNotificationHook(ref);
});
