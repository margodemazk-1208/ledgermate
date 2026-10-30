import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart';
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/budget_engine/application/budget_providers.dart';
import 'package:ledgermate/features/goals/data/goals_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late GoalsRepository repository;
  var instanceCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('goals_repo_test_');
    instanceCounter++;
    // Uses the real `openLedgerMateIsar` (not a bare `Isar.open`) so the
    // Wallet collection — required by `withdrawFromGoal`'s wallet-resolution
    // fix (D18/M16 bug #2) — is always registered, matching production.
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'goals_repo_test_$instanceCounter',
    );
    repository = GoalsRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  /// Seeds a real budget-included wallet, matching the minimum post-
  /// onboarding state (FR-01 requires at least 1 wallet).
  Future<Wallet> seedWallet({String name = 'Dompet Utama'}) async {
    final wallet = Wallet()
      ..name = name
      ..icon = 'account_balance_wallet'
      ..startingBalance = 0
      ..includeInDailyBudget = true
      ..createdAt = DateTime(2026, 1, 1);
    await isar.writeTxn(() => isar.wallets.put(wallet));
    return wallet;
  }

  group('GoalsRepository CRUD (FR-06)', () {
    test('saveGoal creates new goal when id is null', () async {
      final targetDate = DateTime(2026, 12, 31);
      final goal = await repository.saveGoal(
        name: 'Dana Darurat',
        targetAmount: 5000000,
        currentAmount: 1000000,
        targetDate: targetDate,
        manualDailyAllocation: 50000,
      );

      expect(goal.id, greaterThan(0));
      expect(goal.goalName, 'Dana Darurat');
      expect(goal.targetAmount, 5000000);
      expect(goal.currentAmount, 1000000);
      expect(goal.targetDate, targetDate);
      expect(goal.manualDailyAllocation, 50000);

      final fetched = await repository.getGoalById(goal.id);
      expect(fetched, isNotNull);
      expect(fetched!.goalName, 'Dana Darurat');
    });

    test('saveGoal updates existing goal when id is provided', () async {
      final initial = await repository.saveGoal(
        name: 'Laptop Baru',
        targetAmount: 15000000,
        currentAmount: 2000000,
        targetDate: DateTime(2027, 1, 1),
      );

      final updated = await repository.saveGoal(
        id: initial.id,
        name: 'Laptop Gaming Baru',
        targetAmount: 18000000,
        currentAmount: 5000000,
        targetDate: DateTime(2027, 3, 1),
        manualDailyAllocation: 75000,
      );

      expect(updated.id, initial.id);
      expect(updated.goalName, 'Laptop Gaming Baru');
      expect(updated.targetAmount, 18000000);
      expect(updated.currentAmount, 5000000);
      expect(updated.manualDailyAllocation, 75000);

      final all = await repository.getAllGoals();
      expect(all.length, 1);
    });

    test('deleteGoal removes goal from database', () async {
      final goal = await repository.saveGoal(
        name: 'Liburan',
        targetAmount: 3000000,
        currentAmount: 500000,
        targetDate: DateTime(2026, 11, 30),
      );

      expect(await repository.getGoalById(goal.id), isNotNull);

      final deleted = await repository.deleteGoal(goal.id);
      expect(deleted, isTrue);
      expect(await repository.getGoalById(goal.id), isNull);
    });

    test('watchGoals emits updated goals stream', () async {
      final stream = repository.watchGoals();
      expectLater(
        stream,
        emitsInOrder([hasLength(0), hasLength(1), hasLength(2)]),
      );

      await repository.saveGoal(
        name: 'Goal 1',
        targetAmount: 1000000,
        targetDate: DateTime(2026, 12, 1),
      );

      await repository.saveGoal(
        name: 'Goal 2',
        targetAmount: 2000000,
        targetDate: DateTime(2027, 1, 1),
      );
    });
  });

  group('GoalsRepository Withdrawal (FR-06c)', () {
    test('Mode A: withdraws from goal and credits active PayCycle and creates income transaction', () async {
      final wallet = await seedWallet();

      // Seed active PayCycle (Mode A)
      final cycle = PayCycle()
        ..startDate = DateTime(2026, 10, 1)
        ..paydayDate = DateTime(2026, 10, 31)
        ..fixedSalary = 10000000
        ..mandatoryExpenses = [
          MandatoryExpenseItem()
            ..name = 'Mandatory'
            ..amount = 2000000,
        ]
        ..variableIncomeTotal = 100000;
      await isar.writeTxn(() => isar.payCycles.put(cycle));

      final goal = await repository.saveGoal(
        name: 'Dana Darurat',
        targetAmount: 5000000,
        currentAmount: 2000000,
        targetDate: DateTime(2027, 1, 1),
      );

      // Withdraw 500,000
      final updatedGoal = await repository.withdrawFromGoal(
        goalId: goal.id,
        amount: 500000,
      );

      expect(updatedGoal.currentAmount, 1500000);

      // Verify cycle was updated
      final updatedCycle = await isar.payCycles.get(cycle.id);
      expect(updatedCycle!.variableIncomeTotal, 100000 + 500000);

      // Verify income transaction was recorded
      final txs = await isar.transactions.where().findAll();
      expect(txs.length, 1);
      final tx = txs.first;
      expect(tx.type, TransactionType.income);
      expect(tx.amount, 500000);
      expect(tx.payCycleId, cycle.id);
      expect(tx.notes, contains('Dana Darurat'));

      // D18/M16 bug #2 regression: the withdrawal must be attributed to a
      // REAL wallet (never 0 — walletId=0 never reached any wallet's
      // computed balance and tripped the v1.1 migration's orphan-detection
      // on next app open) and a dedicated system category (never whatever
      // category happened to be first — "Makan" in practice).
      expect(tx.walletId, wallet.id);
      expect(tx.walletId, isNot(0));
      final cat = await isar.categorys.get(tx.categoryId);
      expect(cat, isNotNull);
      expect(cat!.isSystemGenerated, isTrue);
      expect(cat.name, isNot('Makan'));
    });

    test('Mode B: withdraws from goal, credits today\'s bekel income exactly once (no carryOverBalance double-count)', () async {
      final wallet = await seedWallet();

      // Seed profile with carryOverBalance (Mode B)
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.daily
        ..carryOverBalance = 250000
        ..onboardingComplete = true;
      await isar.writeTxn(() => isar.localProfiles.put(profile));

      final goal = await repository.saveGoal(
        name: 'Modal Dagang',
        targetAmount: 3000000,
        currentAmount: 1000000,
        targetDate: DateTime(2027, 2, 1),
      );

      final now = DateTime(2026, 10, 30, 9, 0);

      // Withdraw 400,000
      final updatedGoal = await repository.withdrawFromGoal(
        goalId: goal.id,
        amount: 400000,
        referenceNow: now,
      );

      expect(updatedGoal.currentAmount, 600000);

      // D18/M16 bug #2 fix: `carryOverBalance` must NOT be mutated directly
      // by the withdrawal anymore — the OLD code incremented it here AND
      // recorded an income transaction dated today, double-counting the
      // exact same withdrawal (once forever via carryOverBalance, once for
      // today via the transaction). It stays at its pre-withdrawal value;
      // the withdrawn amount reaches the budget via the recorded
      // transaction (today's bekel income) exactly once.
      final updatedProfile = await isar.localProfiles.where().findFirst();
      expect(updatedProfile!.carryOverBalance, 250000);

      // Verify income transaction was recorded (Mode B transaction has null payCycleId)
      final txs = await isar.transactions.where().findAll();
      expect(txs.length, 1);
      final tx = txs.first;
      expect(tx.type, TransactionType.income);
      expect(tx.amount, 400000);
      expect(tx.payCycleId, isNull);
      expect(tx.walletId, wallet.id);
      expect(tx.date, now);

      // Prove the fix end-to-end: run it through the SAME formula adapter
      // Home uses and confirm the withdrawn 400,000 appears in
      // `uangJajanAmanHariIni` EXACTLY ONCE (250,000 carry-over + 400,000
      // today's bekel == 650,000), not 1,050,000 (which the old
      // double-counting bug would have produced).
      final summary = computeDailyBudgetSummary(
        profile: updatedProfile,
        transactions: txs,
        goals: const [],
        includedWalletIds: {wallet.id},
        referenceNow: now,
      );
      expect(summary.uangJajanAmanHariIni, 250000 + 400000);
    });

    test(
      'throws ArgumentError if withdrawal amount exceeds currentAmount',
      () async {
        await seedWallet();
        final goal = await repository.saveGoal(
          name: 'Tabungan Kecil',
          targetAmount: 1000000,
          currentAmount: 300000,
          targetDate: DateTime(2027, 1, 1),
        );

        expect(
          () => repository.withdrawFromGoal(goalId: goal.id, amount: 500000),
          throwsA(isA<ArgumentError>()),
        );
      },
    );

    test('throws ArgumentError if withdrawal amount is <= 0', () async {
      await seedWallet();
      final goal = await repository.saveGoal(
        name: 'Tabungan',
        targetAmount: 1000000,
        currentAmount: 300000,
        targetDate: DateTime(2027, 1, 1),
      );

      expect(
        () => repository.withdrawFromGoal(goalId: goal.id, amount: 0),
        throwsA(isA<ArgumentError>()),
      );
      expect(
        () => repository.withdrawFromGoal(goalId: goal.id, amount: -10000),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('routes withdrawal through a real wallet even if other categories exist (D18/M16 bug #2 regression)', () async {
      await seedWallet();
      // Seed the default categories, "Makan" first — the exact scenario
      // that caused the original bug ("whatever category happens to be
      // first" picked "Makan" in practice).
      await isar.writeTxn(() async {
        for (final name in ['Makan', 'Transport', 'Hiburan']) {
          await isar.categorys.put(
            Category()
              ..name = name
              ..isDefault = true,
          );
        }
      });

      final goal = await repository.saveGoal(
        name: 'Dana Pendidikan',
        targetAmount: 2000000,
        currentAmount: 1000000,
        targetDate: DateTime(2027, 1, 1),
      );

      await repository.withdrawFromGoal(goalId: goal.id, amount: 200000);

      final tx = (await isar.transactions.where().findAll()).single;
      final usedCategory = await isar.categorys.get(tx.categoryId);
      expect(usedCategory!.name, isNot('Makan'));
      expect(usedCategory.isSystemGenerated, isTrue);
    });
  });
}
