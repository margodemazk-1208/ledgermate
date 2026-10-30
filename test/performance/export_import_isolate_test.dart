// M18 Performance Optimization (docs/ROADMAP.md M18, item 7): the
// export/import JSON (de)serialization work previously ran synchronously
// on the main isolate. This measures real wall-clock cost of the
// `jsonEncode`/`jsonDecode` + `BackupData` (de)serialization passes at a
// realistic-to-stress-tested backup size, to make the "this would jank the
// UI thread" claim concrete rather than assumed — and to honestly record
// the `Isolate.run` spawn overhead this fix trades in for a larger backup.
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/export_import/domain/backup_data.dart';

String _ms(Duration d) => '${(d.inMicroseconds / 1000).toStringAsFixed(3)}ms';

BackupData _buildBackup(int transactionCount) {
  final categories = List.generate(
    10,
    (i) => Category()
      ..id = i + 1
      ..name = 'Category $i'
      ..isDefault = true,
  );
  final transactions = List.generate(transactionCount, (i) {
    return db.Transaction()
      ..id = i + 1
      ..type = db.TransactionType.expense
      ..amount = 10000 + i
      ..categoryId = categories[i % categories.length].id
      ..walletId = 1
      ..date = DateTime(2026, 1, 1).add(Duration(hours: i))
      ..notes = i % 5 == 0 ? 'Catatan transaksi nomor $i dengan teks' : null;
  });

  return BackupData(
    exportedAt: DateTime(2026, 10, 30),
    profiles: [],
    payCycles: [],
    categories: categories,
    transactions: transactions,
    financialGoals: [],
    assets: [],
  );
}

void main() {
  test('measures JSON encode/decode cost on-thread vs Isolate.run, for a '
      'realistic-to-large backup (M18/D18 perf item 7)', () async {
    // 800 matches M15's realistic-volume benchmark; 8,000 stress-tests a
    // multi-year power user well past what the PRD expects, to show the
    // trend as the dataset grows.
    for (final count in [800, 8000]) {
      final backup = _buildBackup(count);

      // --- Encode: on-thread vs Isolate.run ---------------------------
      final onThreadEncodeSw = Stopwatch()..start();
      final jsonText = const JsonEncoder.withIndent('  ')
          .convert(backup.toJson());
      onThreadEncodeSw.stop();

      final isolateEncodeSw = Stopwatch()..start();
      final jsonTextViaIsolate = await Isolate.run(() {
        const encoder = JsonEncoder.withIndent('  ');
        return encoder.convert(backup.toJson());
      });
      isolateEncodeSw.stop();
      expect(jsonTextViaIsolate.length, jsonText.length);

      // --- Decode+validate: on-thread vs Isolate.run -------------------
      final onThreadDecodeSw = Stopwatch()..start();
      final decoded = BackupData.fromJson(
        jsonDecode(jsonText) as Map<String, dynamic>,
      );
      onThreadDecodeSw.stop();

      final isolateDecodeSw = Stopwatch()..start();
      final decodedViaIsolate = await Isolate.run(() {
        final parsed = jsonDecode(jsonText);
        return BackupData.fromJson(parsed as Map<String, dynamic>);
      });
      isolateDecodeSw.stop();
      expect(
        decodedViaIsolate.transactions.length,
        decoded.transactions.length,
      );

      // ignore: avoid_print
      print(
        '[PERF][M18] backup with $count transactions '
        '(${(jsonText.length / 1024).toStringAsFixed(1)}KB JSON): '
        'encode on-thread=${_ms(onThreadEncodeSw.elapsed)} vs '
        'Isolate.run=${_ms(isolateEncodeSw.elapsed)} | '
        'decode+validate on-thread=${_ms(onThreadDecodeSw.elapsed)} vs '
        'Isolate.run=${_ms(isolateDecodeSw.elapsed)}',
      );
    }
  });
}
