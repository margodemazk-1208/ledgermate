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

class AppLocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    return const Locale('id');
  }

  void setLocale(Locale locale) {
    state = locale;
  }

  void setFromLanguage(AppLanguage language) {
    state = language == AppLanguage.en
        ? const Locale('en')
        : const Locale('id');
  }
}

final appLocaleProvider = NotifierProvider<AppLocaleNotifier, Locale>(
  AppLocaleNotifier.new,
);
