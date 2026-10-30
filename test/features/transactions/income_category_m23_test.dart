import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/features/analytics/domain/analytics_models.dart';
import 'package:ledgermate/features/export_import/data/export_import_repository.dart';
import 'package:ledgermate/features/settings/data/settings_repository.dart';
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';
import 'package:ledgermate/features/transactions/data/transaction_repository.dart';
import 'package:ledgermate/features/transactions/presentation/transaction_form_screen.dart';
import 'package:ledgermate/features/wallets/application/wallet_providers.dart';
import 'package:ledgermate/features/wallets/data/wallet_repository.dart';

import '../wallets/fake_wallet_repository.dart';
import 'fake_transaction_repository.dart';

Widget _buildTestApp({
  required TransactionRepositoryBase txRepo,
  required WalletRepositoryBase walletRepo,
  db.Transaction? transaction,
}) {
  return ProviderScope(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(txRepo),
      walletRepositoryProvider.overrideWithValue(walletRepo),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id')],
      home: TransactionFormScreen(transaction: transaction),
    ),
  );
}

void main() {
  group('M23 — Remove Income Category Field (UI & Form)', () {
    late FakeTransactionRepository fakeTxRepo;
    late FakeWalletRepository fakeWalletRepo;

    setUp(() {
      fakeTxRepo = FakeTransactionRepository();
      fakeWalletRepo = FakeWalletRepository(
        initialWallets: [
          Wallet()
            ..id = 1
            ..name = 'Dompet Utama'
            ..includeInDailyBudget = true,
        ],
      );
    });

    testWidgets('shows category dropdown for Expense but hides it for Income', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildTestApp(txRepo: fakeTxRepo, walletRepo: fakeWalletRepo),
      );
      await tester.pumpAndSettle();

      // Default is Expense -> Category dropdown must be visible
      expect(
        find.byKey(const ValueKey('transaction_category_picker')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('transaction_wallet_picker')),
        findsOneWidget,
      );

      // Switch segment to Income (Pemasukan)
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Category dropdown must be HIDDEN
      expect(
        find.byKey(const ValueKey('transaction_category_picker')),
        findsNothing,
      );
      // Wallet dropdown must still be VISIBLE
      expect(
        find.byKey(const ValueKey('transaction_wallet_picker')),
        findsOneWidget,
      );

      // Switch back to Expense (Pengeluaran)
      await tester.tap(find.text('Pengeluaran'));
      await tester.pumpAndSettle();

      // Category dropdown reappears
      expect(
        find.byKey(const ValueKey('transaction_category_picker')),
        findsOneWidget,
      );
    });

    testWidgets(
      'saving an income transaction auto-assigns system income category id',
      (tester) async {
        await tester.pumpWidget(
          _buildTestApp(txRepo: fakeTxRepo, walletRepo: fakeWalletRepo),
        );
        await tester.pumpAndSettle();

        // Switch to Income
        await tester.tap(find.text('Pemasukan'));
        await tester.pumpAndSettle();

        // Enter amount
        await tester.enterText(
          find.byKey(const ValueKey('transaction_amount_field')),
          '5000000',
        );
        await tester.pumpAndSettle();

        // Save transaction without any category picker interaction
        await tester.tap(find.byKey(const ValueKey('transaction_save_button')));
        await tester.pumpAndSettle();

        // Verify saved in repo
        final txs = await fakeTxRepo.getTransactions();
        expect(txs.length, equals(1));
        final savedTx = txs.first;
        expect(savedTx.type, equals(db.TransactionType.income));
        expect(savedTx.amount, equals(5000000));

        // categoryId must be the system income category
        final incomeCatId = await fakeTxRepo.resolveSystemIncomeCategoryId();
        expect(savedTx.categoryId, equals(incomeCatId));
      },
    );
  });

  group('M23 — Backend, Analytics & Settings Integration with Isar', () {
    late Isar isar;
    late Directory tempDir;
    late TransactionRepository txRepo;
    late SettingsRepository settingsRepo;

    setUp(() async {
      await Isar.initializeIsarCore(download: true);
      tempDir = await Directory.systemTemp.createTemp('m23_isar_test_');
      isar = await openLedgerMateIsar(
        directory: tempDir.path,
        name: 'm23_isar_test',
      );
      txRepo = TransactionRepository(isar);
      settingsRepo = SettingsRepository(isar);

      await txRepo.seedDefaultCategories();
    });

    tearDown(() async {
      await isar.close(deleteFromDisk: true);
      if (tempDir.existsSync()) {
        tempDir.deleteSync(recursive: true);
      }
    });

    test(
      'system income category is seeded with isSystemGenerated=true',
      () async {
        final categories = await txRepo.getCategories();
        final incomeCat = categories.firstWhere(
          (c) => c.name == systemIncomeCategoryName && c.isSystemGenerated,
        );
        expect(incomeCat, isNotNull);
        expect(incomeCat.isDefault, isFalse);
        expect(incomeCat.isSystemGenerated, isTrue);
      },
    );

    test(
      'income transaction is excluded from category expense breakdown',
      () async {
        final now = DateTime(2026, 3, 15, 12, 0);

        // 1. Add income transaction (auto assigns system income category)
        await txRepo.saveTransaction(
          type: db.TransactionType.income,
          amount: 10000000,
          categoryId: 0,
          date: now,
          notes: 'Bonus Tahunan',
        );

        // 2. Add two expense transactions
        final categories = await txRepo.getCategories();
        final makanCat = categories.firstWhere((c) => c.name == 'Makan');
        final transportCat = categories.firstWhere(
          (c) => c.name == 'Transport',
        );

        await txRepo.saveTransaction(
          type: db.TransactionType.expense,
          amount: 50000,
          categoryId: makanCat.id,
          date: now,
        );
        await txRepo.saveTransaction(
          type: db.TransactionType.expense,
          amount: 25000,
          categoryId: transportCat.id,
          date: now,
        );

        final txs = await txRepo.getTransactions();
        final daily = AnalyticsCalculationEngine.computePeriodAnalytics(
          transactions: txs,
          categories: categories,
          period: PeriodFilter.daily,
          referenceNow: now,
        );
        expect(daily.totalIncome, equals(10000000));
        expect(daily.totalExpense, equals(75000));

        // Breakdown should only contain the 2 expense categories, NOT the system income category
        expect(daily.categoryBreakdowns.length, equals(2));
        final breakdownNames = daily.categoryBreakdowns
            .map((b) => b.categoryName)
            .toList();
        expect(breakdownNames, containsAll(['Makan', 'Transport']));
        expect(breakdownNames, isNot(contains(systemIncomeCategoryName)));
      },
    );

    test(
      'settings category management protects system income category',
      () async {
        final allCats = await settingsRepo.getCategories();
        expect(
          allCats.any(
            (c) => c.name == systemIncomeCategoryName && c.isSystemGenerated,
          ),
          isTrue,
        );

        // Attempting to delete the system category must throw StateError
        final incomeCatId = await txRepo.resolveSystemIncomeCategoryId();
        expect(
          () => settingsRepo.deleteCategory(incomeCatId),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('system income category round-trips correctly through backup export/import', () async {
      final exportRepo = IsarExportImportRepository(isar: isar);

      // Add income transaction
      await txRepo.saveTransaction(
        type: db.TransactionType.income,
        amount: 3500000,
        categoryId: 0,
        date: DateTime(2026, 3, 20),
      );

      // Export backup
      final backup = await exportRepo.createBackupData();
      expect(
        backup.categories.any(
          (c) => c.name == systemIncomeCategoryName && c.isSystemGenerated,
        ),
        isTrue,
      );

      // Restore backup
      await exportRepo.restoreDatabase(backup);

      final restoredCats = await txRepo.getCategories();
      final restoredIncomeCat = restoredCats.firstWhere(
        (c) => c.name == systemIncomeCategoryName && c.isSystemGenerated,
      );
      expect(restoredIncomeCat.isSystemGenerated, isTrue);

      final txs = await txRepo.getTransactions();
      expect(txs.length, equals(1));
      expect(txs.first.type, equals(db.TransactionType.income));
      expect(txs.first.categoryId, equals(restoredIncomeCat.id));
    });
  });
}
