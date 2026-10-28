import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/export_import/domain/csv_serializer.dart';

void main() {
  group('CsvSerializer (FR-08 RFC 4180)', () {
    test(
      'serializes transactions with Indonesian headers and category names',
      () {
        final cat1 = Category()
          ..id = 10
          ..name = 'Makanan'
          ..isDefault = true;
        final cat2 = Category()
          ..id = 20
          ..name = 'Gaji Bulanan'
          ..isDefault = true;

        final tx1 = db.Transaction()
          ..id = 1
          ..amount = 75000
          ..type = db.TransactionType.expense
          ..categoryId = 10
          ..date = DateTime(2026, 10, 20, 14, 30)
          ..notes = 'Makan siang warteg'
          ..payCycleId = 100;

        final tx2 = db.Transaction()
          ..id = 2
          ..amount = 15000000
          ..type = db.TransactionType.income
          ..categoryId = 20
          ..date = DateTime(2026, 10, 25, 9, 0)
          ..notes = null
          ..payCycleId = null;

        final csv = CsvSerializer.transactionsToCsv(
          transactions: [tx1, tx2],
          categories: [cat1, cat2],
        );

        final lines = csv.trim().split('\n');
        expect(lines.length, 3);
        expect(
          lines[0],
          'ID,Tanggal,Tipe,Kategori,Nominal,Catatan,ID_Siklus_Gaji',
        );
        expect(
          lines[1],
          contains(
            '1,2026-10-20T14:30:00.000,Pengeluaran,Makanan,75000,Makan siang warteg,100',
          ),
        );
        expect(
          lines[2],
          contains(
            '2,2026-10-25T09:00:00.000,Pemasukan,Gaji Bulanan,15000000,,',
          ),
        );
      },
    );

    test(
      'escapes commas, quotes, and newlines in accordance with RFC 4180',
      () {
        final cat = Category()
          ..id = 5
          ..name = 'Belanja, & Rumah'
          ..isDefault = false;

        final tx = db.Transaction()
          ..id = 10
          ..amount = 120000
          ..type = db.TransactionType.expense
          ..categoryId = 5
          ..date = DateTime(2026, 10, 28, 18, 0)
          ..notes = 'Beli "sembako", sabun, susu\ndan roti'
          ..payCycleId = 200;

        final csv = CsvSerializer.transactionsToCsv(
          transactions: [tx],
          categories: [cat],
        );

        expect(csv, contains('"Belanja, & Rumah"'));
        expect(csv, contains('"Beli ""sembako"", sabun, susu\ndan roti"'));
      },
    );

    test('resolves fallback category name when categoryId is not in list', () {
      final tx = db.Transaction()
        ..id = 99
        ..amount = 25000
        ..type = db.TransactionType.expense
        ..categoryId = 888
        ..date = DateTime(2026, 10, 29)
        ..notes = 'Kopi kenangan'
        ..payCycleId = null;

      final csv = CsvSerializer.transactionsToCsv(
        transactions: [tx],
        categories: [],
      );

      expect(csv, contains('Kategori #888'));
    });
  });
}
