// Regression test for D18/M17 bug #3: theme and language were always
// written to `LocalProfile` correctly, but never re-read on app startup —
// every restart silently reset both to their hardcoded defaults
// (dark/Indonesian) even though the user had changed them in Settings.
// `main.dart` now reads the persisted profile before `runApp` and feeds it
// through `initialThemeModeProvider`/`initialAppLocaleProvider` — this test
// exercises exactly that wiring at the provider level (the same override
// mechanism `main.dart` uses) without needing a real Isar instance.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/theme/theme_provider.dart';
import 'package:ledgermate/features/settings/application/settings_providers.dart';

void main() {
  group('themeModeFromSetting / localeFromLanguage (pure mapping)', () {
    test('maps AppThemeSetting.light/dark to the matching ThemeMode', () {
      expect(themeModeFromSetting(AppThemeSetting.light), ThemeMode.light);
      expect(themeModeFromSetting(AppThemeSetting.dark), ThemeMode.dark);
    });

    test('maps AppLanguage.en/id to the matching Locale', () {
      expect(localeFromLanguage(AppLanguage.en), const Locale('en'));
      expect(localeFromLanguage(AppLanguage.id), const Locale('id'));
    });
  });

  group(
    'initialThemeModeProvider / initialAppLocaleProvider (D18/M17 bug #3)',
    () {
      test('ThemeModeNotifier boots from the overridden initial value instead '
          'of always defaulting to dark, simulating main.dart reading a '
          'persisted light-theme LocalProfile before runApp', () {
        final container = ProviderContainer(
          overrides: [
            initialThemeModeProvider.overrideWithValue(ThemeMode.light),
          ],
        );
        addTearDown(container.dispose);

        expect(container.read(themeModeProvider), ThemeMode.light);
      });

      test('ThemeModeNotifier defaults to dark (PRD default) when nothing '
          'overrides initialThemeModeProvider, e.g. fresh install with no '
          'LocalProfile row yet', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(themeModeProvider), ThemeMode.dark);
      });

      test(
        'AppLocaleNotifier boots from the overridden initial value instead '
        'of always resetting to Bahasa Indonesia, simulating main.dart '
        'reading a persisted English-language LocalProfile before runApp',
        () {
          final container = ProviderContainer(
            overrides: [
              initialAppLocaleProvider.overrideWithValue(const Locale('en')),
            ],
          );
          addTearDown(container.dispose);

          expect(container.read(appLocaleProvider), const Locale('en'));
        },
      );

      test('AppLocaleNotifier defaults to id (PRD default) when nothing '
          'overrides initialAppLocaleProvider', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);

        expect(container.read(appLocaleProvider), const Locale('id'));
      });

      test('manual in-session theme/language changes still work normally on '
          'top of a restored initial value (restoring persisted state must '
          'not break the existing toggle)', () {
        final container = ProviderContainer(
          overrides: [
            initialThemeModeProvider.overrideWithValue(ThemeMode.light),
            initialAppLocaleProvider.overrideWithValue(const Locale('en')),
          ],
        );
        addTearDown(container.dispose);

        container.read(themeModeProvider.notifier).set(ThemeMode.dark);
        expect(container.read(themeModeProvider), ThemeMode.dark);

        container
            .read(appLocaleProvider.notifier)
            .setFromLanguage(AppLanguage.id);
        expect(container.read(appLocaleProvider), const Locale('id'));
      });
    },
  );
}
