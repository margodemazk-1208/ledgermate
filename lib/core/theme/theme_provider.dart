import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_theme.dart';

/// Current theme mode. M0 only exposes dark/light via system setting;
/// the manual in-app toggle is FR-09/FR-11, built in M10.
///
/// `StateProvider` moved to Riverpod 3's `legacy.dart` API, so a small
/// `Notifier` is used instead of reaching for the legacy import here.
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.dark;

  void set(ThemeMode mode) => state = mode;
}

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

final darkThemeProvider = Provider<ThemeData>((ref) => AppTheme.dark);
final lightThemeProvider = Provider<ThemeData>((ref) => AppTheme.light);
