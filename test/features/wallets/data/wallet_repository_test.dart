import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/wallets/data/wallet_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late WalletRepository repository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: false);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('wallet_repo_test_');
    isar = await Isar.open([
      LocalProfileSchema,
      PayCycleSchema,
      db.TransactionSchema,
      CategorySchema,
      FinancialGoalSchema,
      WalletSchema,
    ], directory: tempDir.path);
    repository = WalletRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('WalletRepository CRUD (FR-12, D16)', () {
    test('saveWallet creates a new wallet when id is null', () async {
      final wallet = await repository.saveWallet(
        name: 'BCA Utama',
        icon: 'account_balance',
        startingBalance: 1500000,
        includeInDailyBudget: true,
      );

      expect(wallet.id, greaterThan(0));
      expect(wallet.name, 'BCA Utama');
      expect(wallet.icon, 'account_balance');
      expect(wallet.startingBalance, 1500000);
      expect(wallet.includeInDailyBudget, isTrue);
      expect(wallet.createdAt, isNotNull);

      final fetched = await repository.getWallet(wallet.id);
      expect(fetched, isNotNull);
      expect(fetched!.name, 'BCA Utama');
    });

    test('saveWallet updates existing wallet when id is provided', () async {
      final created = await repository.saveWallet(
        name: 'Dompet Tunai',
        icon: 'payments',
        startingBalance: 500000,
        includeInDailyBudget: true,
      );

      final updated = await repository.saveWallet(
        id: created.id,
        name: 'Dompet Tunai Fisik',
        icon: 'account_balance_wallet',
        startingBalance: 750000,
        includeInDailyBudget: false,
      );

      expect(updated.id, created.id);
      expect(updated.name, 'Dompet Tunai Fisik');
      expect(updated.icon, 'account_balance_wallet');
      expect(updated.startingBalance, 750000);
      expect(updated.includeInDailyBudget, isFalse);
    });

    test(
      'saveWallet throws ArgumentError on empty name or negative balance',
      () async {
        expect(
          () => repository.saveWallet(
            name: '   ',
            icon: 'payments',
            startingBalance: 1000,
            includeInDailyBudget: true,
          ),
          throwsArgumentError,
        );

        expect(
          () => repository.saveWallet(
            name: 'Gopay',
            icon: 'payments',
            startingBalance: -500,
            includeInDailyBudget: true,
          ),
          throwsArgumentError,
        );
      },
    );

    test('deleteWallet throws WalletDeleteRestrictedException when only 1 wallet remains', () async {
      final onlyWallet = await repository.saveWallet(
        name: 'Main Wallet',
        icon: 'account_balance_wallet',
        startingBalance: 100000,
        includeInDailyBudget: true,
      );

      expect(
        () => repository.deleteWallet(onlyWallet.id),
        throwsA(isA<WalletDeleteRestrictedException>()),
      );
    });

    test('deleteWallet throws WalletHasTransactionsException when transactions reference it', () async {
      final w1 = await repository.saveWallet(
        name: 'Wallet 1',
        icon: 'account_balance_wallet',
        startingBalance: 100000,
        includeInDailyBudget: true,
      );
      final w2 = await repository.saveWallet(
        name: 'Wallet 2',
        icon: 'credit_card',
        startingBalance: 200000,
        includeInDailyBudget: true,
      );

      // Add a transaction referencing w1
      final tx = db.Transaction()
        ..amount = 50000
        ..type = db.TransactionType.expense
        ..date = DateTime.now()
        ..categoryId = 1
        ..walletId = w1.id;
      await isar.writeTxn(() => isar.transactions.put(tx));

      // Attempting to delete w1 should throw
      expect(
        () => repository.deleteWallet(w1.id),
        throwsA(isA<WalletHasTransactionsException>()),
      );

      // Deleting w2 (no transactions) should succeed
      await repository.deleteWallet(w2.id);
      final remaining = await repository.getWallets();
      expect(remaining.length, 1);
      expect(remaining.first.id, w1.id);
    });
  });

  group('Wallet Transfer (FR-13, D16)', () {
    test(
      'transfer creates transfer transaction record with peer links',
      () async {
        final source = await repository.saveWallet(
          name: 'BCA',
          icon: 'account_balance',
          startingBalance: 1000000,
          includeInDailyBudget: true,
        );
        final target = await repository.saveWallet(
          name: 'GoPay',
          icon: 'phone_android',
          startingBalance: 50000,
          includeInDailyBudget: true,
        );

        final date = DateTime.now();
        final tx = await repository.transfer(
          sourceWalletId: source.id,
          targetWalletId: target.id,
          amount: 250000,
          date: date,
          notes: 'Top up GoPay',
        );

        expect(tx.id, greaterThan(0));
        expect(tx.type, db.TransactionType.transfer);
        expect(tx.walletId, source.id);
        expect(tx.transferPeerWalletId, target.id);
        expect(tx.amount, 250000);
        expect(tx.notes, 'Top up GoPay');
        expect(tx.transferGroupId, isNotNull);
      },
    );

    test(
      'transfer validates invalid amounts or identical source/target',
      () async {
        final w1 = await repository.saveWallet(
          name: 'W1',
          icon: 'account_balance_wallet',
          startingBalance: 100000,
          includeInDailyBudget: true,
        );
        final w2 = await repository.saveWallet(
          name: 'W2',
          icon: 'credit_card',
          startingBalance: 200000,
          includeInDailyBudget: true,
        );

        expect(
          () => repository.transfer(
            sourceWalletId: w1.id,
            targetWalletId: w2.id,
            amount: 0,
            date: DateTime.now(),
          ),
          throwsArgumentError,
        );

        expect(
          () => repository.transfer(
            sourceWalletId: w1.id,
            targetWalletId: w1.id,
            amount: 50000,
            date: DateTime.now(),
          ),
          throwsArgumentError,
        );
      },
    );
  });

  group('computeWalletBalance (BR-04, FR-12)', () {
    test('computes balance correctly with income, expense, and transfers', () {
      final wallet = Wallet()
        ..id = 10
        ..name = 'Test Wallet'
        ..startingBalance = 1000000;

      final txs = [
        db.Transaction()
          ..walletId = 10
          ..type = db.TransactionType.income
          ..amount = 500000,
        db.Transaction()
          ..walletId = 10
          ..type = db.TransactionType.expense
          ..amount = 200000,
        db.Transaction()
          ..walletId = 10
          ..transferPeerWalletId = 20
          ..type = db.TransactionType.transfer
          ..amount = 300000,
        db.Transaction()
          ..walletId = 30
          ..transferPeerWalletId = 10
          ..type = db.TransactionType.transfer
          ..amount = 150000,
      ];

      // Expected:
      // 1000000 + 500000 (inc) - 200000 (exp) - 300000 (outgoing trf) + 150000 (incoming trf)
      // = 1150000
      final balance = computeWalletBalance(wallet, txs);
      expect(balance, 1150000);
    });
  });
}
