// Unit tests for computeModeBYesterdayCarryOver (D18/M16 bug #4).
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/pay_cycle/application/pay_cycle_providers.dart';

void main() {
  group('computeModeBYesterdayCarryOver (D18/M16 bug #4)', () {
    final budgetWallet = Wallet()
      ..id = 1
      ..name = 'Tunai'
      ..includeInDailyBudget = true
      ..createdAt = DateTime(2026, 1, 1);
    final savingsWallet = Wallet()
      ..id = 2
      ..name = 'Tabungan'
      ..includeInDailyBudget = false
      ..createdAt = DateTime(2026, 1, 1);

    test('(a) a transfer is NOT counted as an expense — net-neutral per D16 when both ends are budget-scoped', () {
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.daily
        ..carryOverBalance = 100000
        ..lastRolloverDate = DateTime(2026, 10, 26);

      // A transfer entirely within budget-scoped wallets on the elapsed
      // day — the OLD code treated every non-income transaction as an
      // expense (including transfers), which would have wrongly
      // subtracted this from the carry-over.
      final transferTx = db.Transaction()
        ..type = db.TransactionType.transfer
        ..amount = 500000
        ..walletId = budgetWallet.id
        ..transferPeerWalletId = budgetWallet
            .id // same-scope, net zero
        ..date = DateTime(2026, 10, 27);

      final carryOverIgnoringTransfer = computeModeBYesterdayCarryOver(
        profile: profile,
        transactions: [transferTx],
        wallets: [budgetWallet],
        goals: const [],
        referenceNow: DateTime(2026, 10, 28),
      );

      // No transfer at all should produce the exact same result.
      final carryOverNoTx = computeModeBYesterdayCarryOver(
        profile: profile,
        transactions: const [],
        wallets: [budgetWallet],
        goals: const [],
        referenceNow: DateTime(2026, 10, 28),
      );

      expect(carryOverIgnoringTransfer, carryOverNoTx);
      // Sanity: unspent carry-over simply persists when nothing happened.
      expect(carryOverNoTx, 100000);
    });

    test('(b) transactions in a non-budget wallet (includeInDailyBudget=false) are excluded per BR-04', () {
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.daily
        ..carryOverBalance = 100000
        ..lastRolloverDate = DateTime(2026, 10, 26);

      final savingsExpense = db.Transaction()
        ..type = db.TransactionType.expense
        ..amount =
            9000000 // huge — would blow the carry-over deeply negative if wrongly counted
        ..walletId = savingsWallet.id
        ..date = DateTime(2026, 10, 27);

      final carryOver = computeModeBYesterdayCarryOver(
        profile: profile,
        transactions: [savingsExpense],
        wallets: [budgetWallet, savingsWallet],
        goals: const [],
        referenceNow: DateTime(2026, 10, 28),
      );

      // Unaffected by the non-budget wallet's expense — only budget-scoped
      // transactions should be summed.
      expect(carryOver, 100000);
    });

    test('(c) catches up MULTIPLE skipped days in order, not just the single most recent one', () {
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.daily
        ..carryOverBalance = 0
        // App wasn't opened for 3 days — last rollover was Oct 24.
        ..lastRolloverDate = DateTime(2026, 10, 24);

      // Income of 50,000 recorded on each of the 3 skipped days
      // (Oct 25, 26, 27), none spent.
      final transactions = [
        db.Transaction()
          ..type = db.TransactionType.income
          ..amount = 50000
          ..walletId = budgetWallet.id
          ..date = DateTime(2026, 10, 25),
        db.Transaction()
          ..type = db.TransactionType.income
          ..amount = 50000
          ..walletId = budgetWallet.id
          ..date = DateTime(2026, 10, 26),
        db.Transaction()
          ..type = db.TransactionType.income
          ..amount = 50000
          ..walletId = budgetWallet.id
          ..date = DateTime(2026, 10, 27),
      ];

      // Today is Oct 28 — yesterday (Oct 27) is the last day to catch up.
      final carryOver = computeModeBYesterdayCarryOver(
        profile: profile,
        transactions: transactions,
        wallets: [budgetWallet],
        goals: const [],
        referenceNow: DateTime(2026, 10, 28),
      );

      // Each of the 3 skipped days accrues 50,000 unspent — the OLD
      // single-day implementation would only have picked up ONE day
      // (50,000), silently dropping the other two.
      expect(carryOver, 150000);
    });

    test('no catch-up needed when already processed through yesterday', () {
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.daily
        ..carryOverBalance = 77000
        ..lastRolloverDate = DateTime(2026, 10, 27);

      final carryOver = computeModeBYesterdayCarryOver(
        profile: profile,
        transactions: const [],
        wallets: [budgetWallet],
        goals: const [],
        referenceNow: DateTime(2026, 10, 28),
      );

      expect(carryOver, 77000);
    });
  });
}
