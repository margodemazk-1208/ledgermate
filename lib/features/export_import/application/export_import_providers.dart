import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_provider.dart';
import '../data/export_import_repository.dart';
import '../domain/backup_data.dart';

/// Abstraction over file selection to allow hermetic unit and widget testing.
abstract class FilePickerService {
  Future<String?> pickJsonFile();
}

/// Default implementation of [FilePickerService] using the `file_picker` package.
class SystemFilePickerService implements FilePickerService {
  const SystemFilePickerService();

  @override
  Future<String?> pickJsonFile() async {
    final result = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    return result?.path;
  }
}

final filePickerServiceProvider = Provider<FilePickerService>((ref) {
  return const SystemFilePickerService();
});

final exportImportRepositoryProvider = Provider<ExportImportRepository>((ref) {
  final isar = ref.watch(isarProvider);
  return IsarExportImportRepository(isar: isar);
});

/// State representing an ongoing or completed export/import operation.
class ExportImportState {
  const ExportImportState({
    this.isLoading = false,
    this.lastExportedPath,
    this.errorMessage,
    this.pendingRestore,
  });

  final bool isLoading;
  final String? lastExportedPath;
  final String? errorMessage;
  final BackupData? pendingRestore;

  ExportImportState copyWith({
    bool? isLoading,
    String? lastExportedPath,
    String? errorMessage,
    BackupData? pendingRestore,
    bool clearError = false,
    bool clearPendingRestore = false,
    bool clearLastExportedPath = false,
  }) {
    return ExportImportState(
      isLoading: isLoading ?? this.isLoading,
      lastExportedPath: clearLastExportedPath
          ? null
          : (lastExportedPath ?? this.lastExportedPath),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      pendingRestore: clearPendingRestore
          ? null
          : (pendingRestore ?? this.pendingRestore),
    );
  }
}

class ExportImportNotifier extends Notifier<ExportImportState> {
  @override
  ExportImportState build() {
    return const ExportImportState();
  }

  ExportImportRepository get _repository =>
      ref.read(exportImportRepositoryProvider);
  FilePickerService get _filePicker => ref.read(filePickerServiceProvider);

  /// Exports all data to a JSON backup file.
  Future<String?> exportJson({String? targetDirectoryPath}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLastExportedPath: true,
    );
    try {
      final path = await _repository.exportBackupToJson(
        targetDirectoryPath: targetDirectoryPath,
      );
      state = state.copyWith(isLoading: false, lastExportedPath: path);
      return path;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengekspor data cadangan: $e',
      );
      return null;
    }
  }

  /// Exports transactions and category names to a CSV table file.
  Future<String?> exportCsv({String? targetDirectoryPath}) async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearLastExportedPath: true,
    );
    try {
      final path = await _repository.exportTransactionsToCsv(
        targetDirectoryPath: targetDirectoryPath,
      );
      state = state.copyWith(isLoading: false, lastExportedPath: path);
      return path;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mengekspor riwayat transaksi CSV: $e',
      );
      return null;
    }
  }

  /// Opens the file picker, reads and parses the JSON file, and validates its schema.
  /// If valid, stores it in [state.pendingRestore] so the UI can present
  /// the confirmation dialog with summary statistics.
  Future<BackupData?> pickAndValidateBackup() async {
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      clearPendingRestore: true,
    );
    try {
      final filePath = await _filePicker.pickJsonFile();
      if (filePath == null) {
        state = state.copyWith(isLoading: false);
        return null;
      }

      final file = File(filePath);
      if (!file.existsSync()) {
        throw const BackupValidationException(
          'File cadangan tidak ditemukan pada lokasi yang dipilih.',
        );
      }

      final content = await file.readAsString();
      final backupData = _repository.validateBackupString(content);

      state = state.copyWith(isLoading: false, pendingRestore: backupData);
      return backupData;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e is BackupValidationException
            ? e.message
            : 'Gagal membaca file cadangan: $e',
      );
      return null;
    }
  }

  /// Executes the database restore using [state.pendingRestore] (or provided [backupData]).
  Future<bool> confirmRestore([BackupData? backupData]) async {
    final target = backupData ?? state.pendingRestore;
    if (target == null) {
      state = state.copyWith(
        errorMessage: 'Tidak ada data cadangan yang siap dipulihkan.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      await _repository.restoreDatabase(target);
      state = state.copyWith(isLoading: false, clearPendingRestore: true);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal memulihkan database: $e',
      );
      return false;
    }
  }

  void cancelPendingRestore() {
    state = state.copyWith(clearPendingRestore: true, clearError: true);
  }
}

final exportImportNotifierProvider =
    NotifierProvider<ExportImportNotifier, ExportImportState>(
      ExportImportNotifier.new,
    );
