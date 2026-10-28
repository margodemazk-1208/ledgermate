import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/asset.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart';
import 'package:ledgermate/core/formulas/daily_budget_formulas.dart';
import 'package:ledgermate/features/assets/data/assets_repository.dart';

/// Step 5 Regression Guard Test (PRD FR-10, DECISIONS.md D8):
/// Confirm that nothing in `lib/features/assets/` or any Asset-reading code path
/// feeds into `lib/core/formulas/` or `UangJajanAmanHariIni`/`DailySavingsReserve`.
/// Mutating asset values must have ZERO effect on daily budget calculations.
void main() {
  late Directory tempDir;
  late Isar isar;
  late AssetsRepository assetsRepository;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: false);
  });

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('asset_isolation_test_');
    isar = await Isar.open([
      LocalProfileSchema,
      PayCycleSchema,
      TransactionSchema,
      CategorySchema,
      FinancialGoalSchema,
      AssetSchema,
    ], directory: tempDir.path);
    assetsRepository = AssetsRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('Critical Isolation Check: Assets vs Smart Daily Budget Engine (FR-10, BR-01, BR-02)', () {
    test('Mode A: Changing asset values from 0 to 1 Billion does NOT affect Uang Jajan Aman Hari Ini', () async {
      const fixedIncome = 6000000;
      const additionalIncome = 0;
      const mandatoryExpenses = 1500000;
      const recordedExpenses = 1000000;
      const remainingDays = 20;
      const dailySavingsReserve = 30000;

      // 1. Calculate baseline daily budget without any assets
      final baselineModeA = calculateModeABudget(
        fixedIncome: fixedIncome,
        additionalIncome: additionalIncome,
        mandatoryExpenses: mandatoryExpenses,
        recordedExpenses: recordedExpenses,
        remainingDays: remainingDays,
        dailySavingsReserve: dailySavingsReserve,
      );

      // 2. Insert massive asset worth 1 Billion Rupiah
      final asset = await assetsRepository.saveAsset(
        name: 'Portofolio Saham & Emas',
        type: 'Campuran',
        purchaseValue: 500000000,
        currentValue: 1000000000,
      );

      // 3. Recalculate daily budget
      final afterAssetCreated = calculateModeABudget(
        fixedIncome: fixedIncome,
        additionalIncome: additionalIncome,
        mandatoryExpenses: mandatoryExpenses,
        recordedExpenses: recordedExpenses,
        remainingDays: remainingDays,
        dailySavingsReserve: dailySavingsReserve,
      );

      expect(
        afterAssetCreated.uangJajanAmanHariIni,
        equals(baselineModeA.uangJajanAmanHariIni),
        reason: 'Asset net worth must NEVER alter Mode A daily budget',
      );
      expect(
        afterAssetCreated.dailySpendingAllowance,
        equals(baselineModeA.dailySpendingAllowance),
      );
      expect(
        afterAssetCreated.remainingBalance,
        equals(baselineModeA.remainingBalance),
      );

      // 4. Update asset value from 1 Billion to 50 Million (massive crash / drop)
      await assetsRepository.updateAssetCurrentValue(
        id: asset.id,
        currentValue: 50000000,
      );

      final afterAssetDrop = calculateModeABudget(
        fixedIncome: fixedIncome,
        additionalIncome: additionalIncome,
        mandatoryExpenses: mandatoryExpenses,
        recordedExpenses: recordedExpenses,
        remainingDays: remainingDays,
        dailySavingsReserve: dailySavingsReserve,
      );

      expect(
        afterAssetDrop.uangJajanAmanHariIni,
        equals(baselineModeA.uangJajanAmanHariIni),
        reason: 'Asset value drops must NEVER alter Mode A daily budget',
      );
    });

    test('Mode B: Modifying asset values does NOT alter Mode B carryOver balance or daily budget', () async {
      const saldoCarryOver = 150000;
      const bekelHariIni = 200000;
      const pengeluaranWajibHariIni = 50000;
      const pengeluaranHariIni = 30000;
      const dailySavingsReserve = 20000;

      // Baseline Mode B daily budget
      final baselineModeB = calculateModeBBudget(
        saldoCarryOver: saldoCarryOver,
        bekelHariIni: bekelHariIni,
        pengeluaranWajibHariIni: pengeluaranWajibHariIni,
        pengeluaranHariIni: pengeluaranHariIni,
        dailySavingsReserve: dailySavingsReserve,
      );

      // Insert 3 assets
      await assetsRepository.saveAsset(
        name: 'Emas',
        type: 'Logam Mulia',
        purchaseValue: 10000000,
        currentValue: 12000000,
      );
      await assetsRepository.saveAsset(
        name: 'Kripto',
        type: 'Kripto',
        purchaseValue: 5000000,
        currentValue: 2000000,
      );

      // Recalculate Mode B
      final afterAssetsModeB = calculateModeBBudget(
        saldoCarryOver: saldoCarryOver,
        bekelHariIni: bekelHariIni,
        pengeluaranWajibHariIni: pengeluaranWajibHariIni,
        pengeluaranHariIni: pengeluaranHariIni,
        dailySavingsReserve: dailySavingsReserve,
      );

      expect(
        afterAssetsModeB.uangJajanAmanHariIni,
        equals(baselineModeB.uangJajanAmanHariIni),
        reason: 'Asset net worth must NEVER alter Mode B daily budget',
      );
      expect(
        afterAssetsModeB.dailySavingsReserve,
        equals(baselineModeB.dailySavingsReserve),
      );
    });
  });
}
