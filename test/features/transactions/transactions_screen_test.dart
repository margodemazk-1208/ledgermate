import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/theme/app_theme.dart';
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';
import 'package:ledgermate/features/transactions/presentation/transaction_form_screen.dart';
import 'package:ledgermate/features/transactions/presentation/transactions_screen.dart';

import 'fake_transaction_repository.dart';

void main() {
  late FakeTransactionRepository fakeRepository;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    fakeRepository = FakeTransactionRepository();
  });

  tearDown(() {
    fakeRepository.dispose();
  });

  Future<void> pumpScreen(
    WidgetTester tester, {
    ThemeData? theme,
    Widget? home,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          transactionRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp(
          theme: theme ?? AppTheme.dark,
          home: home ?? const TransactionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('TransactionsScreen (FR-02, FR-03 list view)', () {
    testWidgets('shows empty state when transaction list is empty', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(find.text('Belum Ada Transaksi'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('empty_state_add_button')),
        findsOneWidget,
      );
      expect(find.byKey(const ValueKey('add_transaction_fab')), findsOneWidget);
    });

    testWidgets('renders transaction list with category, amount, and notes', (
      tester,
    ) async {
      final now = DateTime.now();
      final tx1 = db.Transaction()
        ..id = 1
        ..type = db.TransactionType.expense
        ..amount = 35000
        ..categoryId =
            1 // Makan
        ..date = now
        ..notes = 'Ayam Geprek';

      final tx2 = db.Transaction()
        ..id = 2
        ..type = db.TransactionType.income
        ..amount = 500000
        ..categoryId =
            5 // Lainnya
        ..date = now.subtract(const Duration(hours: 3))
        ..notes = 'Freelance bonus';

      fakeRepository = FakeTransactionRepository(
        initialTransactions: [tx1, tx2],
      );

      await pumpScreen(tester);

      expect(find.text('Makan'), findsOneWidget);
      expect(find.text('- Rp 35.000'), findsOneWidget);
      expect(find.textContaining('Ayam Geprek'), findsOneWidget);

      expect(find.text('Lainnya'), findsOneWidget);
      expect(find.text('+ Rp 500.000'), findsOneWidget);
      expect(find.textContaining('Freelance bonus'), findsOneWidget);
    });

    testWidgets('tapping FAB navigates to TransactionFormScreen in add mode', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('add_transaction_fab')));
      await tester.pumpAndSettle();

      expect(find.text('Catat Transaksi'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('transaction_save_button')),
        findsOneWidget,
      );
    });

    testWidgets('tapping empty state add button opens TransactionFormScreen', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('empty_state_add_button')));
      await tester.pumpAndSettle();

      expect(find.text('Catat Transaksi'), findsOneWidget);
    });

    testWidgets('tapping transaction item navigates to edit mode', (
      tester,
    ) async {
      final tx = db.Transaction()
        ..id = 42
        ..type = db.TransactionType.expense
        ..amount = 15000
        ..categoryId =
            2 // Transport
        ..date = DateTime.now()
        ..notes = 'Ojek online';

      fakeRepository = FakeTransactionRepository(initialTransactions: [tx]);

      await pumpScreen(tester);

      await tester.tap(find.byKey(const ValueKey('transaction_item_42')));
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaksi'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('transaction_save_button')),
        findsOneWidget,
      );
    });
  });

  group('TransactionFormScreen (FR-02, FR-03 form behavior)', () {
    testWidgets('submits new expense transaction when filled properly', (
      tester,
    ) async {
      await pumpScreen(tester, home: const TransactionFormScreen());

      expect(find.text('Catat Transaksi'), findsOneWidget);

      // Enter amount
      await tester.enterText(
        find.byKey(const ValueKey('transaction_amount_field')),
        '45000',
      );
      await tester.pumpAndSettle();

      // Enter notes
      await tester.enterText(
        find.byKey(const ValueKey('transaction_notes_field')),
        'Kopi dan cemilan',
      );
      await tester.pumpAndSettle();

      // Tap save
      final saveBtn = find.byKey(const ValueKey('transaction_save_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(fakeRepository.savedCalls.length, 1);
      final saved = fakeRepository.savedCalls.first;
      expect(saved.amount, 45000);
      expect(saved.type, db.TransactionType.expense);
      expect(saved.notes, 'Kopi dan cemilan');
    });

    testWidgets('validates required amount before saving', (tester) async {
      await pumpScreen(tester, home: const TransactionFormScreen());

      // Save without entering amount
      final saveBtn = find.byKey(const ValueKey('transaction_save_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Jumlah tidak boleh kosong'), findsOneWidget);
      expect(fakeRepository.savedCalls, isEmpty);
    });

    testWidgets('switching type to income updates saved transaction type', (
      tester,
    ) async {
      await pumpScreen(tester, home: const TransactionFormScreen());

      // Tap 'Pemasukan' segment
      await tester.tap(find.text('Pemasukan'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const ValueKey('transaction_amount_field')),
        '250000',
      );
      await tester.pumpAndSettle();

      final saveBtn = find.byKey(const ValueKey('transaction_save_button'));
      await tester.ensureVisible(saveBtn);
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(fakeRepository.savedCalls.length, 1);
      expect(fakeRepository.savedCalls.first.type, db.TransactionType.income);
      expect(fakeRepository.savedCalls.first.amount, 250000);
    });

    testWidgets(
      'allows deleting transaction dated today with confirmation (FR-03)',
      (tester) async {
        final todayTx = db.Transaction()
          ..id = 99
          ..type = db.TransactionType.expense
          ..amount = 25000
          ..categoryId = 1
          ..date = DateTime.now()
          ..notes = 'Test delete today';

        fakeRepository = FakeTransactionRepository(
          initialTransactions: [todayTx],
        );

        await pumpScreen(
          tester,
          home: TransactionFormScreen(transaction: todayTx),
        );

        expect(find.text('Edit Transaksi'), findsOneWidget);
        final deleteBtn = find.byKey(
          const ValueKey('transaction_delete_button'),
        );
        await tester.ensureVisible(deleteBtn);
        expect(deleteBtn, findsOneWidget);

        // Tap delete button
        await tester.tap(deleteBtn);
        await tester.pumpAndSettle();

        // Confirmation dialog should be visible
        expect(find.text('Hapus Transaksi?'), findsOneWidget);

        // Tap confirmation 'Hapus' button
        await tester.tap(find.widgetWithText(FilledButton, 'Hapus'));
        await tester.pumpAndSettle();

        expect(fakeRepository.deletedIds, contains(99));
      },
    );

    testWidgets(
      'locks delete button on past transaction and shows FR-03 explanation',
      (tester) async {
        final yesterdayTx = db.Transaction()
          ..id = 88
          ..type = db.TransactionType.expense
          ..amount = 25000
          ..categoryId = 1
          ..date = DateTime.now().subtract(const Duration(days: 2))
          ..notes = 'Past transaction';

        fakeRepository = FakeTransactionRepository(
          initialTransactions: [yesterdayTx],
        );

        await pumpScreen(
          tester,
          home: TransactionFormScreen(transaction: yesterdayTx),
        );

        expect(find.text('Edit Transaksi'), findsOneWidget);
        // Deletable button should NOT be present
        expect(
          find.byKey(const ValueKey('transaction_delete_button')),
          findsNothing,
        );

        // Disabled button with lock icon should be present
        final lockedBtn = find.byKey(
          const ValueKey('transaction_delete_button_disabled'),
        );
        await tester.ensureVisible(lockedBtn);
        expect(lockedBtn, findsOneWidget);
        expect(find.text('Hapus Transaksi (Terkunci)'), findsOneWidget);

        // Informational text referencing FR-03 and integrity of history
        expect(find.textContaining('FR-03'), findsOneWidget);
      },
    );
  });

  group('Dark and Light Theme rendering (antislop R-21, R-34)', () {
    testWidgets(
      'dark theme renders TransactionsScreen and Form without error',
      (tester) async {
        await pumpScreen(tester, theme: AppTheme.dark);
        expect(find.byType(TransactionsScreen), findsOneWidget);

        await pumpScreen(
          tester,
          theme: AppTheme.dark,
          home: const TransactionFormScreen(),
        );
        expect(find.byType(TransactionFormScreen), findsOneWidget);
      },
    );

    testWidgets(
      'light theme renders TransactionsScreen and Form without error',
      (tester) async {
        await pumpScreen(tester, theme: AppTheme.light);
        expect(find.byType(TransactionsScreen), findsOneWidget);

        await pumpScreen(
          tester,
          theme: AppTheme.light,
          home: const TransactionFormScreen(),
        );
        expect(find.byType(TransactionFormScreen), findsOneWidget);
      },
    );
  });
}
