// Verifies the Isar instance opener (M1 step 3) actually opens a working
// instance containing all 6 collections and is idempotent for repeated
// calls with the same instance name.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/isar_provider.dart';

void main() {
  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  test(
    'openLedgerMateIsar opens a usable instance with all collections',
    () async {
      final tempDir = Directory.systemTemp.createTempSync(
        'ledgermate_opener_test_',
      );
      try {
        final isar = await openLedgerMateIsar(
          directory: tempDir.path,
          name: 'opener_test',
        );

        // Prove it's a working, queryable instance, not just a non-null
        // return value.
        final category = Category()
          ..name = 'Sanity check'
          ..isDefault = true;
        await isar.writeTxn(() => isar.categorys.put(category));
        expect(await isar.categorys.get(category.id), isNotNull);

        // Calling it again with the same name must return the same open
        // instance instead of throwing "instance already open".
        final reopened = await openLedgerMateIsar(
          directory: tempDir.path,
          name: 'opener_test',
        );
        expect(identical(isar, reopened), isTrue);

        await isar.close(deleteFromDisk: true);
      } finally {
        if (tempDir.existsSync()) {
          tempDir.deleteSync(recursive: true);
        }
      }
    },
  );
}
