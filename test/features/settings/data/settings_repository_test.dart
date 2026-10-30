import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/accrual/daily_accrual_service.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/settings/data/settings_repository.dart';

import '../../notifications/fake_notification_service.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late FakeNotificationService fakeNotifService;
  late SettingsRepository repository;
  var instanceCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'ledgermate_settings_repo_test_',
    );
    instanceCounter++;
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'settings_repo_test_$instanceCounter',
    );
    fakeNotifService = FakeNotificationService();
    repository = SettingsRepository(isar, fakeNotifService);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('SettingsRepository - Profile & Preferences (FR-09, FR-11)', () {
    test('getProfile creates default LocalProfile if none exists', () async {
      final profile = await repository.getProfile();
      expect(profile, isNotNull);
      expect(profile.notifDailyReminderEnabled, isTrue);
      expect(profile.notifDailyReminderTime, 1260);
      expect(profile.language, AppLanguage.id);
      expect(profile.theme, AppThemeSetting.dark);
    });

    test('updateTheme updates and persists theme setting', () async {
      await repository.updateTheme(AppThemeSetting.light);
      final profile = await repository.getProfile();
      expect(profile.theme, AppThemeSetting.light);
    });

    test('updateLanguage updates and persists app language', () async {
      await repository.updateLanguage(AppLanguage.en);
      final profile = await repository.getProfile();
      expect(profile.language, AppLanguage.en);
    });

    test(
      'updateDailyReminder updates profile and schedules notification',
      () async {
        await repository.updateDailyReminder(
          enabled: true,
          timeMinutes: 20 * 60 + 30,
        );
        final profile = await repository.getProfile();
        expect(profile.notifDailyReminderEnabled, isTrue);
        expect(profile.notifDailyReminderTime, 1230);
        expect(fakeNotifService.lastDailyReminderEnabled, isTrue);
        expect(fakeNotifService.lastDailyReminderTime, 1230);
      },
    );

    test(
      'updateLimitAlert, updatePayCycleAlert, updateGoalMilestoneAlert persist',
      () async {
        await repository.updateLimitAlert(enabled: false);
        await repository.updatePayCycleAlert(enabled: false);
        await repository.updateGoalMilestoneAlert(enabled: false);

        final profile = await repository.getProfile();
        expect(profile.notifLimitAlertEnabled, isFalse);
        expect(profile.notifPayCycleEnabled, isFalse);
        expect(profile.notifGoalMilestoneEnabled, isFalse);
      },
    );

    // D18/M17 bug #2 regression: default-enabled notifications were never
    // actually scheduled, and the POST_NOTIFICATIONS permission was never
    // requested, until the user manually toggled a Settings switch that
    // already visually showed as "on" — so a fresh install's reminders
    // silently never fired.
    group('bootstrapDefaultNotificationsIfNeeded (D18/M17 bug #2)', () {
      test('schedules the default-enabled daily reminder and requests '
          'permission on first run', () async {
        final profileBefore = await repository.getProfile();
        expect(profileBefore.notificationsBootstrapped, isFalse);
        expect(profileBefore.notifDailyReminderEnabled, isTrue);

        await repository.bootstrapDefaultNotificationsIfNeeded();

        expect(fakeNotifService.requestPermissionCallCount, 1);
        expect(fakeNotifService.lastDailyReminderEnabled, isTrue);
        expect(fakeNotifService.lastDailyReminderTime, 1260);

        final profileAfter = await repository.getProfile();
        expect(profileAfter.notificationsBootstrapped, isTrue);
      });

      test('is a no-op on a second call (idempotent)', () async {
        await repository.bootstrapDefaultNotificationsIfNeeded();
        expect(fakeNotifService.requestPermissionCallCount, 1);

        await repository.bootstrapDefaultNotificationsIfNeeded();
        // Still 1 — the second call must short-circuit on the persisted
        // `notificationsBootstrapped` flag, not request permission again.
        expect(fakeNotifService.requestPermissionCallCount, 1);
      });

      test('does not request permission when the daily reminder is disabled, '
          'but still records the bootstrap as done', () async {
        await repository.updateDailyReminder(enabled: false, timeMinutes: 1260);
        // updateDailyReminder's own scheduleDailyReminder call above
        // doesn't touch notificationsBootstrapped — confirm the
        // bootstrap flow still runs correctly afterward.
        final profileBefore = await repository.getProfile();
        expect(profileBefore.notificationsBootstrapped, isFalse);

        await repository.bootstrapDefaultNotificationsIfNeeded();

        expect(fakeNotifService.requestPermissionCallCount, 0);
        final profileAfter = await repository.getProfile();
        expect(profileAfter.notificationsBootstrapped, isTrue);
      });
    });
  });

  group('SettingsRepository - Category CRUD (FR-09)', () {
    test(
      'getCategories seeds default categories when collection is empty',
      () async {
        final cats = await repository.getCategories();
        expect(cats.length, greaterThanOrEqualTo(5));
        expect(cats.any((c) => c.name == 'Makan' && c.isDefault), isTrue);
      },
    );

    test(
      'addCategory creates custom category and validates duplicates/empty',
      () async {
        final newCat = await repository.addCategory('Investasi Saham');
        expect(newCat.id, greaterThan(0));
        expect(newCat.name, 'Investasi Saham');
        expect(newCat.isDefault, isFalse);

        expect(() => repository.addCategory('   '), throwsArgumentError);
        expect(
          () => repository.addCategory('investasi saham'),
          throwsArgumentError,
        );
      },
    );

    test('updateCategory modifies category name and validates', () async {
      final newCat = await repository.addCategory('Crypto');
      final updated = await repository.updateCategory(
        newCat.id,
        'Cryptocurrency',
      );
      expect(updated.name, 'Cryptocurrency');

      expect(
        () => repository.updateCategory(newCat.id, '  '),
        throwsArgumentError,
      );
    });

    test('deleteCategory fails for default built-in category', () async {
      final cats = await repository.getCategories();
      final defaultCat = cats.firstWhere((c) => c.isDefault);

      expect(() => repository.deleteCategory(defaultCat.id), throwsStateError);
    });

    test('deleteCategory fails if category is used by transaction', () async {
      final customCat = await repository.addCategory('Donasi');

      final tx = db.Transaction()
        ..amount = 50000
        ..type = db.TransactionType.expense
        ..categoryId = customCat.id
        ..date = DateTime.now();
      await isar.writeTxn(() => isar.transactions.put(tx));

      expect(() => repository.deleteCategory(customCat.id), throwsStateError);
    });

    test('deleteCategory succeeds for unused custom category', () async {
      final customCat = await repository.addCategory('Hobi');
      final deleted = await repository.deleteCategory(customCat.id);
      expect(deleted, isTrue);

      final cats = await repository.getCategories();
      expect(cats.any((c) => c.id == customCat.id), isFalse);
    });
  });

  group('SettingsRepository - Mandatory Expenses CRUD (FR-09, BR-02, M22)', () {
    test('addMandatoryExpense adds item to profile and validates', () async {
      await repository.addMandatoryExpense('Sewa Kos', 1500000);
      var profile = await repository.getProfile();
      expect(profile.mandatoryExpenses.length, 1);
      expect(profile.mandatoryExpenses.first.name, 'Sewa Kos');
      expect(profile.mandatoryExpenses.first.amount, 1500000);

      await repository.addMandatoryExpense('Listrik', 300000);
      profile = await repository.getProfile();
      expect(profile.mandatoryExpenses.length, 2);
      expect(profile.mandatoryExpenses[1].name, 'Listrik');
      expect(profile.mandatoryExpenses[1].amount, 300000);

      expect(
        () => repository.addMandatoryExpense('   ', 100000),
        throwsArgumentError,
      );
      expect(
        () => repository.addMandatoryExpense('Air', 0),
        throwsArgumentError,
      );
      expect(
        () => repository.addMandatoryExpense('Air', -50000),
        throwsArgumentError,
      );
    });

    test(
      'updateMandatoryExpense updates item at index and validates',
      () async {
        await repository.addMandatoryExpense('Sewa Kos', 1500000);
        await repository.addMandatoryExpense('Listrik', 300000);

        await repository.updateMandatoryExpense(0, 'Sewa Apartemen', 2000000);
        final profile = await repository.getProfile();
        expect(profile.mandatoryExpenses.first.name, 'Sewa Apartemen');
        expect(profile.mandatoryExpenses.first.amount, 2000000);
        expect(profile.mandatoryExpenses[1].name, 'Listrik');

        expect(
          () => repository.updateMandatoryExpense(0, '', 100000),
          throwsArgumentError,
        );
        expect(
          () => repository.updateMandatoryExpense(0, 'Test', 0),
          throwsArgumentError,
        );
        expect(
          () => repository.updateMandatoryExpense(5, 'Test', 100000),
          throwsRangeError,
        );
        expect(
          () => repository.updateMandatoryExpense(-1, 'Test', 100000),
          throwsRangeError,
        );
      },
    );

    test(
      'deleteMandatoryExpense removes item at index and validates bounds',
      () async {
        await repository.addMandatoryExpense('Sewa Kos', 1500000);
        await repository.addMandatoryExpense('Listrik', 300000);

        await repository.deleteMandatoryExpense(0);
        var profile = await repository.getProfile();
        expect(profile.mandatoryExpenses.length, 1);
        expect(profile.mandatoryExpenses.first.name, 'Listrik');
        expect(profile.mandatoryExpenses.first.amount, 300000);

        await repository.deleteMandatoryExpense(0);
        profile = await repository.getProfile();
        expect(profile.mandatoryExpenses, isEmpty);

        expect(() => repository.deleteMandatoryExpense(0), throwsRangeError);
      },
    );

    test('regression: mandatory expense added via settings affects Mode B daily carry-over accrual calculation', () async {
      final profile = await repository.getProfile();
      profile.incomeFrequency = IncomeFrequency.daily;
      profile.onboardingComplete = true;
      profile.lastAccrualDate = DateTime(2026, 10, 27);
      profile.carryOverBalance = 200000;
      await isar.writeTxn(() => isar.localProfiles.put(profile));

      final wallet = Wallet()
        ..name = 'Dompet Utama'
        ..startingBalance = 500000
        ..includeInDailyBudget = true;
      await isar.writeTxn(() => isar.wallets.put(wallet));

      final incomeTx = db.Transaction()
        ..amount = 150000
        ..type = db.TransactionType.income
        ..walletId = wallet.id
        ..date = DateTime(2026, 10, 28, 10, 0);
      await isar.writeTxn(() => isar.transactions.put(incomeTx));

      await repository.addMandatoryExpense('Paket Data Harian', 50000);

      final accrualService = DailyAccrualService(isar);
      await accrualService.runCatchUp(referenceNow: DateTime(2026, 10, 28));

      final updatedProfile = await repository.getProfile();
      expect(updatedProfile.carryOverBalance, 300000);
      expect(updatedProfile.lastAccrualDate, DateTime(2026, 10, 28));
    });
  });
}
