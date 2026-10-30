import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/features/export_import/application/export_import_providers.dart';
import 'package:ledgermate/features/export_import/data/export_import_repository.dart';
import 'package:ledgermate/features/export_import/domain/backup_data.dart';
import 'package:ledgermate/features/notifications/data/notification_service.dart';
import 'package:ledgermate/features/settings/application/settings_providers.dart';
import 'package:ledgermate/features/settings/presentation/settings_screen.dart';

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
      child: const MaterialApp(home: SettingsScreen()),
    );
  }

  group(
    'SettingsScreen Widget Tests (Milestone M9 / M10 & FR-08, FR-09, FR-11)',
    () {
      testWidgets(
        'renders appBar and all 5 settings cards (Data, Prefs, Notifs, Categories, About)',
        (tester) async {
          tester.view.physicalSize = const Size(1200, 6000);
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          await tester.pumpWidget(createTestWidget());
          await tester.pumpAndSettle();

          expect(find.widgetWithText(AppBar, 'Pengaturan'), findsOneWidget);
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
            find.byKey(const ValueKey('settings_about_card')),
            findsOneWidget,
          );

          expect(find.text('Tampilan & Bahasa'), findsOneWidget);
          expect(find.text('Notifikasi & Pengingat'), findsOneWidget);
          expect(find.text('Kelola Kategori'), findsOneWidget);
          expect(find.text('Tentang LedgerMate'), findsOneWidget);
          expect(find.textContaining('100% Offline'), findsAtLeast(1));
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
    },
  );
}
