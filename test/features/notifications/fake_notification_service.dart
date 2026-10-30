import 'package:ledgermate/features/notifications/data/notification_service.dart';

class FakeNotificationService implements NotificationServiceBase {
  bool initialized = false;
  bool permissionGranted = true;
  int requestPermissionCallCount = 0;

  bool? lastDailyReminderEnabled;
  int? lastDailyReminderTime;

  int? lastLimitExceededUangJajan;
  String? lastPayCycleTitle;
  String? lastPayCycleBody;
  String? lastGoalMilestoneName;
  int? lastGoalMilestonePercent;

  final List<Map<String, dynamic>> payCycleAlerts = [];
  final List<Map<String, dynamic>> goalMilestoneAlerts = [];
  final List<int> limitExceededAlerts = [];

  final List<int> cancelledNotificationIds = [];
  bool allCancelled = false;

  @override
  Future<void> initialize() async {
    initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    requestPermissionCallCount++;
    return permissionGranted;
  }

  @override
  Future<void> scheduleDailyReminder({
    required bool enabled,
    required int timeMinutes,
  }) async {
    lastDailyReminderEnabled = enabled;
    lastDailyReminderTime = timeMinutes;
  }

  @override
  Future<void> showLimitExceededAlert({
    required int uangJajanAmanHariIni,
  }) async {
    lastLimitExceededUangJajan = uangJajanAmanHariIni;
    limitExceededAlerts.add(uangJajanAmanHariIni);
  }

  @override
  Future<void> showPayCycleAlert({
    required String title,
    required String body,
  }) async {
    lastPayCycleTitle = title;
    lastPayCycleBody = body;
    payCycleAlerts.add({'title': title, 'body': body});
  }

  @override
  Future<void> showGoalMilestoneAlert({
    required String goalName,
    required int milestonePercent,
  }) async {
    lastGoalMilestoneName = goalName;
    lastGoalMilestonePercent = milestonePercent;
    goalMilestoneAlerts.add({
      'goalName': goalName,
      'milestonePercent': milestonePercent,
    });
  }

  @override
  Future<void> cancel(int id) async {
    cancelledNotificationIds.add(id);
  }

  @override
  Future<void> cancelAll() async {
    allCancelled = true;
  }
}
