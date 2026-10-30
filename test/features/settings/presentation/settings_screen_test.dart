import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/features/export_import/application/export_import_providers.dart';
import 'package:ledgermate/features/export_import/data/export_import_repository.dart';
import 'package:ledgermate/features/export_import/domain/backup_data.dart';
import 'package:ledgermate/features/notifications/data/notification_service.dart';
import 'package:ledgermate/features/settings/application/settings_providers.dart';
import 'package:ledgermate/features/settings/presentation/settings_screen.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../notifications/fake_notification_service.dart';
import '../fake_settings_repository.dart';

class FakeFilePickerService implements FilePickerService {
  @override
  Future<String?> pickJsonFile() async => null;

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String mimeType = 'application/octet-stream',
  }) async => '/mock/saf/backup.json';
}

class FakeExportImportRepository implements ExportImportRepository {
  @override
  Future<BackupData> createBackupData() async {
    return BackupData(
      exportedAt: DateTime(2026, 10, 29),
      profiles: [],
      payCycles: [],
      categories: [],
      transactions: [],
      financialGoals: [],
      assets: [],
    );
  }

  @override
  Future<String> buildBackupJson() async => '{}';

  @override
  Future<String> buildTransactionsCsv() async => '';

  @override
  String defaultBackupFileName() => 'ledgermate_backup_test.json';

  @override
  String defaultCsvFileName() => 'ledgermate_transaksi_test.csv';

  @override
  Future<String> exportBackupToJson({
    String? targetDirectoryPath,
    String? customFileName,
  }) async => '/mock/backup.json';

  @override
  Future<String> exportTransactionsToCsv({
    String? targetDirectoryPath,
    String? customFileName,
  }) async => '/mock/transaksi.csv';

  @override
  Future<BackupData> validateBackupString(String jsonContent) async {
    return BackupData(
      exportedAt: DateTime(2026, 10, 29),
      profiles: [],
      payCycles: [],
      categories: [],
      transactions: [],
      financialGoals: [],
      assets: [],
    );
  }

  @override
  Future<void> restoreDatabase(BackupData backupData) async {}
}

void main() {
  late FakeSettingsRepository fakeSettingsRepo;
  late FakeNotificationService fakeNotifService;

  setUp(() {
    fakeSettingsRepo = FakeSettingsRepository();
    fakeNotifService = FakeNotificationService();
  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        filePickerServiceProvider.overrideWithValue(FakeFilePickerService()),
        exportImportRepositoryProvider.overrideWithValue(
          FakeExportImportRepository(),
        ),
        settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
        notificationServiceProvider.overrideWithValue(fakeNotifService),
      ],
      child: MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        // M21/Bug 1: `SettingsScreen` is now bare body content (no own
        // `Scaffold`) — wrap it here so ink effects (switches, ListTiles)
        // have a `Material` ancestor, matching what `AppShell` supplies in
        // production.
        home: const Scaffold(body: SettingsScreen()),
      ),
    );
  }

  group(
    'SettingsScreen Widget Tests (Milestone M9 / M10 & FR-08, FR-09, FR-11)',
    () {
      testWidgets(
        'renders appBar and all settings cards (Data, Prefs, Notifs, Categories, Mandatory Expenses, About)',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(
            find.byKey(const ValueKey('data_management_card')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('settings_preferences_card')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('settings_notifications_card')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('settings_category_card')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('settings_mandatory_expenses_card')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('settings_about_card')),
            findsOneWidget,
          );

          expect(find.text('Tampilan & Bahasa'), findsOneWidget);
          expect(find.text('Notifikasi & Pengingat'), findsOneWidget);
          expect(find.text('Kelola Kategori'), findsOneWidget);
          expect(find.text('Pengeluaran Wajib'), findsOneWidget);
          expect(find.text('Tentang LedgerMate'), findsOneWidget);
          expect(find.textContaining('100% Offline'), findsAtLeast(1));
        },
      );

      testWidgets(
        'M19/D18: version string reads dynamically (never the hardcoded '
        '"Versi 1.0.0" literal)',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          // No platform channel mock is registered for package_info_plus in
          // this widget-test harness, so `appPackageInfoProvider` resolves
          // to an AsyncError and the About card falls back to its `error:`
          // branch — which must NOT be the old literal string.
          expect(
            find.text('Versi 1.0.0 (100% Offline, Tanpa Server)'),
            findsNothing,
          );
          expect(find.textContaining('100% Offline'), findsAtLeast(1));
        },
      );

      testWidgets(
        'M19/D18: with package_info mocked, the real version is rendered '
        '(proves this reads from PackageInfo, not a literal)',
        (tester) async {
          PackageInfo.setMockInitialValues(
            appName: 'LedgerMate',
            packageName: 'com.example.ledgermate',
            version: '1.3.0',
            buildNumber: '42',
            buildSignature: '',
          );

          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(find.textContaining('Versi 1.3.0+42'), findsOneWidget);
        },
      );

      testWidgets('toggles dark mode switch and updates theme provider', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1200, 6000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final switchFinder = find.byKey(
          const ValueKey('settings_dark_mode_switch'),
        );
        expect(switchFinder, findsOneWidget);

        await tester.tap(switchFinder);
        await tester.pumpAndSettle();
      });

      testWidgets(
        'toggles language dropdown to English and updates UI text to English',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(
            ProviderScope(
              overrides: [
                filePickerServiceProvider.overrideWithValue(
                  FakeFilePickerService(),
                ),
                exportImportRepositoryProvider.overrideWithValue(
                  FakeExportImportRepository(),
                ),
                settingsRepositoryProvider.overrideWithValue(fakeSettingsRepo),
                notificationServiceProvider.overrideWithValue(fakeNotifService),
              ],
              child: Consumer(
                builder: (context, ref, _) {
                  final locale = ref.watch(appLocaleProvider);
                  return MaterialApp(
                    locale: locale,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    home: const Scaffold(body: SettingsScreen()),
                  );
                },
              ),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Tampilan & Bahasa'), findsOneWidget);

          final langDropdown = find.byType(DropdownButton<AppLanguage>);
          expect(langDropdown, findsOneWidget);

          await tester.tap(langDropdown);
          await tester.pumpAndSettle();

          final enOption = find.text('English').last;
          await tester.tap(enOption);
          await tester.pumpAndSettle();

          expect(find.text('Appearance & Language'), findsOneWidget);
          expect(find.text('Dark Mode'), findsOneWidget);
        },
      );

      testWidgets(
        'toggles notification switches and triggers permission request',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final dailySwitch = find.byKey(
            const ValueKey('settings_daily_reminder_switch'),
          );
          expect(dailySwitch, findsOneWidget);

          await tester.tap(dailySwitch);
          await tester.pumpAndSettle();

          final limitSwitch = find.byKey(
            const ValueKey('settings_limit_alert_switch'),
          );
          expect(limitSwitch, findsOneWidget);
          await tester.tap(limitSwitch);
          await tester.pumpAndSettle();

          final payCycleSwitch = find.byKey(
            const ValueKey('settings_pay_cycle_switch'),
          );
          expect(payCycleSwitch, findsOneWidget);
          await tester.tap(payCycleSwitch);
          await tester.pumpAndSettle();

          final goalSwitch = find.byKey(
            const ValueKey('settings_goal_milestone_switch'),
          );
          expect(goalSwitch, findsOneWidget);
          await tester.tap(goalSwitch);
          await tester.pumpAndSettle();
        },
      );

      testWidgets('opens add category dialog and enters category name', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(1200, 6000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        final addBtn = find.byKey(
          const ValueKey('settings_add_category_button'),
        );
        expect(addBtn, findsOneWidget);

        await tester.tap(addBtn);
        await tester.pumpAndSettle();

        expect(find.text('Tambah Kategori Baru'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('add_category_name_field')),
          findsOneWidget,
        );

        await tester.enterText(
          find.byKey(const ValueKey('add_category_name_field')),
          'Investasi Saham',
        );
        await tester.tap(
          find.byKey(const ValueKey('add_category_confirm_button')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Investasi Saham'), findsOneWidget);
      });

      testWidgets(
        'renders empty message when no mandatory expenses are configured',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(
            find.text('Belum ada pengeluaran wajib ditambahkan.'),
            findsOneWidget,
          );
        },
      );

      testWidgets(
        'renders list of current mandatory expenses with formatted amounts',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          fakeSettingsRepo.profile.mandatoryExpenses = [
            MandatoryExpenseItem()
              ..name = 'Sewa Kos'
              ..amount = 1500000,
            MandatoryExpenseItem()
              ..name = 'Listrik'
              ..amount = 300000,
          ];

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(find.text('Sewa Kos'), findsOneWidget);
          expect(find.text('Rp 1.500.000'), findsOneWidget);
          expect(find.text('Listrik'), findsOneWidget);
          expect(find.text('Rp 300.000'), findsOneWidget);
        },
      );

      testWidgets(
        'opens add mandatory expense dialog, validates, enters data, saves and updates list',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final addBtn = find.byKey(
            const ValueKey('settings_add_mandatory_expense_button'),
          );
          expect(addBtn, findsOneWidget);

          await tester.tap(addBtn);
          await tester.pumpAndSettle();

          expect(find.text('Tambah Pengeluaran Wajib'), findsOneWidget);
          expect(
            find.byKey(const ValueKey('mandatory_expense_name_field')),
            findsOneWidget,
          );
          expect(
            find.byKey(const ValueKey('mandatory_expense_amount_field')),
            findsOneWidget,
          );

          // Attempt save with empty inputs -> shows validation errors
          await tester.tap(
            find.byKey(const ValueKey('save_mandatory_expense_button')),
          );
          await tester.pumpAndSettle();

          expect(find.text('Nama tidak boleh kosong'), findsOneWidget);
          expect(find.text('Jumlah tidak boleh kosong'), findsOneWidget);

          // Enter valid data
          await tester.enterText(
            find.byKey(const ValueKey('mandatory_expense_name_field')),
            'Wi-Fi & Internet',
          );
          await tester.enterText(
            find.byKey(const ValueKey('mandatory_expense_amount_field')),
            '350000',
          );
          await tester.tap(
            find.byKey(const ValueKey('save_mandatory_expense_button')),
          );
          await tester.pumpAndSettle();

          expect(find.text('Wi-Fi & Internet'), findsOneWidget);
          expect(find.text('Rp 350.000'), findsOneWidget);
          expect(
            fakeSettingsRepo.profile.mandatoryExpenses.any(
              (e) => e.name == 'Wi-Fi & Internet' && e.amount == 350000,
            ),
            isTrue,
          );
        },
      );

      testWidgets(
        'opens edit mandatory expense dialog, modifies data, saves and updates list',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          fakeSettingsRepo.profile.mandatoryExpenses = [
            MandatoryExpenseItem()
              ..name = 'Sewa Kos'
              ..amount = 1500000,
          ];

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final editBtn = find.byKey(
            const ValueKey('edit_mandatory_expense_button_0'),
          );
          expect(editBtn, findsOneWidget);

          await tester.tap(editBtn);
          await tester.pumpAndSettle();

          expect(find.text('Ubah Pengeluaran Wajib'), findsOneWidget);

          await tester.enterText(
            find.byKey(const ValueKey('mandatory_expense_name_field')),
            'Sewa Apartemen',
          );
          await tester.enterText(
            find.byKey(const ValueKey('mandatory_expense_amount_field')),
            '2500000',
          );
          await tester.tap(
            find.byKey(const ValueKey('save_mandatory_expense_button')),
          );
          await tester.pumpAndSettle();

          expect(find.text('Sewa Apartemen'), findsOneWidget);
          expect(find.text('Rp 2.500.000'), findsOneWidget);
          expect(
            fakeSettingsRepo.profile.mandatoryExpenses.first.name,
            'Sewa Apartemen',
          );
          expect(
            fakeSettingsRepo.profile.mandatoryExpenses.first.amount,
            2500000,
          );
        },
      );

      testWidgets('tapping item row opens edit dialog', (tester) async {
        tester.view.physicalSize = const Size(1200, 6000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        fakeSettingsRepo.profile.mandatoryExpenses = [
          MandatoryExpenseItem()
            ..name = 'Sewa Kos'
            ..amount = 1500000,
        ];

        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(
          find.byKey(const ValueKey('mandatory_expense_item_0')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Ubah Pengeluaran Wajib'), findsOneWidget);
      });

      testWidgets(
        'opens delete mandatory expense dialog, confirms and removes item',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          fakeSettingsRepo.profile.mandatoryExpenses = [
            MandatoryExpenseItem()
              ..name = 'Tagihan PDAM'
              ..amount = 120000,
          ];

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          final deleteBtn = find.byKey(
            const ValueKey('delete_mandatory_expense_button_0'),
          );
          expect(deleteBtn, findsOneWidget);

          await tester.tap(deleteBtn);
          await tester.pumpAndSettle();

          expect(find.text('Hapus Pengeluaran Wajib?'), findsOneWidget);
          expect(
            find.text('Apakah Anda yakin ingin menghapus "Tagihan PDAM"?'),
            findsOneWidget,
          );

          // Cancel first
          await tester.tap(find.text('Batal'));
          await tester.pumpAndSettle();
          expect(find.text('Tagihan PDAM'), findsOneWidget);
          expect(fakeSettingsRepo.profile.mandatoryExpenses.length, 1);

          // Delete again and confirm
          await tester.tap(deleteBtn);
          await tester.pumpAndSettle();

          await tester.tap(
            find.byKey(
              const ValueKey('delete_mandatory_expense_confirm_button'),
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Tagihan PDAM'), findsNothing);
          expect(
            find.text('Belum ada pengeluaran wajib ditambahkan.'),
            findsOneWidget,
          );
          expect(fakeSettingsRepo.profile.mandatoryExpenses, isEmpty);
        },
      );
    },
  );
}
