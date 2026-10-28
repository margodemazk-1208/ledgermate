// Notification integration point for Pay Cycle lifecycle events (PRD FR-11 reminder type 3: "Siklus gajian baru").
//
// M10 will implement/override this hook to schedule local notifications
// via `flutter_local_notifications` when a pay cycle starts or expires.
// M5 provides this single, unambiguous integration hook so M10 does not need
// to reverse-engineer where to wire into.

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/local_profile.dart';

/// Contract for handling pay cycle notification triggers.
abstract class PayCycleNotificationHook {
  /// Invoked when a new pay cycle has started (transition completed).
  ///
  /// [incomeFrequency] indicates whether Mode A (periodic) or Mode B (daily) applies.
  /// [nextPaydayDate] is the scheduled end/payday of the cycle (Mode A), or null for Mode B.
  /// [incomeAmount] is the fixed salary (Mode A) or logged bekel (Mode B).
  Future<void> onPayCycleStarted({
    required IncomeFrequency incomeFrequency,
    DateTime? nextPaydayDate,
    required int incomeAmount,
  });

  /// Invoked when a cycle boundary is detected as reached or overdue.
  Future<void> onPayCycleExpired({
    required IncomeFrequency incomeFrequency,
    required DateTime expiredDate,
  });
}

/// Default no-op hook for M5. M10 overrides this provider with
/// real `flutter_local_notifications` scheduling.
class NoOpPayCycleNotificationHook implements PayCycleNotificationHook {
  const NoOpPayCycleNotificationHook();

  @override
  Future<void> onPayCycleStarted({
    required IncomeFrequency incomeFrequency,
    DateTime? nextPaydayDate,
    required int incomeAmount,
  }) async {
    // Integration point for M10: schedule reminder for nextPaydayDate.
  }

  @override
  Future<void> onPayCycleExpired({
    required IncomeFrequency incomeFrequency,
    required DateTime expiredDate,
  }) async {
    // Integration point for M10: trigger immediate notification when cycle expires.
  }
}

/// Provider for [PayCycleNotificationHook].
final payCycleNotificationHookProvider = Provider<PayCycleNotificationHook>((
  ref,
) {
  return const NoOpPayCycleNotificationHook();
});
