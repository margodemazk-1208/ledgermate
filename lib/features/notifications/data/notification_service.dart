import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../../core/utils/rupiah_formatter.dart';

/// D18/M17 bug #1: `tz.setLocalLocation` was never called anywhere in the
/// app, so the `timezone` package silently defaulted `tz.local` to UTC —
/// every `zonedSchedule` call in [LocalNotificationService.scheduleDailyReminder]
/// then computed "21:00" in UTC, which displays as 04:00 the next day for a
/// WIB (UTC+7) device. Must run BEFORE any notification is scheduled, so
/// `main.dart` calls this once at app startup rather than waiting for the
/// lazily-created [notificationServiceProvider] to be first read.
///
/// [resolveTimezoneName] is injectable so this is unit-testable without the
/// `flutter_timezone` platform channel (unavailable under `flutter test`) —
/// real callers rely on the default, which asks the OS via that plugin.
/// Failures (plugin unavailable, unrecognized name) are swallowed and
/// logged: falling back to `tz.local`'s previous value (UTC by default) is
/// strictly better than crashing app boot over a notification nicety.
Future<void> configureLocalTimezone({
  Future<String> Function()? resolveTimezoneName,
}) async {
  tz.initializeTimeZones();
  try {
    final name = await (resolveTimezoneName ?? _defaultResolveTimezoneName)();
    tz.setLocalLocation(tz.getLocation(name));
  } catch (e) {
    debugPrint(
      'Could not resolve device timezone, notification times may be off '
      '(defaulting to ${tz.local.name}): $e',
    );
  }
}

Future<String> _defaultResolveTimezoneName() {
  return FlutterTimezone.getLocalTimezone();
}

/// Contract for local notification scheduling and immediate triggers (FR-11, D9).
abstract class NotificationServiceBase {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> scheduleDailyReminder({
    required bool enabled,
    required int timeMinutes,
  });
  Future<void> showLimitExceededAlert({required int uangJajanAmanHariIni});
  Future<void> showPayCycleAlert({required String title, required String body});
  Future<void> showGoalMilestoneAlert({
    required String goalName,
    required int milestonePercent,
  });
  Future<void> cancel(int id);
  Future<void> cancelAll();
}

/// Implementation of [NotificationServiceBase] using `flutter_local_notifications`.
class LocalNotificationService implements NotificationServiceBase {
  LocalNotificationService([FlutterLocalNotificationsPlugin? plugin])
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  bool _isInitialized = false;

  static const int dailyReminderId = 1001;
  static const int limitAlertId = 1002;
  static const int payCycleAlertId = 1003;
  static const int goalMilestoneBaseId = 1004;

  static const String dailyReminderChannelId = 'daily_reminder_channel';
  static const String limitAlertChannelId = 'limit_alert_channel';
  static const String payCycleChannelId = 'pay_cycle_channel';
  static const String goalMilestoneChannelId = 'goal_milestone_channel';

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
    } catch (e) {
      debugPrint('Timezone initialization note: $e');
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(settings: initSettings);
    _isInitialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    final androidPlatform = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlatform != null) {
      final granted = await androidPlatform.requestNotificationsPermission();
      return granted ?? false;
    }
    return true;
  }

  @override
  Future<void> scheduleDailyReminder({
    required bool enabled,
    required int timeMinutes,
  }) async {
    await _plugin.cancel(id: dailyReminderId);
    if (!enabled) return;

    final hour = (timeMinutes ~/ 60).clamp(0, 23);
    final minute = (timeMinutes % 60).clamp(0, 59);

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      dailyReminderChannelId,
      'Pengingat Harian',
      channelDescription: 'Pengingat harian untuk mencatat transaksi keuangan',
      importance: Importance.high,
      priority: Priority.high,
    );

    try {
      await _plugin.zonedSchedule(
        id: dailyReminderId,
        title: 'Saatnya Catat Keuangan!',
        body: 'Jangan lupa mencatat pengeluaran dan pemasukan hari ini di LedgerMate.',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Fallback for Android without exact alarm permission
      await _plugin.zonedSchedule(
        id: dailyReminderId,
        title: 'Saatnya Catat Keuangan!',
        body: 'Jangan lupa mencatat pengeluaran dan pemasukan hari ini di LedgerMate.',
        scheduledDate: scheduledDate,
        notificationDetails: const NotificationDetails(android: androidDetails),
        androidScheduleMode: AndroidScheduleMode.inexact,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  @override
  Future<void> showLimitExceededAlert({
    required int uangJajanAmanHariIni,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      limitAlertChannelId,
      'Peringatan Limit Anggaran',
      channelDescription:
          'Pemberitahuan saat budget harian habis atau mendekati 0',
      importance: Importance.max,
      priority: Priority.high,
    );

    final formatted = formatRupiah(uangJajanAmanHariIni);
    await _plugin.show(
      id: limitAlertId,
      title: 'Peringatan: Limit Harian Terlampaui!',
      body:
          'Uang jajan aman hari ini tersisa $formatted. Tahan pengeluaran non-esensial.',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  @override
  Future<void> showPayCycleAlert({
    required String title,
    required String body,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      payCycleChannelId,
      'Siklus Gajian',
      channelDescription: 'Pemberitahuan awal atau berakhirnya siklus gajian',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      id: payCycleAlertId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  @override
  Future<void> showGoalMilestoneAlert({
    required String goalName,
    required int milestonePercent,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      goalMilestoneChannelId,
      'Target Finansial (Goals)',
      channelDescription: 'Pemberitahuan pencapaian milestone target tabungan',
      importance: Importance.high,
      priority: Priority.high,
    );

    await _plugin.show(
      id: goalMilestoneBaseId,
      title: 'Milestone Target Tercapai! 🎉',
      body:
          'Target "$goalName" telah mencapai $milestonePercent%! Tetap konsisten menabung!',
      notificationDetails: const NotificationDetails(android: androidDetails),
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _plugin.cancel(id: id);
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}

/// Provider exposing the singleton [NotificationServiceBase].
final notificationServiceProvider = Provider<NotificationServiceBase>((ref) {
  final service = LocalNotificationService();
  service.initialize();
  return service;
});
