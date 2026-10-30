import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/asset.dart';
import '../../../core/database/category.dart';
import '../../../core/database/financial_goal.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../../core/database/wallet.dart';
import '../domain/backup_data.dart';
import '../domain/csv_serializer.dart';

/// Contract for backup export and import operations (FR-08).
abstract class ExportImportRepository {
  /// Creates an in-memory snapshot of all 6 PRD §8 Isar collections.
  Future<BackupData> createBackupData();

  /// Builds the full JSON backup content in-memory WITHOUT writing it to
  /// disk anywhere. D18/M17 bug #9: the Storage Access Framework fallback
  /// (`ExportImportNotifier`) needs the raw bytes to hand to
  /// `FilePicker.saveFile`, which writes through the SAF picker itself
  /// rather than a direct `File` path.
  ///
  /// M18/D18 perf item 7: the actual `jsonEncode` pass (CPU-bound, blocks
  /// the UI thread for large datasets) runs on a background isolate via
  /// `Isolate.run` — only the Isar read (`createBackupData`) stays on the
  /// main isolate, since Isar queries aren't valid across an isolate
  /// boundary.
  Future<String> buildBackupJson();

  /// Builds the full transactions CSV content in-memory, same rationale as
  /// [buildBackupJson] (M18/D18 perf item 7: CSV row-building moved to
  /// `Isolate.run` too).
  Future<String> buildTransactionsCsv();

  /// Serializes all collections to a JSON backup file in the downloads/documents folder.
  /// Returns the absolute path of the created file.
  Future<String> exportBackupToJson({
    String? targetDirectoryPath,
    String? customFileName,
  });

  /// Serializes transaction history and categories to a CSV table.
  /// Returns the absolute path of the created file.
  Future<String> exportTransactionsToCsv({
    String? targetDirectoryPath,
    String? customFileName,
  });

  /// Validates a raw JSON string without touching the database.
  /// Throws [BackupValidationException] if malformed or incompatible.
  ///
  /// M18/D18 perf item 7: `jsonDecode` + full schema validation
  /// (`BackupData.fromJson`) run on a background isolate via `Isolate.run`
  /// — for a large backup file this is real CPU work that would otherwise
  /// block the UI thread for the duration of the import flow.
  Future<BackupData> validateBackupString(String jsonContent);

  /// Replaces the entire local database with the records from [backupData].
  /// Performed atomically inside a single Isar write transaction.
  Future<void> restoreDatabase(BackupData backupData);

  /// A default file name for a fresh JSON backup, timestamped at the
  /// current moment — shared by the direct-write path and the SAF fallback
  /// so both produce identically-named files.
  String defaultBackupFileName();

  /// A default file name for a fresh transactions CSV export, timestamped
  /// at the current moment.
  String defaultCsvFileName();
}

/// Production implementation of [ExportImportRepository] backed by [Isar].
class IsarExportImportRepository implements ExportImportRepository {
  IsarExportImportRepository({required this.isar, this.directoryProvider});

  final Isar isar;
  final Future<Directory> Function()? directoryProvider;

  @override
  Future<BackupData> createBackupData() async {
    final profiles = await isar.localProfiles.where().findAll();
    final payCycles = await isar.payCycles.where().findAll();
    final categories = await isar.categorys.where().findAll();
    final transactions = await isar.transactions.where().findAll();
    final goals = await isar.financialGoals.where().findAll();
    final assets = await isar.assets.where().findAll();
    final wallets = await isar.wallets.where().findAll();

    return BackupData(
      exportedAt: DateTime.now(),
      profiles: profiles,
      payCycles: payCycles,
      categories: categories,
      transactions: transactions,
      financialGoals: goals,
      assets: assets,
      wallets: wallets,
    );
  }

  @override
  Future<String> buildBackupJson() async {
    final backup = await createBackupData();
    // M18/D18 perf item 7: the Isar read is done — everything from here is
    // pure CPU work (JSON encoding), safe to hand to a background isolate
    // so a large backup doesn't jank the UI thread.
    return Isolate.run(() {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(backup.toJson());
    });
  }

  @override
  Future<String> buildTransactionsCsv() async {
    final transactions = await isar.transactions.where().findAll();
    final categories = await isar.categorys.where().findAll();
    // M18/D18 perf item 7: same rationale as [buildBackupJson] — the Isar
    // reads above are done, row-building is pure CPU work.
    return Isolate.run(() {
      return CsvSerializer.transactionsToCsv(
        transactions: transactions,
        categories: categories,
      );
    });
  }

  @override
  String defaultBackupFileName() =>
      'ledgermate_backup_${_formatTimestamp(DateTime.now())}.json';

  @override
  String defaultCsvFileName() =>
      'ledgermate_transaksi_${_formatTimestamp(DateTime.now())}.csv';

  @override
  Future<String> exportBackupToJson({
    String? targetDirectoryPath,
    String? customFileName,
  }) async {
    final jsonText = await buildBackupJson();

    final dir = targetDirectoryPath != null
        ? Directory(targetDirectoryPath)
        : await _resolveExportDirectory();

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final fileName = customFileName ?? defaultBackupFileName();
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(jsonText, flush: true);
    return file.path;
  }

  @override
  Future<String> exportTransactionsToCsv({
    String? targetDirectoryPath,
    String? customFileName,
  }) async {
    final csvText = await buildTransactionsCsv();

    final dir = targetDirectoryPath != null
        ? Directory(targetDirectoryPath)
        : await _resolveExportDirectory();

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final fileName = customFileName ?? defaultCsvFileName();
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(csvText, flush: true);
    return file.path;
  }

  @override
  Future<BackupData> validateBackupString(String jsonContent) {
    // M18/D18 perf item 7: `jsonDecode` + full validation is pure CPU work
    // on a plain String input — safe to run off the main isolate.
    return Isolate.run(() {
      dynamic parsed;
      try {
        parsed = jsonDecode(jsonContent);
      } catch (e) {
        throw BackupValidationException(
          'File bukan format JSON yang valid: $e',
        );
      }

      if (parsed is! Map<String, dynamic>) {
        throw const BackupValidationException(
          'Struktur data cadangan tidak valid: objek utama harus berupa JSON Object.',
        );
      }

      return BackupData.fromJson(parsed);
    });
  }

  @override
  Future<void> restoreDatabase(BackupData backupData) async {
    // Atomically replace all collections in a single write transaction (DECISIONS M9).
    // If anything throws, the transaction is rolled back and local data is preserved.
    await isar.writeTxn(() async {
      await isar.localProfiles.clear();
      await isar.payCycles.clear();
      await isar.categorys.clear();
      await isar.transactions.clear();
      await isar.financialGoals.clear();
      await isar.assets.clear();
      await isar.wallets.clear();

      if (backupData.profiles.isNotEmpty) {
        await isar.localProfiles.putAll(backupData.profiles);
      }
      if (backupData.payCycles.isNotEmpty) {
        await isar.payCycles.putAll(backupData.payCycles);
      }
      if (backupData.categories.isNotEmpty) {
        await isar.categorys.putAll(backupData.categories);
      }
      if (backupData.transactions.isNotEmpty) {
        await isar.transactions.putAll(backupData.transactions);
      }
      if (backupData.financialGoals.isNotEmpty) {
        await isar.financialGoals.putAll(backupData.financialGoals);
      }
      if (backupData.assets.isNotEmpty) {
        await isar.assets.putAll(backupData.assets);
      }
      if (backupData.wallets.isNotEmpty) {
        await isar.wallets.putAll(backupData.wallets);
      }
    });

    await migrateIsarSchema(isar);
  }

  Future<Directory> _resolveExportDirectory() async {
    final customProvider = directoryProvider;
    if (customProvider != null) {
      return customProvider();
    }

    try {
      if (Platform.isAndroid) {
        final publicDownload = Directory('/storage/emulated/0/Download');
        if (publicDownload.existsSync()) {
          return publicDownload;
        }
      }

      final downloads = await getDownloadsDirectory();
      if (downloads != null && downloads.existsSync()) {
        return downloads;
      }
    } catch (_) {
      // Ignored for non-mobile platforms or headless tests
    }

    try {
      return await getApplicationDocumentsDirectory();
    } catch (_) {
      return Directory.systemTemp;
    }
  }

  String _formatTimestamp(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    final s = dt.second.toString().padLeft(2, '0');
    return '$y$m${d}_$h$min$s';
  }
}
