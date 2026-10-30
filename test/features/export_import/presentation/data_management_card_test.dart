import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/features/export_import/application/export_import_providers.dart';
import 'package:ledgermate/features/export_import/data/export_import_repository.dart';
import 'package:ledgermate/features/export_import/domain/backup_data.dart';
import 'package:ledgermate/features/export_import/presentation/widgets/data_management_card.dart';
import 'package:ledgermate/features/export_import/presentation/widgets/restore_confirmation_dialog.dart';

class FakeFilePickerService implements FilePickerService {
  String? pickedPath;
  String? savedPath = '/mock/saf/backup.json';

  @override
  Future<String?> pickJsonFile() async => pickedPath;

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String mimeType = 'application/octet-stream',
  }) async => savedPath;
}

class FakeExportImportRepository implements ExportImportRepository {
  String jsonExportPath = '/storage/emulated/0/Download/ledgermate_backup.json';
  String csvExportPath =
      '/storage/emulated/0/Download/ledgermate_transaksi.csv';
  bool shouldFail = false;
  bool buildShouldFail = false;
  BackupData? lastRestored;

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
  Future<String> buildBackupJson() async {
    if (buildShouldFail) throw Exception('Simulated JSON build failure');
    return '{}';
  }

  @override
  Future<String> buildTransactionsCsv() async {
    if (buildShouldFail) throw Exception('Simulated CSV build failure');
    return '';
  }

  @override
  String defaultBackupFileName() => 'ledgermate_backup_test.json';

  @override
  String defaultCsvFileName() => 'ledgermate_transaksi_test.csv';

  @override
  Future<String> exportBackupToJson({
    String? targetDirectoryPath,
    String? customFileName,
  }) async {
    if (shouldFail) throw Exception('Simulated JSON failure');
    return jsonExportPath;
  }

  @override
  Future<String> exportTransactionsToCsv({
    String? targetDirectoryPath,
    String? customFileName,
  }) async {
    if (shouldFail) throw Exception('Simulated CSV failure');
    return csvExportPath;
  }

  @override
  BackupData validateBackupString(String jsonContent) {
    if (shouldFail) throw const BackupValidationException('Invalid content');
    return BackupData(
      exportedAt: DateTime(2026, 10, 29, 12, 0),
      profiles: [],
      payCycles: [],
      categories: [
        Category()
          ..id = 1
          ..name = 'Makanan',
      ],
      transactions: [],
      financialGoals: [],
      assets: [],
    );
  }

  @override
  Future<void> restoreDatabase(BackupData backupData) async {
    if (shouldFail) throw Exception('Simulated restore failure');
    lastRestored = backupData;
  }
}

void main() {
  late FakeFilePickerService fakePicker;
  late FakeExportImportRepository fakeRepo;

  setUp(() {
    fakePicker = FakeFilePickerService();
    fakeRepo = FakeExportImportRepository();
  });

  Widget createTestWidget({Widget? child}) {
    return ProviderScope(
      overrides: [
        filePickerServiceProvider.overrideWithValue(fakePicker),
        exportImportRepositoryProvider.overrideWithValue(fakeRepo),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: child ?? const DataManagementCard(),
          ),
        ),
      ),
    );
  }

  group('DataManagementCard Widget Tests (FR-08 UI)', () {
    testWidgets('renders all three actions and card headers', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Cadangkan & Pulihkan Data'), findsOneWidget);
      expect(find.byKey(const ValueKey('export_json_button')), findsOneWidget);
      expect(find.byKey(const ValueKey('export_csv_button')), findsOneWidget);
      expect(
        find.byKey(const ValueKey('restore_backup_button')),
        findsOneWidget,
      );
    });

    testWidgets(
      'tapping export JSON triggers export and shows success banner',
      (tester) async {
        await tester.pumpWidget(createTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('export_json_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('export_success_banner')),
          findsOneWidget,
        );
        expect(find.textContaining('ledgermate_backup.json'), findsWidgets);
      },
    );

    testWidgets('tapping export CSV triggers export and shows success banner', (
      tester,
    ) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('export_csv_button')));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const ValueKey('export_success_banner')),
        findsOneWidget,
      );
      expect(find.textContaining('ledgermate_transaksi.csv'), findsWidgets);
    });

    testWidgets('renders error banner when export fails', (tester) async {
      fakeRepo.shouldFail = true;
      fakeRepo.buildShouldFail = true;

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('export_json_button')));
      await tester.pumpAndSettle();

      expect(find.byKey(const ValueKey('export_error_banner')), findsOneWidget);
      expect(find.textContaining('Simulated JSON failure'), findsOneWidget);
    });
  });

  group('RestoreConfirmationDialog Widget Tests (FR-08 Safety Pre-Check)', () {
    testWidgets('displays summary data and calls callbacks', (tester) async {
      final summary = BackupSummary(
        exportedAt: DateTime(2026, 10, 29, 14, 30),
        hasProfile: true,
        payCycleCount: 2,
        categoryCount: 8,
        transactionCount: 45,
        goalCount: 3,
        assetCount: 4,
      );

      bool confirmed = false;
      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RestoreConfirmationDialog(
              summary: summary,
              onConfirm: () => confirmed = true,
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Konfirmasi Pemulihan Data'), findsOneWidget);
      expect(
        find.text(
          'PERHATIAN: Pemulihan akan menghapus dan menimpa SELURUH data lokal saat ini. Tindakan ini tidak dapat dibatalkan.',
        ),
        findsOneWidget,
      );
      expect(find.text('45 transaksi'), findsOneWidget);
      expect(find.text('8 kategori'), findsOneWidget);
      expect(find.text('3 target'), findsOneWidget);
      expect(find.text('4 aset'), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('restore_confirm_button')));
      expect(confirmed, isTrue);

      await tester.tap(find.byKey(const ValueKey('restore_cancel_button')));
      expect(cancelled, isTrue);
    });
  });
}
