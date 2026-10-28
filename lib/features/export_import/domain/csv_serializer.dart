// CSV serialization for human-readable tabular export (FR-08).
import '../../../core/database/category.dart';
import '../../../core/database/transaction.dart' as db;

/// Converts transaction history and category mappings to an RFC 4180 compliant CSV string.
class CsvSerializer {
  const CsvSerializer._();

  /// Serializes [transactions] into CSV format, resolving [Category.name] using [categories].
  static String transactionsToCsv({
    required List<db.Transaction> transactions,
    required List<Category> categories,
  }) {
    final categoryMap = {for (final c in categories) c.id: c.name};

    final buffer = StringBuffer();
    // Header row
    buffer.writeln('ID,Tanggal,Tipe,Kategori,Nominal,Catatan,ID_Siklus_Gaji');

    for (final tx in transactions) {
      final categoryName =
          categoryMap[tx.categoryId] ?? 'Kategori #${tx.categoryId}';
      final typeLabel = tx.type == db.TransactionType.income
          ? 'Pemasukan'
          : 'Pengeluaran';
      final dateStr = tx.date.toIso8601String();
      final notes = tx.notes ?? '';
      final payCycleIdStr = tx.payCycleId?.toString() ?? '';

      final row = [
        tx.id.toString(),
        escapeCsv(dateStr),
        escapeCsv(typeLabel),
        escapeCsv(categoryName),
        tx.amount.toString(),
        escapeCsv(notes),
        payCycleIdStr,
      ].join(',');

      buffer.writeln(row);
    }

    return buffer.toString();
  }

  /// Escapes a CSV cell value according to RFC 4180 rules.
  static String escapeCsv(String value) {
    if (value.contains(',') ||
        value.contains('"') ||
        value.contains(String.fromCharCode(10)) ||
        value.contains(String.fromCharCode(13))) {
      final escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}
