import 'dart:convert';
import 'dart:io';

import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/database/asset.dart';
import '../../../core/database/category.dart';
import '../../../core/database/financial_goal.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../domain/backup_data.dart';
import '../domain/csv_serializer.dart';

/// Contract for backup export and import operations (FR-08).
abstract class ExportImportRepository {
  /// Creates an in-memory snapshot of all 6 PRD §8 Isar collections.
  Future<BackupData> createBackupData();

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
  BackupData validateBackupString(String jsonContent);

  /// Replaces the entire local database with the records from [backupData].
  /// Performed atomically inside a single Isar write transaction.
  Future<void> restoreDatabase(BackupData backupData);
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

    return BackupData(
      exportedAt: DateTime.now(),
      profiles: profiles,
      payCycles: payCycles,
      categories: categories,
      transactions: transactions,
      financialGoals: goals,
      assets: assets,
    );
  }

  @override
  Future<String> exportBackupToJson({
    String? targetDirectoryPath,
    String? customFileName,
  }) async {
    final backup = await createBackupData();
    const encoder = JsonEncoder.withIndent('  ');
    final jsonText = encoder.convert(backup.toJson());

    final dir = targetDirectoryPath != null
        ? Directory(targetDirectoryPath)
        : await _resolveExportDirectory();

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final timestamp = _formatTimestamp(backup.exportedAt);
    final fileName = customFileName ?? 'ledgermate_backup_$timestamp.json';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(jsonText, flush: true);
    return file.path;
  }

  @override
  Future<String> exportTransactionsToCsv({
    String? targetDirectoryPath,
    String? customFileName,
  }) async {
    final transactions = await isar.transactions.where().findAll();
    final categories = await isar.categorys.where().findAll();

    final csvText = CsvSerializer.transactionsToCsv(
      transactions: transactions,
      categories: categories,
    );

    final dir = targetDirectoryPath != null
        ? Directory(targetDirectoryPath)
        : await _resolveExportDirectory();

    if (!dir.existsSync()) {
      await dir.create(recursive: true);
    }

    final timestamp = _formatTimestamp(DateTime.now());
    final fileName = customFileName ?? 'ledgermate_transaksi_$timestamp.csv';
    final file = File('${dir.path}/$fileName');

    await file.writeAsString(csvText, flush: true);
    return file.path;
  }

  @override
  BackupData validateBackupString(String jsonContent) {
    dynamic parsed;
    try {
      parsed = jsonDecode(jsonContent);
    } catch (e) {
      throw BackupValidationException('File bukan format JSON yang valid: $e');
    }

    if (parsed is! Map<String, dynamic>) {
      throw const BackupValidationException(
        'Struktur data cadangan tidak valid: objek utama harus berupa JSON Object.',
      );
    }

    return BackupData.fromJson(parsed);
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
    });
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
