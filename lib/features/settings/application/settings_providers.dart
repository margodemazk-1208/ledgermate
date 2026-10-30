import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/category.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../notifications/data/notification_service.dart';
import '../data/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepositoryBase>((ref) {
  final isar = ref.watch(isarProvider);
  final notifService = ref.watch(notificationServiceProvider);
  return SettingsRepository(isar, notifService);
});

final settingsProfileStreamProvider = StreamProvider<LocalProfile?>((ref) {
  return ref.watch(settingsRepositoryProvider).watchProfile();
});

final settingsCategoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(settingsRepositoryProvider).watchCategories();
});

/// Converts the persisted [AppLanguage] into a Flutter [Locale].
/// Pure/stateless so it is trivially unit-testable — see D18/M17 bug #3.
Locale localeFromLanguage(AppLanguage language) {
  return language == AppLanguage.en ? const Locale('en') : const Locale('id');
}

/// Overridden by `main.dart` with the persisted `LocalProfile.language`
/// value (read from Isar before `runApp`) so the UI boots in the user's
/// last-saved language instead of always resetting to Bahasa Indonesia
/// (D18/M17 bug #3). Defaults to `id` (PRD default) when no profile exists
/// yet or in tests that don't override it.
final initialAppLocaleProvider = Provider<Locale>((ref) => const Locale('id'));

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return ref.watch(initialAppLocaleProvider);
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  void setFromLanguage(AppLanguage language) {
    state = localeFromLanguage(language);
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);
