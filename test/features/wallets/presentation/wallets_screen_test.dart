import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';
import 'package:ledgermate/features/wallets/application/wallet_providers.dart';
import 'package:ledgermate/features/wallets/presentation/transfer_form_screen.dart';
import 'package:ledgermate/features/wallets/presentation/wallet_form_screen.dart';
import 'package:ledgermate/features/wallets/presentation/wallets_screen.dart';

import '../fake_wallet_repository.dart';

void main() {
  late FakeWalletRepository fakeRepo;
  late Wallet w1;
  late Wallet w2;

  setUp(() {
    w1 = Wallet()
      ..id = 1
      ..name = 'Dompet Utama'
      ..icon = 'account_balance_wallet'
      ..startingBalance = 500000
      ..includeInDailyBudget = true
      ..createdAt = DateTime(2026, 1, 1);

    w2 = Wallet()
      ..id = 2
      ..name = 'BCA Tabungan'
      ..icon = 'account_balance'
      ..startingBalance = 2000000
      ..includeInDailyBudget = false
      ..createdAt = DateTime(2026, 1, 2);

    fakeRepo = FakeWalletRepository(initialWallets: [w1, w2]);
  });

  Widget createTestWidget({ThemeMode themeMode = ThemeMode.light}) {
    return ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(fakeRepo),
        transactionsStreamProvider.overrideWith(
          (ref) => Stream.value(<db.Transaction>[]),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData.light(useMaterial3: true),
        darkTheme: ThemeData.dark(useMaterial3: true),
        themeMode: themeMode,
        home: const WalletsScreen(),
      ),
    );
  }

  testWidgets('WalletsScreen renders total net worth and list of wallets', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Verify AppBar
    expect(find.text('Kelola Dompet'), findsOneWidget);

    // Verify Total Saldo Net Worth Card
    expect(
      find.byKey(const ValueKey('wallets_total_saldo_card')),
      findsOneWidget,
    );
    expect(find.text('Total Saldo (Kekayaan Bersih)'), findsOneWidget);
    expect(find.text('Rp 2.500.000'), findsOneWidget);

    // Verify Wallet items
    expect(find.text('Dompet Utama'), findsOneWidget);
    expect(find.text('BCA Tabungan'), findsOneWidget);
    expect(find.text('Ikut Budget Harian'), findsOneWidget);
    expect(find.text('Di luar Budget'), findsOneWidget);
    expect(find.text('Rp 500.000'), findsOneWidget);
    expect(find.text('Rp 2.000.000'), findsOneWidget);
  });

  testWidgets(
    'WalletsScreen renders correctly in dark theme (docs/DESIGN.md R-21)',
    (tester) async {
      await tester.pumpWidget(createTestWidget(themeMode: ThemeMode.dark));
      await tester.pumpAndSettle();

      expect(find.text('Kelola Dompet'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('wallets_total_saldo_card')),
        findsOneWidget,
      );
      expect(find.text('Dompet Utama'), findsOneWidget);
    },
  );

  testWidgets('WalletsScreen navigates to WalletFormScreen on FAB click', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    final fab = find.byKey(const ValueKey('add_wallet_fab'));
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();

    expect(find.byType(WalletFormScreen), findsOneWidget);
    expect(find.text('Tambah Dompet'), findsOneWidget);
  });

  testWidgets(
    'WalletsScreen navigates to TransferFormScreen on quick transfer click',
    (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final transferBtn = find.byKey(
        const ValueKey('wallets_quick_transfer_button'),
      );
      expect(transferBtn, findsOneWidget);
      await tester.tap(transferBtn);
      await tester.pumpAndSettle();

      expect(find.byType(TransferFormScreen), findsOneWidget);
      expect(find.text('Transfer Antar Dompet'), findsOneWidget);
    },
  );

  testWidgets('WalletsScreen deletes a wallet after confirmation', (
    tester,
  ) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Tap popup menu for w2
    final menuBtn = find.byKey(ValueKey('wallet_menu_${w2.id}'));
    expect(menuBtn, findsOneWidget);
    await tester.tap(menuBtn);
    await tester.pumpAndSettle();

    final deleteOption = find.text('Hapus');
    expect(deleteOption, findsOneWidget);
    await tester.tap(deleteOption);
    await tester.pumpAndSettle();

    // Confirmation dialog should appear
    expect(find.text('Hapus Dompet?'), findsOneWidget);
    final confirmDeleteBtn = find.widgetWithText(FilledButton, 'Hapus');
    expect(confirmDeleteBtn, findsOneWidget);
    await tester.tap(confirmDeleteBtn);
    await tester.pumpAndSettle();

    // w2 should now be removed
    expect(find.text('BCA Tabungan'), findsNothing);
    expect(find.text('Dompet Utama'), findsOneWidget);
  });
}
