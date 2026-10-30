import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_provider.dart';
import '../data/export_import_repository.dart';
import '../domain/backup_data.dart';

/// Abstraction over file selection to allow hermetic unit and widget testing.
abstract class FilePickerService {
  Future<String?> pickJsonFile();

  /// D18/M17 bug #9: direct `File` writes to the public Downloads folder
  /// are unreliable on Android 7-10 (API 24-29) — pre-scoped-storage API
  /// levels require the `WRITE_EXTERNAL_STORAGE` permission for that path,
  /// which this app deliberately does NOT declare (requesting broad
  /// storage access for a single export feature goes against the
  /// offline/minimal-permissions posture — D9's "nothing leaves the
  /// device" spirit). The Storage Access Framework "save as" picker works
  /// on every API level without that permission, so it is the fallback
  /// used when the direct-path write throws. Returns the saved file's
  /// path/URI, or `null` if the user cancelled the picker.
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String mimeType = 'application/octet-stream',
  });
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

  @override
  Future<String?> saveFile({
    required String fileName,
    required String content,
    String mimeType = 'application/octet-stream',
  }) async {
    final uri = await FilePicker.saveFile(
      fileName: fileName,
      bytes: Uint8List.fromList(utf8.encode(content)),
      mimeType: mimeType,
    );
    return uri?.toString();
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
  ///
  /// D18/M17 bug #9: tries the direct-path write first (fast, no user
  /// interaction — works fine on Android 11+ and most 7-10 devices too),
  /// and falls back to the Storage Access Framework "save as" picker if
  /// that throws (the unreliable case on some Android 7-10 devices/OEMs).
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
    } catch (directWriteError) {
      final fallbackPath = await _tryFileSystemAccessFallback(
        content: _repository.buildBackupJson,
        fileName: _repository.defaultBackupFileName(),
        mimeType: 'application/json',
        directWriteError: directWriteError,
        failureMessage: 'Gagal mengekspor data cadangan',
      );
      return fallbackPath;
    }
  }

  /// Exports transactions and category names to a CSV table file.
  /// See [exportJson]'s doc comment for the SAF-fallback rationale.
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
    } catch (directWriteError) {
      final fallbackPath = await _tryFileSystemAccessFallback(
        content: _repository.buildTransactionsCsv,
        fileName: _repository.defaultCsvFileName(),
        mimeType: 'text/csv',
        directWriteError: directWriteError,
        failureMessage: 'Gagal mengekspor riwayat transaksi CSV',
      );
      return fallbackPath;
    }
  }

  /// D18/M17 bug #9: shared fallback path for both export actions — builds
  /// the content in-memory and hands it to the SAF "save as" picker. If the
  /// user cancels the picker (returns `null`), this is treated as a plain
  /// cancellation, not an error (matches the import flow's
  /// `pickAndValidateBackup` cancel behavior). Only a genuine failure of
  /// BOTH the direct write and the SAF picker surfaces as `state.errorMessage`.
  Future<String?> _tryFileSystemAccessFallback({
    required Future<String> Function() content,
    required String fileName,
    required String mimeType,
    required Object directWriteError,
    required String failureMessage,
  }) async {
    try {
      final fileContent = await content();
      final path = await _filePicker.saveFile(
        fileName: fileName,
        content: fileContent,
        mimeType: mimeType,
      );
      if (path == null) {
        // User cancelled the SAF picker — not an error.
        state = state.copyWith(isLoading: false);
        return null;
      }
      state = state.copyWith(isLoading: false, lastExportedPath: path);
      return path;
    } catch (fallbackError) {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            '$failureMessage: $directWriteError (fallback juga gagal: $fallbackError)',
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
