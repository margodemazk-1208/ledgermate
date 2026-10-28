// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LedgerMate';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get dataManagement => 'Backup & Restore';

  @override
  String get appearanceAndLanguage => 'Appearance & Language';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'App Language';

  @override
  String get notificationsTitle => 'Notifications & Reminders';

  @override
  String get dailyReminder => 'Daily Logging Reminder';

  @override
  String get limitAlert => 'Daily Limit Exceeded Alert';

  @override
  String get payCycleAlert => 'New Pay Cycle Alert';

  @override
  String get goalMilestoneAlert => 'Goal Milestone Alert';

  @override
  String get categoryManagement => 'Manage Categories';

  @override
  String get aboutTitle => 'About LedgerMate';
}
