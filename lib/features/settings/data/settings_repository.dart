import 'package:isar_community/isar.dart';

import '../../../core/database/category.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../notifications/data/notification_service.dart';
import '../../transactions/data/transaction_repository.dart';

/// Contract for managing user profile preferences, notifications, and custom categories (FR-09, FR-11).
abstract class SettingsRepositoryBase {
  Future<LocalProfile> getProfile();
  Stream<LocalProfile?> watchProfile();
  Future<void> updateTheme(AppThemeSetting theme);
  Future<void> updateLanguage(AppLanguage language);
  Future<void> updateDailyReminder({
    required bool enabled,
    required int timeMinutes,
  });
  Future<void> updateLimitAlert({required bool enabled});
  Future<void> updatePayCycleAlert({required bool enabled});
  Future<void> updateGoalMilestoneAlert({required bool enabled});

  /// Mandatory expenses management (FR-09, BR-02, M22).
  Future<void> addMandatoryExpense(String name, int amount);
  Future<void> updateMandatoryExpense(int index, String name, int amount);
  Future<void> deleteMandatoryExpense(int index);

  /// D18/M17 bug #2: one-time bootstrap that actually schedules the
  /// default-enabled notifications and proactively requests the Android
  /// 13+ `POST_NOTIFICATIONS` permission, instead of waiting for the user
  /// to manually toggle a Settings switch that already visually shows as
  /// "on". No-ops if already run once for this profile
  /// ([LocalProfile.notificationsBootstrapped]).
  Future<void> bootstrapDefaultNotificationsIfNeeded();

  Stream<List<Category>> watchCategories();
  Future<List<Category>> getCategories();
  Future<Category> addCategory(String name);
  Future<Category> updateCategory(int id, String name);
  Future<bool> deleteCategory(int id);
  Future<bool> isCategoryInUse(int id);
}

class SettingsRepository implements SettingsRepositoryBase {
  SettingsRepository(this._isar, [this._notificationService]);

  final Isar _isar;
  final NotificationServiceBase? _notificationService;

  @override
  Future<LocalProfile> getProfile() async {
    var profile = await _isar.localProfiles.where().findFirst();
    if (profile == null) {
      profile = LocalProfile();
      await _isar.writeTxn(() async {
        final id = await _isar.localProfiles.put(profile!);
        profile!.id = id;
      });
    }
    return profile;
  }

  @override
  Stream<LocalProfile?> watchProfile() {
    return _isar.localProfiles
        .where()
        .watch(fireImmediately: true)
        .map((profiles) => profiles.isNotEmpty ? profiles.first : null);
  }

  @override
  Future<void> updateTheme(AppThemeSetting theme) async {
    final profile = await getProfile();
    profile.theme = theme;
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
  }

  @override
  Future<void> updateLanguage(AppLanguage language) async {
    final profile = await getProfile();
    profile.language = language;
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
  }

  @override
  Future<void> updateDailyReminder({
    required bool enabled,
    required int timeMinutes,
  }) async {
    final profile = await getProfile();
    profile.notifDailyReminderEnabled = enabled;
    profile.notifDailyReminderTime = timeMinutes;
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });

    if (_notificationService != null) {
      await _notificationService.scheduleDailyReminder(
        enabled: enabled,
        timeMinutes: timeMinutes,
      );
    }
  }

  @override
  Future<void> updateLimitAlert({required bool enabled}) async {
    final profile = await getProfile();
    profile.notifLimitAlertEnabled = enabled;
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
  }

  @override
  Future<void> updatePayCycleAlert({required bool enabled}) async {
    final profile = await getProfile();
    profile.notifPayCycleEnabled = enabled;
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
  }

  @override
  Future<void> updateGoalMilestoneAlert({required bool enabled}) async {
    final profile = await getProfile();
    profile.notifGoalMilestoneEnabled = enabled;
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
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
    final profile = await getProfile();
    final item = MandatoryExpenseItem()
      ..name = trimmed
      ..amount = amount;
    profile.mandatoryExpenses = [...profile.mandatoryExpenses, item];
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
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
    final profile = await getProfile();
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
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
  }

  @override
  Future<void> deleteMandatoryExpense(int index) async {
    final profile = await getProfile();
    if (index < 0 || index >= profile.mandatoryExpenses.length) {
      throw RangeError.index(index, profile.mandatoryExpenses);
    }
    final updatedList = List<MandatoryExpenseItem>.from(
      profile.mandatoryExpenses,
    )..removeAt(index);
    profile.mandatoryExpenses = updatedList;
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
  }

  @override
  Future<void> bootstrapDefaultNotificationsIfNeeded() async {
    final profile = await getProfile();
    if (profile.notificationsBootstrapped) return;

    if (_notificationService != null) {
      if (profile.notifDailyReminderEnabled) {
        await _notificationService.requestPermission();
      }
      await _notificationService.scheduleDailyReminder(
        enabled: profile.notifDailyReminderEnabled,
        timeMinutes: profile.notifDailyReminderTime,
      );
    }

    profile.notificationsBootstrapped = true;
    await _isar.writeTxn(() async {
      await _isar.localProfiles.put(profile);
    });
  }

  @override
  Stream<List<Category>> watchCategories() {
    return _isar.categorys.where().watch(fireImmediately: true);
  }

  @override
  Future<List<Category>> getCategories() async {
    final existingCount = await _isar.categorys.count();
    if (existingCount == 0) {
      await _seedDefaultCategories();
    }
    return _isar.categorys.where().findAll();
  }

  Future<void> _seedDefaultCategories() async {
    await _isar.writeTxn(() async {
      for (final name in defaultCategoryNames) {
        final cat = Category()
          ..name = name
          ..isDefault = true;
        await _isar.categorys.put(cat);
      }
    });
  }

  @override
  Future<Category> addCategory(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nama kategori tidak boleh kosong.');
    }

    final categories = await _isar.categorys.where().findAll();
    final duplicate = categories.any(
      (c) => c.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicate) {
      throw ArgumentError('Kategori "$trimmed" sudah ada.');
    }

    final newCat = Category()
      ..name = trimmed
      ..isDefault = false;

    await _isar.writeTxn(() async {
      final id = await _isar.categorys.put(newCat);
      newCat.id = id;
    });

    return newCat;
  }

  @override
  Future<Category> updateCategory(int id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError('Nama kategori tidak boleh kosong.');
    }

    final cat = await _isar.categorys.get(id);
    if (cat == null) {
      throw ArgumentError('Kategori tidak ditemukan.');
    }

    final categories = await _isar.categorys.where().findAll();
    final duplicate = categories.any(
      (c) => c.id != id && c.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (duplicate) {
      throw ArgumentError('Kategori "$trimmed" sudah digunakan.');
    }

    cat.name = trimmed;
    await _isar.writeTxn(() async {
      await _isar.categorys.put(cat);
    });

    return cat;
  }

  @override
  Future<bool> deleteCategory(int id) async {
    final cat = await _isar.categorys.get(id);
    if (cat == null) return false;

    if (cat.isDefault || cat.isSystemGenerated) {
      throw StateError('Kategori bawaan sistem tidak dapat dihapus.');
    }

    final inUse = await isCategoryInUse(id);
    if (inUse) {
      throw StateError(
        'Kategori tidak dapat dihapus karena masih digunakan oleh transaksi.',
      );
    }

    return _isar.writeTxn(() async {
      return _isar.categorys.delete(id);
    });
  }

  @override
  Future<bool> isCategoryInUse(int id) async {
    final count = await _isar.transactions
        .filter()
        .categoryIdEqualTo(id)
        .count();
    return count > 0;
  }
}
