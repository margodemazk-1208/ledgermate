import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/database/isar_provider.dart';
import 'core/database/local_profile.dart';
import 'core/error/global_error_handler.dart';
import 'core/presentation/widgets/database_error_screen.dart';
import 'core/theme/theme_provider.dart';
import 'features/notifications/data/notification_service.dart';
import 'features/settings/application/settings_providers.dart';

/// Boots Isar before the widget tree builds — M1 explicitly left this
/// unwired ("left for the milestone that first needs the DB live
/// — likely M2 onboarding", see `core/database/isar_provider.dart`). The
/// real app's storage directory comes from `path_provider`'s
/// `getApplicationDocumentsDirectory()` per that file's own doc comment.
///
/// D18/M17 bug #6: previously had no try/catch around `Isar.open`/the M12
/// migration, and the app registered no global error handler at all — any
/// failure here (corrupted DB file, interrupted write, out of storage)
/// fell through to Flutter's default silent-blank-screen behavior. Now
/// wrapped in `runZonedGuarded` + `FlutterError.onError`/
/// `PlatformDispatcher.onError` (logging, not swallowing), and a boot-time
/// DB-open failure runs [DatabaseErrorScreen] with a retry button instead
/// of `runApp` never being reached with anything to show.
Future<void> main() async {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      installGlobalErrorHandlers();

      await initializeDateFormatting('id_ID');
      // D18/M17 bug #1: must run before ANY notification scheduling —
      // `tz.setLocalLocation` was never called anywhere pre-fix, silently
      // defaulting every scheduled notification to UTC.
      await configureLocalTimezone();

      await _bootApp();
    },
    (error, stack) {
      debugPrint('Uncaught zone error during boot: $error\n$stack');
    },
  );
}

/// Attempts to open Isar and launch the real app; on failure, launches
/// [DatabaseErrorScreen] instead with a retry callback that re-runs this
/// same function (so a transient failure — e.g. storage temporarily full —
/// can be recovered from without force-closing the app).
Future<void> _bootApp() async {
  Isar isar;
  try {
    final directory = await getApplicationDocumentsDirectory();
    isar = await openLedgerMateIsar(directory: directory.path);
  } catch (e, stackTrace) {
    debugPrint('Failed to open local database: $e\n$stackTrace');
    runApp(DatabaseErrorScreen(error: e, onRetry: () => _bootApp()));
    return;
  }

  // D18/M17 bug #3: theme/language were always written to LocalProfile
  // correctly but never re-read on startup, so every restart silently
  // reset both to their hardcoded defaults. Read the persisted profile
  // (if any — fresh installs legitimately have none yet) BEFORE the first
  // frame renders and seed the initial providers from it.
  LocalProfile? profile;
  try {
    profile = await isar.localProfiles.where().findFirst();
  } catch (e) {
    debugPrint('Could not read persisted profile at boot: $e');
  }

  final initialThemeMode = profile != null
      ? themeModeFromSetting(profile.theme)
      : ThemeMode.dark;
  final initialLocale = profile != null
      ? localeFromLanguage(profile.language)
      : const Locale('id');

  runApp(
    ProviderScope(
      overrides: [
        isarProvider.overrideWithValue(isar),
        initialThemeModeProvider.overrideWithValue(initialThemeMode),
        initialAppLocaleProvider.overrideWithValue(initialLocale),
      ],
      child: const LedgerMateApp(),
    ),
  );
}
