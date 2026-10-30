import 'dart:async';

import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/features/settings/data/settings_repository.dart';

class FakeSettingsRepository implements SettingsRepositoryBase {
  FakeSettingsRepository({
    LocalProfile? initialProfile,
    List<Category>? initialCategories,
  }) : profile = initialProfile ?? LocalProfile(),
       categories =
           initialCategories ??
           [
             Category()
               ..id = 1
               ..name = 'Makan & Minum'
               ..isDefault = true,
             Category()
               ..id = 2
               ..name = 'Transportasi'
               ..isDefault = true,
             Category()
               ..id = 99
               ..name = 'Kustom Test'
               ..isDefault = false,
           ] {
    _profileController = StreamController<LocalProfile?>.broadcast();
    _categoriesController = StreamController<List<Category>>.broadcast();
  }

  LocalProfile profile;
  List<Category> categories;
  late final StreamController<LocalProfile?> _profileController;
  late final StreamController<List<Category>> _categoriesController;

  @override
  Future<LocalProfile> getProfile() async => profile;

  @override
  Stream<LocalProfile?> watchProfile() async* {
    yield profile;
    yield* _profileController.stream;
  }

  @override
  Future<void> updateTheme(AppThemeSetting theme) async {
    profile.theme = theme;
    _profileController.add(profile);
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    profile.language = language;
    _profileController.add(profile);
  }

  @override
  Future<void> updateDailyReminder({
    required bool enabled,
    required int timeMinutes,
  }) async {
    profile.notifDailyReminderEnabled = enabled;
    profile.notifDailyReminderTime = timeMinutes;
    _profileController.add(profile);
  }

  @override
  Future<void> updateLimitAlert({required bool enabled}) async {
    profile.notifLimitAlertEnabled = enabled;
    _profileController.add(profile);
  }

  @override
  Future<void> updatePayCycleAlert({required bool enabled}) async {
    profile.notifPayCycleEnabled = enabled;
    _profileController.add(profile);
  }

  @override
  Future<void> updateGoalMilestoneAlert({required bool enabled}) async {
    profile.notifGoalMilestoneEnabled = enabled;
    _profileController.add(profile);
  }

  @override
  Future<void> bootstrapDefaultNotificationsIfNeeded() async {
    if (profile.notificationsBootstrapped) return;
    profile.notificationsBootstrapped = true;
    _profileController.add(profile);
  }

  @override
  Stream<List<Category>> watchCategories() async* {
    yield List.unmodifiable(categories);
    yield* _categoriesController.stream;
  }

  @override
  Future<List<Category>> getCategories() async => List.unmodifiable(categories);

  @override
  Future<Category> addCategory(String name) async {
    final cat = Category()
      ..id = categories.length + 1
      ..name = name
      ..isDefault = false;
    categories.add(cat);
    _categoriesController.add(List.unmodifiable(categories));
    return cat;
  }

  @override
  Future<Category> updateCategory(int id, String name) async {
    final cat = categories.firstWhere((c) => c.id == id);
    cat.name = name;
    _categoriesController.add(List.unmodifiable(categories));
    return cat;
  }

  @override
  Future<bool> deleteCategory(int id) async {
    categories.removeWhere((c) => c.id == id);
    _categoriesController.add(List.unmodifiable(categories));
    return true;
  }

  @override
  Future<bool> isCategoryInUse(int id) async => false;
}
