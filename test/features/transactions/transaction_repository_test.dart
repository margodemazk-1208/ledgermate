// Real-Isar persistence tests for TransactionRepository (M3).
// Deliberately plain `test()`, not `testWidgets()`, because Isar native
// calls hang under `AutomatedTestWidgetsFlutterBinding`.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/transactions/data/transaction_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late TransactionRepository repository;
  var instanceCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync('ledgermate_tx_repo_test_');
    instanceCounter++;
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'tx_repo_test_$instanceCounter',
    );
    repository = TransactionRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Category seeding (FR-02, FR-09)', () {
    test(
      'seedDefaultCategories seeds 5 default categories on empty database',
      () async {
        expect(await isar.categorys.count(), 0);

        await repository.seedDefaultCategories();

        final categories = await isar.categorys.where().findAll();
        expect(categories.length, 5);
        final names = categories.map((c) => c.name).toList();
        expect(
          names,
          containsAll(['Makan', 'Transport', 'Hiburan', 'Tagihan', 'Lainnya']),
        );
        for (final cat in categories) {
          expect(cat.isDefault, isTrue);
        }
      },
    );

    test(
      'seedDefaultCategories is idempotent and does not create duplicates',
      () async {
        await repository.seedDefaultCategories();
        expect(await isar.categorys.count(), 5);

        await repository.seedDefaultCategories();
        expect(await isar.categorys.count(), 5);
      },
    );

    test('getCategories automatically triggers seeding if empty', () async {
      expect(await isar.categorys.count(), 0);
      final categories = await repository.getCategories();
      expect(categories, isNotEmpty);
      expect(categories.length, 5);
    });
  });

  group('Transaction CRUD (FR-02, FR-03)', () {
    test('saveTransaction persists income and expense transactions', () async {
      await repository.seedDefaultCategories();
      final categories = await isar.categorys.where().findAll();
      final makanCat = categories.firstWhere((c) => c.name == 'Makan');

      final now = DateTime.now();
      final expense = await repository.saveTransaction(
        type: db.TransactionType.expense,
        amount: 35000,
        categoryId: makanCat.id,
        date: now,
        notes: 'Makan siang ayam geprek',
      );

      expect(expense.id, greaterThan(0));
      expect(expense.amount, 35000);
      expect(expense.type, db.TransactionType.expense);
      expect(expense.categoryId, makanCat.id);
      expect(expense.notes, 'Makan siang ayam geprek');

      final fetched = await repository.getTransaction(expense.id);
      expect(fetched, isNotNull);
      expect(fetched!.amount, 35000);
      expect(fetched.type, db.TransactionType.expense);
    });

    test('saveTransaction rejects zero or negative amount', () async {
      await repository.seedDefaultCategories();
      final categories = await isar.categorys.where().findAll();

      expect(
        () => repository.saveTransaction(
          type: db.TransactionType.expense,
          amount: 0,
          categoryId: categories.first.id,
          date: DateTime.now(),
        ),
        throwsArgumentError,
      );

      expect(
        () => repository.saveTransaction(
          type: db.TransactionType.expense,
          amount: -50000,
          categoryId: categories.first.id,
          date: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test(
      'saveTransaction rejects invalid categoryId (0 or negative)',
      () async {
        expect(
          () => repository.saveTransaction(
            type: db.TransactionType.expense,
            amount: 10000,
            categoryId: 0,
            date: DateTime.now(),
          ),
          throwsArgumentError,
        );
      },
    );

    test('saveTransaction updates existing transaction on edit', () async {
      await repository.seedDefaultCategories();
      final categories = await isar.categorys.where().findAll();
      final cat1 = categories[0];
      final cat2 = categories[1];

      final original = await repository.saveTransaction(
        type: db.TransactionType.expense,
        amount: 20000,
        categoryId: cat1.id,
        date: DateTime.now(),
        notes: 'Original note',
      );

      final updated = await repository.saveTransaction(
        id: original.id,
        type: db.TransactionType.income,
        amount: 75000,
        categoryId: cat2.id,
        date: DateTime.now(),
        notes: 'Updated note',
      );

      expect(updated.id, original.id);
      expect(updated.amount, 75000);
      expect(updated.type, db.TransactionType.income);
      expect(updated.categoryId, cat2.id);
      expect(updated.notes, 'Updated note');

      final count = await isar.transactions.count();
      expect(count, 1);
    });

    test(
      'saveTransaction auto-associates with current PayCycle in Mode A',
      () async {
        // Setup Mode A profile & PayCycle
        await isar.writeTxn(() async {
          final profile = LocalProfile()
            ..incomeFrequency = IncomeFrequency.periodic
            ..onboardingComplete = true;
          await isar.localProfiles.put(profile);

          final cycle = PayCycle()
            ..startDate = DateTime(2026, 10, 1)
            ..paydayDate = DateTime(2026, 10, 31);
          await isar.payCycles.put(cycle);
        });

        final cycles = await isar.payCycles.where().findAll();
        final currentCycle = cycles.first;

        await repository.seedDefaultCategories();
        final cat = (await isar.categorys.where().findAll()).first;

        final tx = await repository.saveTransaction(
          type: db.TransactionType.expense,
          amount: 25000,
          categoryId: cat.id,
          date: DateTime.now(),
        );

        expect(tx.payCycleId, currentCycle.id);
      },
    );

    test('watchTransactions and getTransactions return items in reverse-chronological order', () async {
      await repository.seedDefaultCategories();
      final cat = (await isar.categorys.where().findAll()).first;

      final d1 = DateTime(2026, 10, 26, 10, 0);
      final d2 = DateTime(2026, 10, 27, 15, 0);
      final d3 = DateTime(2026, 10, 28, 9, 0);

      await repository.saveTransaction(
        type: db.TransactionType.expense,
        amount: 10000,
        categoryId: cat.id,
        date: d1,
      );
      await repository.saveTransaction(
        type: db.TransactionType.expense,
        amount: 20000,
        categoryId: cat.id,
        date: d3,
      );
      await repository.saveTransaction(
        type: db.TransactionType.expense,
        amount: 15000,
        categoryId: cat.id,
        date: d2,
      );

      final list = await repository.getTransactions();
      expect(list.length, 3);
      expect(list[0].amount, 20000); // newest (d3)
      expect(list[1].amount, 15000); // middle (d2)
      expect(list[2].amount, 10000); // oldest (d1)
    });

    test('deleteTransaction deletes transaction dated today (FR-03)', () async {
      await repository.seedDefaultCategories();
      final cat = (await isar.categorys.where().findAll()).first;

      final now = DateTime.now();
      final tx = await repository.saveTransaction(
        type: db.TransactionType.expense,
        amount: 45000,
        categoryId: cat.id,
        date: now,
      );

      expect(await isar.transactions.count(), 1);

      // Allowed: same day as now
      await repository.deleteTransaction(tx.id, referenceDate: now);

      expect(await isar.transactions.count(), 0);
    });

    test('deleteTransaction throws TransactionDeleteRestrictedException for older transaction (FR-03)', () async {
      await repository.seedDefaultCategories();
      final cat = (await isar.categorys.where().findAll()).first;

      final yesterday = DateTime(2026, 10, 27, 12, 0);
      final today = DateTime(2026, 10, 28, 12, 0);

      final tx = await repository.saveTransaction(
        type: db.TransactionType.expense,
        amount: 60000,
        categoryId: cat.id,
        date: yesterday,
      );

      expect(await isar.transactions.count(), 1);

      // Prohibited: yesterday's transaction attempting to delete on today
      expect(
        () => repository.deleteTransaction(tx.id, referenceDate: today),
        throwsA(isA<TransactionDeleteRestrictedException>()),
      );

      // Data must remain untouched
      expect(await isar.transactions.count(), 1);
    });
  });

  group('Performance benchmark (PRD §6.1)', () {
    test('saveTransaction executes well under 50ms per transaction', () async {
      await repository.seedDefaultCategories();
      final cat = (await isar.categorys.where().findAll()).first;

      final stopwatch = Stopwatch()..start();
      const iterations = 30;
      for (var i = 0; i < iterations; i++) {
        await repository.saveTransaction(
          type: db.TransactionType.expense,
          amount: 10000 + i * 500,
          categoryId: cat.id,
          date: DateTime.now(),
          notes: 'Perf test item #$i',
        );
      }
      stopwatch.stop();

      final avgMillis = stopwatch.elapsedMilliseconds / iterations;
      // Assert average save time is well under the 50ms PRD target
      expect(avgMillis, lessThan(50.0));
    });
  });
}
