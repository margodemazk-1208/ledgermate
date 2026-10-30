import 'dart:async';

import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
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

  LocalProfile _cloneProfile(LocalProfile p) {
    return LocalProfile()
      ..id = p.id
      ..fixedSalary = p.fixedSalary
      ..incomeFrequency = p.incomeFrequency
      ..nextPaydayDate = p.nextPaydayDate
      ..incomeIntervalType = p.incomeIntervalType
      ..carryOverBalance = p.carryOverBalance
      ..language = p.language
      ..theme = p.theme
      ..notifDailyReminderEnabled = p.notifDailyReminderEnabled
      ..notifDailyReminderTime = p.notifDailyReminderTime
      ..notifLimitAlertEnabled = p.notifLimitAlertEnabled
      ..notifPayCycleEnabled = p.notifPayCycleEnabled
      ..notifGoalMilestoneEnabled = p.notifGoalMilestoneEnabled
      ..onboardingComplete = p.onboardingComplete
      ..lastRolloverDate = p.lastRolloverDate
      ..lastAccrualDate = p.lastAccrualDate
      ..notificationsBootstrapped = p.notificationsBootstrapped
      ..mandatoryExpenses = p.mandatoryExpenses
          .map(
            (e) => MandatoryExpenseItem()
              ..name = e.name
              ..amount = e.amount,
          )
          .toList();
  }

  void _notifyProfile() {
    _profileController.add(_cloneProfile(profile));
  }

  @override
  Future<LocalProfile> getProfile() async => profile;

  @override
  Stream<LocalProfile?> watchProfile() async* {
    yield _cloneProfile(profile);
    yield* _profileController.stream;
  }

  @override
  Future<void> updateTheme(AppThemeSetting theme) async {
    profile.theme = theme;
    _notifyProfile();
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    profile.language = language;
    _notifyProfile();
  }

  @override
  Future<void> updateDailyReminder({
    required bool enabled,
    required int timeMinutes,
  }) async {
    profile.notifDailyReminderEnabled = enabled;
    profile.notifDailyReminderTime = timeMinutes;
    _notifyProfile();
  }

  @override
  Future<void> updateLimitAlert({required bool enabled}) async {
    profile.notifLimitAlertEnabled = enabled;
    _notifyProfile();
  }

  @override
  Future<void> updatePayCycleAlert({required bool enabled}) async {
    profile.notifPayCycleEnabled = enabled;
    _notifyProfile();
  }

  @override
  Future<void> updateGoalMilestoneAlert({required bool enabled}) async {
    profile.notifGoalMilestoneEnabled = enabled;
    _notifyProfile();
  }

  @override
  Future<void> addMandatoryExpense(String name, int amount) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nama pengeluaran wajib tidak boleh kosong.');
    }
    if (amount <= 0) {
      throw ArgumentError(
        'Jumlah pengeluaran wajib harus lebih besar dari nol.',
      );
    }
    final item = MandatoryExpenseItem()
      ..name = trimmed
      ..amount = amount;
    profile.mandatoryExpenses = [...profile.mandatoryExpenses, item];
    _notifyProfile();
  }

  @override
  Future<void> updateMandatoryExpense(
    int index,
    String name,
    int amount,
  ) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nama pengeluaran wajib tidak boleh kosong.');
    }
    if (amount <= 0) {
      throw ArgumentError(
        'Jumlah pengeluaran wajib harus lebih besar dari nol.',
      );
    }
    if (index < 0 || index >= profile.mandatoryExpenses.length) {
      throw RangeError.index(index, profile.mandatoryExpenses);
    }
    final updatedList = List<MandatoryExpenseItem>.from(
      profile.mandatoryExpenses,
    );
    updatedList[index] = MandatoryExpenseItem()
      ..name = trimmed
      ..amount = amount;
    profile.mandatoryExpenses = updatedList;
    _notifyProfile();
  }

  @override
  Future<void> deleteMandatoryExpense(int index) async {
    if (index < 0 || index >= profile.mandatoryExpenses.length) {
      throw RangeError.index(index, profile.mandatoryExpenses);
    }
    final updatedList = List<MandatoryExpenseItem>.from(
      profile.mandatoryExpenses,
    )..removeAt(index);
    profile.mandatoryExpenses = updatedList;
    _notifyProfile();
  }

  @override
  Future<void> bootstrapDefaultNotificationsIfNeeded() async {
    if (profile.notificationsBootstrapped) return;
    profile.notificationsBootstrapped = true;
    _notifyProfile();
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
