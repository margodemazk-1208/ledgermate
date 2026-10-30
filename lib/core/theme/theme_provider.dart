import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/local_profile.dart';
import 'app_theme.dart';

/// Converts the persisted [AppThemeSetting] into Flutter's [ThemeMode].
/// Pure/stateless so it is trivially unit-testable — see D18/M17 bug #3.
ThemeMode themeModeFromSetting(AppThemeSetting setting) {
  return setting == AppThemeSetting.light ? ThemeMode.light : ThemeMode.dark;
}

/// Overridden by `main.dart` with the persisted `LocalProfile.theme` value
/// (read from Isar before `runApp`) so the UI boots in the user's last-saved
/// theme instead of always resetting to the dark default (D18/M17 bug #3:
/// the setting was always written to the DB correctly but never re-read on
/// startup). Defaults to dark (PRD default) when no profile exists yet
/// (fresh install, before onboarding) or in tests that don't override it.
final initialThemeModeProvider = Provider<ThemeMode>((ref) => ThemeMode.dark);

/// Current theme mode. M0 only exposes dark/light via system setting;
/// the manual in-app toggle is FR-09/FR-11, built in M10.
///
/// `StateProvider` moved to Riverpod 3's `legacy.dart` API, so a small
/// `Notifier` is used instead of reaching for the legacy import here.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ref.watch(initialThemeModeProvider);

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final darkThemeProvider = Provider<ThemeData>((ref) => AppTheme.dark);
final lightThemeProvider = Provider<ThemeData>((ref) => AppTheme.light);
