import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/wallets/application/wallet_providers.dart';
import 'package:ledgermate/features/wallets/presentation/wallet_form_screen.dart';

import '../fake_wallet_repository.dart';

void main() {
  late FakeWalletRepository fakeRepo;

  setUp(() {
    fakeRepo = FakeWalletRepository();
  });

  Widget createTestWidget({Wallet? wallet}) {
    return ProviderScope(
      overrides: [walletRepositoryProvider.overrideWithValue(fakeRepo)],
      child: MaterialApp(home: WalletFormScreen(wallet: wallet)),
    );
  }

  testWidgets('renders create form and saves new wallet', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Tambah Dompet'), findsOneWidget);
    expect(find.byKey(const ValueKey('wallet_name_field')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('wallet_starting_balance_field')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('wallet_include_budget_switch')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('wallet_save_button')), findsOneWidget);

    // Enter name & balance
    await tester.enterText(
      find.byKey(const ValueKey('wallet_name_field')),
      'Bank Mandiri',
    );
    await tester.enterText(
      find.byKey(const ValueKey('wallet_starting_balance_field')),
      '1250000',
    );
    await tester.pumpAndSettle();

    // Tap save
    await tester.tap(find.byKey(const ValueKey('wallet_save_button')));
    await tester.pumpAndSettle();

    // Verify saved in repository
    final wallets = await fakeRepo.getWallets();
    expect(wallets.length, 1);
    final saved = wallets.first;
    expect(saved.name, 'Bank Mandiri');
    expect(saved.startingBalance, 1250000);
    expect(saved.includeInDailyBudget, isTrue);
  });

  testWidgets('renders edit form with initial values and updates wallet', (
    tester,
  ) async {
    final existing = Wallet()
      ..id = 42
      ..name = 'OVO Cash'
      ..icon = 'account_balance_wallet'
      ..startingBalance = 75000
      ..includeInDailyBudget = false;
    await fakeRepo.saveWallet(
      id: 42,
      name: 'OVO Cash',
      icon: 'account_balance_wallet',
      startingBalance: 75000,
      includeInDailyBudget: false,
    );

    await tester.pumpWidget(createTestWidget(wallet: existing));
    await tester.pumpAndSettle();

    expect(find.text('Edit Dompet'), findsOneWidget);
    expect(find.text('OVO Cash'), findsOneWidget);
    expect(find.text('75.000'), findsOneWidget);

    // Edit name
    await tester.enterText(
      find.byKey(const ValueKey('wallet_name_field')),
      'OVO Premier',
    );
    await tester.pumpAndSettle();

    // Tap save
    await tester.tap(find.byKey(const ValueKey('wallet_save_button')));
    await tester.pumpAndSettle();

    final fetched = await fakeRepo.getWallet(42);
    expect(fetched, isNotNull);
    expect(fetched!.name, 'OVO Premier');
  });

  testWidgets('validates required wallet name on submit', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    // Try to save with empty name
    await tester.tap(find.byKey(const ValueKey('wallet_save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Nama dompet tidak boleh kosong'), findsOneWidget);
    final wallets = await fakeRepo.getWallets();
    expect(wallets, isEmpty);
  });
}
