import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/features/export_import/application/export_import_providers.dart';
import 'package:ledgermate/features/export_import/data/export_import_repository.dart';
import 'package:ledgermate/features/export_import/domain/backup_data.dart';

class FakeFilePickerService implements FilePickerService {
  String? pickedPath;

  @override
  Future<String?> pickJsonFile() async => pickedPath;
}

class FakeExportImportRepository implements ExportImportRepository {
  String jsonExportPath = '/mock/path/backup.json';
  String csvExportPath = '/mock/path/transactions.csv';
  bool shouldFail = false;
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
  BackupData validateBackupString(String jsonContent) {
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

    test('exportJson handles failure and sets error message', () async {
      fakeRepo.shouldFail = true;
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
  });
}
