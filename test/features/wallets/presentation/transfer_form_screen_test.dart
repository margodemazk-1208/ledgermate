import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';
import 'package:ledgermate/features/wallets/application/wallet_providers.dart';
import 'package:ledgermate/features/wallets/presentation/transfer_form_screen.dart';

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
      ..startingBalance = 1000000
      ..includeInDailyBudget = true
      ..createdAt = DateTime(2026, 1, 1);

    w2 = Wallet()
      ..id = 2
      ..name = 'BCA Rekening'
      ..icon = 'account_balance'
      ..startingBalance = 5000000
      ..includeInDailyBudget = false
      ..createdAt = DateTime(2026, 1, 2);
  });

  Widget createTestWidget({required FakeWalletRepository repo}) {
    return ProviderScope(
      overrides: [
        walletRepositoryProvider.overrideWithValue(repo),
        transactionsStreamProvider.overrideWith(
          (ref) => Stream.value(<db.Transaction>[]),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const TransferFormScreen(),
      ),
    );
  }

  testWidgets('shows warning when less than 2 wallets exist', (tester) async {
    fakeRepo = FakeWalletRepository(initialWallets: [w1]);

    await tester.pumpWidget(createTestWidget(repo: fakeRepo));
    await tester.pumpAndSettle();

    expect(
      find.text('Butuh minimal 2 dompet untuk melakukan transfer.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('transfer_submit_button')), findsNothing);
  });

  testWidgets('renders fields and submits transfer with valid inputs', (
    tester,
  ) async {
    fakeRepo = FakeWalletRepository(initialWallets: [w1, w2]);

    await tester.pumpWidget(createTestWidget(repo: fakeRepo));
    await tester.pumpAndSettle();

    // Check fields exist
    expect(
      find.byKey(const ValueKey('transfer_source_wallet_picker')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('transfer_target_wallet_picker')),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('transfer_amount_field')), findsOneWidget);
    expect(find.byKey(const ValueKey('transfer_notes_field')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('transfer_submit_button')),
      findsOneWidget,
    );

    // Fill amount
    await tester.enterText(
      find.byKey(const ValueKey('transfer_amount_field')),
      '150000',
    );
    await tester.enterText(
      find.byKey(const ValueKey('transfer_notes_field')),
      'Transfer bulanan',
    );
    await tester.pumpAndSettle();

    // Tap submit
    await tester.tap(find.byKey(const ValueKey('transfer_submit_button')));
    await tester.pumpAndSettle();

    // Verify recorded transaction in fake repository
    expect(fakeRepo.recordedTransactions.length, 1);
    final tx = fakeRepo.recordedTransactions.first;
    expect(tx.type, db.TransactionType.transfer);
    expect(tx.amount, 150000);
    expect(tx.walletId, 1);
    expect(tx.transferPeerWalletId, 2);
    expect(tx.notes, 'Transfer bulanan');
  });
}
