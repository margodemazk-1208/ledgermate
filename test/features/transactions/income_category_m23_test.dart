import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/features/analytics/data/analytics_repository.dart';
import 'package:ledgermate/features/export_import/data/export_import_service.dart';
import 'package:ledgermate/features/export_import/domain/backup_data.dart';
import 'package:ledgermate/features/settings/data/settings_repository.dart';
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';
import 'package:ledgermate/features/transactions/data/transaction_repository.dart';
import 'package:ledgermate/features/transactions/presentation/transaction_form_screen.dart';
import 'package:ledgermate/features/wallets/application/wallet_providers.dart';
import 'package:ledgermate/features/wallets/data/wallet_repository.dart';

import 'fake_transaction_repository.dart';

class _FakeWalletRepo implements WalletRepositoryBase {
  final List<Wallet> _wallets = [
    Wallet()
      ..id = 1
      ..name = 'Dompet Utama'
      ..isDefault = true,
  ];

  @override
  Future<List<Wallet>> getWallets() async => [..._wallets];

  @override
  Stream<List<Wallet>> watchWallets() => Stream.value([..._wallets]);

  @override
  Future<Wallet> getDefaultWallet() async => _wallets.first;

  @override
  Future<Wallet> createWallet(String name, {bool isDefault = false}) async {
    final w = Wallet()
      ..id = _wallets.length + 1
      ..name = name
      ..isDefault = isDefault;
    _wallets.add(w);
    return w;
  }

  @override
  Future<void> updateWallet(Wallet wallet) async {
    final idx = _wallets.indexWhere((w) => w.id == wallet.id);
    if (idx >= 0) _wallets[idx] = wallet;
  }

  @override
  Future<void> deleteWallet(int id) async {
    _wallets.removeWhere((w) => w.id == id);
  }

  @override
  Future<int> resolveDefaultWalletId() async => 1;
}

Widget _buildTestApp({
  required TransactionRepositoryBase txRepo,
  required WalletRepositoryBase walletRepo,
  db.Transaction? transaction,
}) {
  return ProviderScope(
    overrides: [
      transactionRepositoryProvider.overrideWithValue(txRepo),
      walletRepositoryProvider.overrideWithValue(walletRepo),
      defaultWalletProvider.overrideWith(
        (ref) => Stream.value(
          Wallet()
            ..id = 1
            ..name = 'Dompet Utama'
            ..isDefault = true,
        ),
      ),
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
    late _FakeWalletRepo fakeWalletRepo;

    setUp(() {
      fakeTxRepo = FakeTransactionRepository();
      fakeWalletRepo = _FakeWalletRepo();
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
        find.byKey(const Key('transaction_category_dropdown')),
        findsOneWidget,
      );
      expect(
        find.byKey(const Key('transaction_wallet_dropdown')),
        findsOneWidget,
      );

      // Switch segment to Income (Pemasukan)
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      // Category dropdown must be HIDDEN
      expect(
        find.byKey(const Key('transaction_category_dropdown')),
        findsNothing,
      );
      // Wallet dropdown must still be VISIBLE
      expect(
        find.byKey(const Key('transaction_wallet_dropdown')),
        findsOneWidget,
      );

      // Switch back to Expense (Pengeluaran)
      await tester.tap(find.text('Pengeluaran'));
      await tester.pumpAndSettle();

      // Category dropdown reappears
      expect(
        find.byKey(const Key('transaction_category_dropdown')),
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
          find.byKey(const Key('transaction_amount_input')),
          '5000000',
        );
        await tester.pumpAndSettle();

        // Save transaction without any category picker interaction
        await tester.tap(find.byKey(const Key('transaction_save_button')));
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
    late AnalyticsRepository analyticsRepo;
    late SettingsRepository settingsRepo;

    setUp(() async {
      await Isar.initializeIsarCore(download: true);
      tempDir = await Directory.systemTemp.createTemp('m23_isar_test_');
      isar = await Isar.open([
        db.TransactionSchema,
        CategorySchema,
        PayCycleSchema,
        FinancialGoalSchema,
        LocalProfileSchema,
        WalletSchema,
      ], directory: tempDir.path);
      txRepo = TransactionRepository(isar);
      analyticsRepo = AnalyticsRepository(isar);
      settingsRepo = SettingsRepository(isarInstance: isar);

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
          (c) => c.name == 'Transportasi',
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

        final daily = await analyticsRepo.getDailyAnalytics(now);
        expect(daily.totalIncome, equals(10000000));
        expect(daily.totalExpense, equals(75000));

        // Breakdown should only contain the 2 expense categories, NOT the system income category
        expect(daily.categoryBreakdown.length, equals(2));
        final breakdownNames = daily.categoryBreakdown
            .map((b) => b.categoryName)
            .toList();
        expect(breakdownNames, containsAll(['Makan', 'Transportasi']));
        expect(breakdownNames, isNot(contains(systemIncomeCategoryName)));
      },
    );

    test(
      'settings category management hides and protects system income category',
      () async {
        final customCats = await settingsRepo.getCustomCategories();
        // Custom categories must not contain system generated categories
        expect(
          customCats.any((c) => c.name == systemIncomeCategoryName),
          isFalse,
        );
        expect(customCats.any((c) => c.isSystemGenerated), isFalse);

        // Attempting to delete the system category must throw StateError
        final incomeCatId = await txRepo.resolveSystemIncomeCategoryId();
        expect(
          () => settingsRepo.deleteCategory(incomeCatId),
          throwsA(isA<StateError>()),
        );
      },
    );

    test('system income category round-trips correctly through backup export/import', () async {
      final exportService = ExportImportService(isarInstance: isar);
      final incomeCatId = await txRepo.resolveSystemIncomeCategoryId();

      // Add income transaction
      await txRepo.saveTransaction(
        type: db.TransactionType.income,
        amount: 3500000,
        categoryId: 0,
        date: DateTime(2026, 3, 20),
      );

      // Export backup
      final backup = await exportService.exportBackup();
      expect(
        backup.categories.any(
          (c) => c.name == systemIncomeCategoryName && c.isSystemGenerated,
        ),
        isTrue,
      );

      // Restore backup
      await exportService.restoreBackup(backup);

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
