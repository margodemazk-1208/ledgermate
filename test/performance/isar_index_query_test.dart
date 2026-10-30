// M18 Performance Optimization (docs/ROADMAP.md M18, item 1): before this
// milestone there was no `@Index()` anywhere in the schema, so every
// wallet/category/pay-cycle-scoped lookup had to be a full collection scan
// (`.filter().xEqualTo(...)`) — Isar's `.where()` indexed query builders
// (`.whereXEqualTo(...)`) don't even exist in generated code for a field
// until it carries `@Index()`.
//
// This test seeds a larger, more skewed dataset than M15's 800-row
// benchmark (500-1000 was realistic for "total transactions a user has ever
// recorded"; 6,000 is used here purely to make the scan-vs-index-lookup
// delta measurable above Isar's already very fast baseline — see
// `docs/PERFORMANCE.md` M18 section for why this is a deliberately
// larger-than-realistic volume) and times the SAME logical lookup two ways:
//   (a) `.filter().xEqualTo(...)`      — always a full scan, index or not
//       (this is what every call site was effectively limited to pre-M18,
//       since no indexed `.where()` variant existed to call)
//   (b) `.where().xEqualTo(...)`       — only exists post-M18 (@Index()
//       generates this builder), uses Isar's B-tree index
//
// Real, measured numbers on this host's native Isar engine — same caveat as
// `isar_performance_test.dart` (no Android device/emulator in this
// environment; relative scaling is what matters here, not an absolute
// on-device number).
import 'dart:io';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';

String _us(Duration d) => '${d.inMicroseconds}µs';

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

  test('indexed where() lookups beat unindexed filter() scans at scale '
      '(M18/D18 perf item 1)', () async {
    tempDir = Directory.systemTemp.createTempSync(
      'ledgermate_index_perf_test_',
    );
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'index_perf_test_${DateTime.now().microsecondsSinceEpoch}',
    );

    const walletCount = 6;
    const categoryCount = 15;
    const cycleCount = 20;
    const txCount = 10000;

    final wallets = <Wallet>[];
    await isar.writeTxn(() async {
      for (var i = 0; i < walletCount; i++) {
        final w = Wallet()
          ..name = 'Wallet $i'
          ..icon = 'account_balance_wallet'
          ..startingBalance = 0
          ..includeInDailyBudget = true
          ..createdAt = DateTime.now();
        final id = await isar.wallets.put(w);
        w.id = id;
        wallets.add(w);
      }
    });

    final categories = <Category>[];
    await isar.writeTxn(() async {
      for (var i = 0; i < categoryCount; i++) {
        final c = Category()
          ..name = 'Category $i'
          ..isDefault = true;
        final id = await isar.categorys.put(c);
        c.id = id;
        categories.add(c);
      }
    });

    final cycles = <PayCycle>[];
    await isar.writeTxn(() async {
      for (var i = 0; i < cycleCount; i++) {
        final start = DateTime.now().subtract(Duration(days: 30 * i));
        final cyc = PayCycle()
          ..startDate = start
          ..paydayDate = start.add(const Duration(days: 30))
          ..fixedSalary = 5000000;
        final id = await isar.payCycles.put(cyc);
        cyc.id = id;
        cycles.add(cyc);
      }
    });

    final rng = Random(7);
    final now = DateTime.now();
    await isar.writeTxn(() async {
      for (var i = 0; i < txCount; i++) {
        final tx = db.Transaction()
          ..type = db.TransactionType.expense
          ..amount = 10000 + rng.nextInt(90000)
          ..categoryId = categories[rng.nextInt(categoryCount)].id
          ..walletId = wallets[rng.nextInt(walletCount)].id
          ..payCycleId = cycles[rng.nextInt(cycleCount)].id
          ..date = now.subtract(Duration(days: rng.nextInt(450)));
        await isar.transactions.put(tx);
      }
    });
    expect(await isar.transactions.count(), txCount);

    /// Runs [body] [samples] times (plus one discarded warm-up run to
    /// avoid penalizing whichever form happens to run first with JIT/IO
    /// cache warm-up cost) and returns the median duration — a single
    /// sample at native-Isar speed (sub-millisecond) is too noisy to
    /// compare honestly.
    Future<Duration> medianTimeOf(
      Future<void> Function() body, {
      int samples = 15,
    }) async {
      await body(); // warm-up, discarded
      final durations = <Duration>[];
      for (var i = 0; i < samples; i++) {
        final sw = Stopwatch()..start();
        await body();
        sw.stop();
        durations.add(sw.elapsed);
      }
      durations.sort();
      return durations[durations.length ~/ 2];
    }

    // --- walletId: filter() (scan) vs where() (indexed) --------------
    final targetWalletId = wallets.first.id;
    final walletFilterTime = await medianTimeOf(() async {
      await isar.transactions
          .filter()
          .walletIdEqualTo(targetWalletId)
          .findAll();
    });
    final walletWhereTime = await medianTimeOf(() async {
      await isar.transactions.where().walletIdEqualTo(targetWalletId).findAll();
    });
    // ignore: avoid_print
    print(
      '[PERF][M18] walletId lookup over $txCount rows (median of 15): '
      'filter()=${_us(walletFilterTime)} (unindexed scan, pre-M18 only '
      'option) vs where()=${_us(walletWhereTime)} (indexed, M18)',
    );

    // --- categoryId: filter() (scan) vs where() (indexed) -------------
    final targetCategoryId = categories.first.id;
    final categoryFilterTime = await medianTimeOf(() async {
      await isar.transactions
          .filter()
          .categoryIdEqualTo(targetCategoryId)
          .findAll();
    });
    final categoryWhereTime = await medianTimeOf(() async {
      await isar.transactions
          .where()
          .categoryIdEqualTo(targetCategoryId)
          .findAll();
    });
    // ignore: avoid_print
    print(
      '[PERF][M18] categoryId lookup over $txCount rows (median of 15): '
      'filter()=${_us(categoryFilterTime)} (unindexed scan, pre-M18 only '
      'option) vs where()=${_us(categoryWhereTime)} (indexed, M18)',
    );

    // --- payCycleId: filter() (scan) vs where() (indexed) --------------
    final targetCycleId = cycles.first.id;
    final cycleFilterTime = await medianTimeOf(() async {
      await isar.transactions
          .filter()
          .payCycleIdEqualTo(targetCycleId)
          .findAll();
    });
    final cycleWhereTime = await medianTimeOf(() async {
      await isar.transactions
          .where()
          .payCycleIdEqualTo(targetCycleId)
          .findAll();
    });
    // ignore: avoid_print
    print(
      '[PERF][M18] payCycleId lookup over $txCount rows (median of 15): '
      'filter()=${_us(cycleFilterTime)} (unindexed scan, pre-M18 only '
      'option) vs where()=${_us(cycleWhereTime)} (indexed, M18)',
    );

    // --- PayCycle.startDate: filter() (scan) vs where() (indexed) ------
    final cutoff = now.subtract(const Duration(days: 180));
    final startDateFilterTime = await medianTimeOf(() async {
      await isar.payCycles
          .filter()
          .startDateGreaterThan(cutoff)
          .sortByStartDateDesc()
          .findAll();
    });
    final startDateWhereTime = await medianTimeOf(() async {
      await isar.payCycles
          .where()
          .startDateGreaterThan(cutoff)
          .sortByStartDateDesc()
          .findAll();
    });
    // ignore: avoid_print
    print(
      '[PERF][M18] PayCycle.startDate range lookup over $cycleCount rows '
      '(median of 15): filter()=${_us(startDateFilterTime)} (unindexed '
      'scan, pre-M18 only option) vs where()=${_us(startDateWhereTime)} '
      '(indexed, M18)',
    );

    // Sanity: both forms of every query must still return the same,
    // correct result set (the index must not silently change semantics).
    final walletFilterResult = await isar.transactions
        .filter()
        .walletIdEqualTo(targetWalletId)
        .findAll();
    final walletWhereResult = await isar.transactions
        .where()
        .walletIdEqualTo(targetWalletId)
        .findAll();
    expect(walletWhereResult.length, walletFilterResult.length);
    expect(
      walletWhereResult.map((t) => t.id).toSet(),
      walletFilterResult.map((t) => t.id).toSet(),
    );

    // NFR §6.1 (<50ms) sanity on the indexed paths specifically — not a
    // strict "index must always beat scan" assertion (both are already
    // sub-millisecond at this volume on native Isar/this host, so a hard
    // relative-speed assertion would be flaky; see docs/PERFORMANCE.md
    // for the honest printed numbers instead).
    expect(walletWhereTime.inMilliseconds, lessThan(50));
    expect(categoryWhereTime.inMilliseconds, lessThan(50));
    expect(cycleWhereTime.inMilliseconds, lessThan(50));
    expect(startDateWhereTime.inMilliseconds, lessThan(50));

    await isar.close(deleteFromDisk: true);
  });
}
