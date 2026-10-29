// M15 Performance Testing (docs/ROADMAP.md M15, PRD NFR §6.1).
//
// Seeds a realistic data volume (per the task brief: 500-1000 transactions
// across several months, multiple wallets/goals/categories) into a REAL
// Isar instance (native MDBX engine, same code path as production — just
// running on this host's Linux binary instead of an Android device/ARM
// binary) and measures actual save/query latency against the <50ms target
// (PRD §6.1), plus the derived in-memory aggregations the UI layer runs on
// every transaction-stream emission (wallet balance computation, budget
// formula adapter) since those are real per-write costs too, not just the
// raw Isar read/write.
//
// Caveat (see docs/PERFORMANCE.md for the full disclosure): these numbers
// are real, measured wall-clock timings of the production code paths
// against the production Isar engine, but captured on this host's hardware
// (dev machine), not an Android device. They are one order-of-magnitude
// correct for relative cost/scaling (which is what matters for catching an
// accidental O(n^2) or a query missing an index as data grows), not a
// certified on-device number — flagged explicitly rather than implied.
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/budget_engine/application/budget_providers.dart';
import 'package:ledgermate/features/wallets/data/wallet_repository.dart';

/// Formats a [Duration] as fractional milliseconds for report-friendly output.
String _ms(Duration d) => '${(d.inMicroseconds / 1000).toStringAsFixed(3)}ms';

void main() {
  late Isar isar;
  late Directory tempDir;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  tearDownAll(() {
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('Isar read/write latency under realistic volume (500-1000 tx, multi-wallet/goal/category)', () async {
    tempDir = Directory.systemTemp.createTempSync('ledgermate_perf_test_');
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'perf_test_${DateTime.now().microsecondsSinceEpoch}',
    );

    // --- Seed realistic dataset -------------------------------------
    final wallets = <Wallet>[];
    await isar.writeTxn(() async {
      for (final spec in [
        ('Dompet Utama', 2000000),
        ('BCA', 5000000),
        ('GoPay', 150000),
        ('Tabungan', 10000000),
      ]) {
        final w = Wallet()
          ..name = spec.$1
          ..icon = 'account_balance_wallet'
          ..startingBalance = spec.$2
          ..includeInDailyBudget = spec.$1 != 'Tabungan'
          ..createdAt = DateTime.now();
        final id = await isar.wallets.put(w);
        w.id = id;
        wallets.add(w);
      }
    });

    final categories = <Category>[];
    await isar.writeTxn(() async {
      for (final name in [
        'Makan',
        'Transport',
        'Hiburan',
        'Tagihan',
        'Lainnya',
        'Belanja',
        'Kesehatan',
        'Pendidikan',
      ]) {
        final c = Category()
          ..name = name
          ..isDefault = true;
        final id = await isar.categorys.put(c);
        c.id = id;
        categories.add(c);
      }
    });

    await isar.writeTxn(() async {
      for (final spec in [
        ('Laptop Baru', 15000000, 2000000, 180),
        ('Dana Darurat', 20000000, 5000000, 365),
        ('Liburan', 8000000, 1000000, 120),
        ('Motor', 25000000, 3000000, 400),
        ('Nikah', 100000000, 10000000, 700),
      ]) {
        final g = FinancialGoal()
          ..goalName = spec.$1
          ..targetAmount = spec.$2
          ..currentAmount = spec.$3
          ..targetDate = DateTime.now().add(Duration(days: spec.$4));
        await isar.financialGoals.put(g);
      }

      final profile = LocalProfile()
        ..fixedSalary = 8000000
        ..incomeFrequency = IncomeFrequency.periodic
        ..nextPaydayDate = DateTime.now().add(const Duration(days: 10));
      await isar.localProfiles.put(profile);

      final cycle = PayCycle()
        ..startDate = DateTime.now().subtract(const Duration(days: 20))
        ..paydayDate = DateTime.now().add(const Duration(days: 10))
        ..fixedSalary = 8000000
        ..variableIncomeTotal = 500000;
      await isar.payCycles.put(cycle);
    });

    const seedCount = 800; // within the brief's 500-1000 range
    final rng = Random(42);
    final now = DateTime.now();

    final seedStopwatch = Stopwatch()..start();
    await isar.writeTxn(() async {
      for (var i = 0; i < seedCount; i++) {
        final daysAgo = rng.nextInt(180); // spread across ~6 months
        final isIncome = rng.nextDouble() < 0.15;
        final wallet = wallets[rng.nextInt(wallets.length)];
        final tx = db.Transaction()
          ..type = isIncome
              ? db.TransactionType.income
              : db.TransactionType.expense
          ..amount = 10000 + rng.nextInt(490000)
          ..categoryId = categories[rng.nextInt(categories.length)].id
          ..date = now.subtract(Duration(days: daysAgo))
          ..notes = i % 7 == 0 ? 'Catatan transaksi #$i' : null
          ..walletId = wallet.id;
        await isar.transactions.put(tx);
      }
    });
    seedStopwatch.stop();
    // ignore: avoid_print
    print(
      '[PERF] Seed $seedCount transactions (single writeTxn, batch insert): '
      '${_ms(seedStopwatch.elapsed)} total, '
      '${_ms(Duration(microseconds: seedStopwatch.elapsed.inMicroseconds ~/ seedCount))} avg/row',
    );

    final totalTxCount = await isar.transactions.count();
    expect(totalTxCount, seedCount);

    // --- 1. Single transaction save latency (FR-02/PRD §6.1: <50ms) --
    // Measures the realistic per-save cost: one row inserted via its own
    // writeTxn against a table that already holds [seedCount] rows (the
    // scenario that matters — not an empty-table save).
    const saveSamples = 50;
    final saveDurations = <Duration>[];
    for (var i = 0; i < saveSamples; i++) {
      final sw = Stopwatch()..start();
      await isar.writeTxn(() async {
        final tx = db.Transaction()
          ..type = db.TransactionType.expense
          ..amount = 25000
          ..categoryId = categories.first.id
          ..date = DateTime.now()
          ..walletId = wallets.first.id;
        final id = await isar.transactions.put(tx);
        tx.id = id;
      });
      sw.stop();
      saveDurations.add(sw.elapsed);
    }
    saveDurations.sort();
    final saveMedian = saveDurations[saveDurations.length ~/ 2];
    final saveMax = saveDurations.last;
    final saveAvgMicros =
        saveDurations.fold<int>(0, (a, b) => a + b.inMicroseconds) /
        saveDurations.length;
    // ignore: avoid_print
    print(
      '[PERF] Single transaction save (n=$saveSamples, table has '
      '${seedCount + saveSamples} rows by the end): '
      'median=${_ms(saveMedian)} avg=${_ms(Duration(microseconds: saveAvgMicros.round()))} '
      'max=${_ms(saveMax)}',
    );
    expect(
      saveMedian.inMilliseconds,
      lessThan(50),
      reason: 'PRD §6.1: transaction save must be <50ms (median)',
    );

    // --- 2. Full-table read (Home/budget engine watchTransactions) ---
    final readSw = Stopwatch()..start();
    final allTxs = await isar.transactions.where().sortByDateDesc().findAll();
    readSw.stop();
    // ignore: avoid_print
    print(
      '[PERF] getTransactions() full scan+sort (${allTxs.length} rows): '
      '${_ms(readSw.elapsed)}',
    );
    expect(readSw.elapsed.inMilliseconds, lessThan(50));

    // --- 3. Ranged query (Analytics month filter) ---------------------
    final rangeSw = Stopwatch()..start();
    final monthTxs = await isar.transactions
        .filter()
        .dateBetween(
          DateTime(now.year, now.month, 1),
          DateTime(now.year, now.month + 1, 0),
        )
        .sortByDateDesc()
        .findAll();
    rangeSw.stop();
    // ignore: avoid_print
    print(
      '[PERF] getTransactionsInRange() 1-month window (${monthTxs.length} '
      'of ${allTxs.length} rows matched): ${_ms(rangeSw.elapsed)}',
    );
    expect(rangeSw.elapsed.inMilliseconds, lessThan(50));

    // --- 4. Wallet balance aggregation (walletBalancesProvider work) --
    // This runs in-memory over the already-fetched transaction list for
    // EVERY wallet, every time the transactions stream emits (any
    // save/delete) — O(wallets * transactions), the one spot flagged by
    // the task brief as "wallet-scoped budget formula" complexity.
    final balanceSw = Stopwatch()..start();
    final balances = <int, int>{};
    for (final w in wallets) {
      balances[w.id] = computeWalletBalance(w, allTxs);
    }
    balanceSw.stop();
    // ignore: avoid_print
    print(
      '[PERF] computeWalletBalance() x${wallets.length} wallets over '
      '${allTxs.length} transactions (full in-memory scan per wallet): '
      '${_ms(balanceSw.elapsed)}',
    );
    expect(balanceSw.elapsed.inMilliseconds, lessThan(50));

    // --- 5. Budget formula adapter (computeDailyBudgetSummary) --------
    final profile = (await isar.localProfiles.where().findFirst())!;
    final latestCycle = await isar.payCycles
        .where()
        .sortByStartDateDesc()
        .findFirst();
    final goals = await isar.financialGoals.where().findAll();
    final formulaSw = Stopwatch()..start();
    final summary = computeDailyBudgetSummary(
      profile: profile,
      latestCycle: latestCycle,
      transactions: allTxs,
      goals: goals,
      includedWalletIds: wallets
          .where((w) => w.includeInDailyBudget)
          .map((w) => w.id)
          .toSet(),
    );
    formulaSw.stop();
    // ignore: avoid_print
    print(
      '[PERF] computeDailyBudgetSummary() over ${allTxs.length} '
      'transactions + ${goals.length} goals: ${_ms(formulaSw.elapsed)} '
      '(result uangJajanAmanHariIni=${summary.uangJajanAmanHariIni})',
    );
    expect(formulaSw.elapsed.inMilliseconds, lessThan(50));

    await isar.close(deleteFromDisk: true);
  });
}
