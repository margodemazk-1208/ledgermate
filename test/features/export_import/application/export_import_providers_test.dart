import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/features/export_import/application/export_import_providers.dart';
import 'package:ledgermate/features/export_import/data/export_import_repository.dart';
import 'package:ledgermate/features/export_import/domain/backup_data.dart';

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
  String jsonExportPath = '/mock/path/backup.json';
  String csvExportPath = '/mock/path/transactions.csv';
  bool shouldFail = false;
  // D18/M17 bug #9: separate from `shouldFail` (which only governs the
  // direct-path `exportBackupToJson`/`exportTransactionsToCsv` writes) so
  // tests can simulate "direct write fails, SAF fallback succeeds" as well
  // as "both fail" without the two being coupled.
  bool buildShouldFail = false;
  BackupData? lastRestored;
  BackupData? dataToReturn;

  @override
  Future<BackupData> createBackupData() async {
    return dataToReturn ??
        BackupData(
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
    if (shouldFail) throw Exception('Simulated JSON export failure');
    return jsonExportPath;
  }

  @override
  Future<String> exportTransactionsToCsv({
    String? targetDirectoryPath,
    String? customFileName,
  }) async {
    if (shouldFail) throw Exception('Simulated CSV export failure');
    return csvExportPath;
  }

  @override
  Future<BackupData> validateBackupString(String jsonContent) async {
    if (shouldFail) throw const BackupValidationException('Invalid content');
    return dataToReturn ??
        BackupData(
          exportedAt: DateTime(2026, 10, 29),
          profiles: [],
          payCycles: [],
          categories: [
            Category()
              ..id = 1
              ..name = 'Test',
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
  late ProviderContainer container;
  late FakeFilePickerService fakePicker;
  late FakeExportImportRepository fakeRepo;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('notifier_test_');
    fakePicker = FakeFilePickerService();
    fakeRepo = FakeExportImportRepository();

    container = ProviderContainer(
      overrides: [
        filePickerServiceProvider.overrideWithValue(fakePicker),
        exportImportRepositoryProvider.overrideWithValue(fakeRepo),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('ExportImportNotifier (FR-08 Application)', () {
    test('initial state is idle with no errors or paths', () {
      final state = container.read(exportImportNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.lastExportedPath, isNull);
      expect(state.errorMessage, isNull);
      expect(state.pendingRestore, isNull);
    });

    test('exportJson succeeds and records path in state', () async {
      final notifier = container.read(exportImportNotifierProvider.notifier);
      final path = await notifier.exportJson();

      expect(path, '/mock/path/backup.json');
      final state = container.read(exportImportNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.lastExportedPath, '/mock/path/backup.json');
      expect(state.errorMessage, isNull);
    });

    test('exportJson surfaces an error when BOTH the direct write AND the '
        'SAF fallback fail (D18/M17 bug #9 added the fallback — a direct '
        'write failure alone no longer surfaces as an error on its own, see '
        'the dedicated "Export SAF fallback" group below)', () async {
      fakeRepo.shouldFail = true;
      fakeRepo.buildShouldFail = true;
      final notifier = container.read(exportImportNotifierProvider.notifier);
      final path = await notifier.exportJson();

      expect(path, isNull);
      final state = container.read(exportImportNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.errorMessage, contains('Gagal mengekspor data cadangan'));
    });

    test('exportCsv succeeds and records path in state', () async {
      final notifier = container.read(exportImportNotifierProvider.notifier);
      final path = await notifier.exportCsv();

      expect(path, '/mock/path/transactions.csv');
      final state = container.read(exportImportNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.lastExportedPath, '/mock/path/transactions.csv');
      expect(state.errorMessage, isNull);
    });

    test(
      'pickAndValidateBackup returns null when user cancels picker',
      () async {
        fakePicker.pickedPath = null;
        final notifier = container.read(exportImportNotifierProvider.notifier);
        final result = await notifier.pickAndValidateBackup();

        expect(result, isNull);
        final state = container.read(exportImportNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.pendingRestore, isNull);
        expect(state.errorMessage, isNull);
      },
    );

    test(
      'pickAndValidateBackup populates pendingRestore when file is valid',
      () async {
        final validFile = File('${tempDir.path}/backup.json');
        await validFile.writeAsString('{"dummy": true}');
        fakePicker.pickedPath = validFile.path;

        final notifier = container.read(exportImportNotifierProvider.notifier);
        final result = await notifier.pickAndValidateBackup();

        expect(result, isNotNull);
        final state = container.read(exportImportNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.pendingRestore, isNotNull);
        expect(state.pendingRestore!.categories.length, 1);
      },
    );

    test('pickAndValidateBackup catches validation exceptions and displays message', () async {
      final validFile = File('${tempDir.path}/bad_backup.json');
      await validFile.writeAsString('corrupted');
      fakePicker.pickedPath = validFile.path;
      fakeRepo.shouldFail = true;

      final notifier = container.read(exportImportNotifierProvider.notifier);
      final result = await notifier.pickAndValidateBackup();

      expect(result, isNull);
      final state = container.read(exportImportNotifierProvider);
      expect(state.isLoading, isFalse);
      expect(state.pendingRestore, isNull);
      expect(state.errorMessage, contains('Invalid content'));
    });

    test(
      'confirmRestore restores data and clears pendingRestore on success',
      () async {
        final backupData = BackupData(
          exportedAt: DateTime(2026, 10, 29),
          profiles: [],
          payCycles: [],
          categories: [],
          transactions: [],
          financialGoals: [],
          assets: [],
        );

        final notifier = container.read(exportImportNotifierProvider.notifier);
        final success = await notifier.confirmRestore(backupData);

        expect(success, isTrue);
        expect(fakeRepo.lastRestored, backupData);
        final state = container.read(exportImportNotifierProvider);
        expect(state.pendingRestore, isNull);
        expect(state.errorMessage, isNull);
      },
    );

    test('cancelPendingRestore resets pendingRestore state', () {
      final notifier = container.read(exportImportNotifierProvider.notifier);
      notifier.cancelPendingRestore();
      final state = container.read(exportImportNotifierProvider);
      expect(state.pendingRestore, isNull);
      expect(state.errorMessage, isNull);
    });

    // D18/M17 bug #9: direct-path writes to the public Downloads folder are
    // unreliable on some Android 7-10 (API 24-29) devices/OEMs. When the
    // direct write throws, `exportJson`/`exportCsv` must fall back to the
    // Storage Access Framework "save as" picker instead of just surfacing
    // an error.
    group('Export SAF fallback (D18/M17 bug #9)', () {
      test('exportJson falls back to the SAF picker when the direct write '
          'throws, and records the SAF path on success', () async {
        fakeRepo.shouldFail = true;
        fakePicker.savedPath = '/saf/uri/backup.json';

        final notifier = container.read(exportImportNotifierProvider.notifier);
        final path = await notifier.exportJson();

        expect(path, '/saf/uri/backup.json');
        final state = container.read(exportImportNotifierProvider);
        expect(state.lastExportedPath, '/saf/uri/backup.json');
        expect(state.errorMessage, isNull);
      });

      test('exportCsv falls back to the SAF picker when the direct write '
          'throws, and records the SAF path on success', () async {
        fakeRepo.shouldFail = true;
        fakePicker.savedPath = '/saf/uri/transaksi.csv';

        final notifier = container.read(exportImportNotifierProvider.notifier);
        final path = await notifier.exportCsv();

        expect(path, '/saf/uri/transaksi.csv');
        final state = container.read(exportImportNotifierProvider);
        expect(state.lastExportedPath, '/saf/uri/transaksi.csv');
      });

      test('treats a user-cancelled SAF picker as a plain cancellation, not '
          'an error', () async {
        fakeRepo.shouldFail = true;
        fakePicker.savedPath = null; // user backed out of the picker

        final notifier = container.read(exportImportNotifierProvider.notifier);
        final path = await notifier.exportJson();

        expect(path, isNull);
        final state = container.read(exportImportNotifierProvider);
        expect(state.isLoading, isFalse);
        expect(state.errorMessage, isNull);
      });

      test('surfaces an error only when BOTH the direct write and the SAF '
          'fallback fail', () async {
        fakeRepo.shouldFail = true;
        fakeRepo.buildShouldFail = true;
        final notifier = container.read(exportImportNotifierProvider.notifier);
        final path = await notifier.exportJson();

        expect(path, isNull);
        final state = container.read(exportImportNotifierProvider);
        expect(state.errorMessage, contains('Gagal mengekspor data cadangan'));
        expect(state.errorMessage, contains('fallback juga gagal'));
      });
    });
  });
}
