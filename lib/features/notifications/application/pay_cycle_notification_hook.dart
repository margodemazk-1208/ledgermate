// Notification integration point for Pay Cycle lifecycle events (PRD FR-11 reminder type 3: "Siklus gajian baru").
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_community/isar.dart';

import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../data/notification_service.dart';

/// Contract for handling pay cycle notification triggers.
abstract class PayCycleNotificationHook {
  /// Invoked when a new pay cycle has started (transition completed).
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

/// Default no-op hook for fallback or isolated testing.
class NoOpPayCycleNotificationHook implements PayCycleNotificationHook {
  const NoOpPayCycleNotificationHook();

  @override
  Future<void> onPayCycleStarted({
    required IncomeFrequency incomeFrequency,
    DateTime? nextPaydayDate,
    required int incomeAmount,
  }) async {}

  @override
  Future<void> onPayCycleExpired({
    required IncomeFrequency incomeFrequency,
    required DateTime expiredDate,
  }) async {}
}

/// Real M10 hook integrating with [NotificationServiceBase] and [LocalProfile] (FR-11).
class RealPayCycleNotificationHook implements PayCycleNotificationHook {
  RealPayCycleNotificationHook(this._ref);

  final Ref _ref;

  Future<LocalProfile?> _getProfile() async {
    try {
      final isar = _ref.read(isarProvider);
      return await isar.localProfiles.where().findFirst();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> onPayCycleStarted({
    required IncomeFrequency incomeFrequency,
    DateTime? nextPaydayDate,
    required int incomeAmount,
  }) async {
    final profile = await _getProfile();
    if (profile == null || !profile.notifPayCycleEnabled) return;

    final notifService = _ref.read(notificationServiceProvider);
    final title = incomeFrequency == IncomeFrequency.periodic
        ? 'Siklus Baru Dimulai'
        : 'Siklus Harian Baru';
    final body =
        incomeFrequency == IncomeFrequency.periodic && nextPaydayDate != null
        ? 'Siklus baru aktif hingga ${nextPaydayDate.day}/${nextPaydayDate.month}/${nextPaydayDate.year}. Budget harian telah disesuaikan.'
        : 'Bekel harian telah dicatat. Uang jajan aman siap digunakan hari ini.';

    await notifService.showPayCycleAlert(title: title, body: body);
  }

  @override
  Future<void> onPayCycleExpired({
    required IncomeFrequency incomeFrequency,
    required DateTime expiredDate,
  }) async {
    final profile = await _getProfile();
    if (profile == null || !profile.notifPayCycleEnabled) return;

    final notifService = _ref.read(notificationServiceProvider);
    await notifService.showPayCycleAlert(
      title: 'Siklus Gajian Telah Tiba!',
      body: 'Waktunya perbarui gaji dan pengeluaran wajib untuk memulai siklus baru.',
    );
  }
}

/// Provider for [PayCycleNotificationHook].
final payCycleNotificationHookProvider = Provider<PayCycleNotificationHook>((
  ref,
) {
  return RealPayCycleNotificationHook(ref);
});
