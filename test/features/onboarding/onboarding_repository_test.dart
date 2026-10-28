// Real-Isar persistence tests for OnboardingRepository.completeOnboarding
// (M2). Deliberately plain `test()`, not `testWidgets()` — Isar's async
// native calls hang indefinitely under `AutomatedTestWidgetsFlutterBinding`
// (confirmed by direct repro: open/write/watch all stall there), exactly
// like M1's own `isar_collections_test.dart`/`isar_provider_test.dart`
// already do for the same reason.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:ledgermate/core/database/isar_provider.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/features/onboarding/data/onboarding_repository.dart';

void main() {
  late Directory tempDir;
  late Isar isar;
  late OnboardingRepository repository;
  var instanceCounter = 0;

  setUpAll(() async {
    await Isar.initializeIsarCore(download: true);
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync(
      'ledgermate_onboarding_repo_test_',
    );
    instanceCounter++;
    isar = await openLedgerMateIsar(
      directory: tempDir.path,
      name: 'onboarding_repo_test_$instanceCounter',
    );
    repository = OnboardingRepository(isar);
  });

  tearDown(() async {
    await isar.close(deleteFromDisk: true);
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('watchProfile emits null before any profile exists', () async {
    final first = await repository.watchProfile().first;
    expect(first, isNull);
  });

  test(
    'Mode A (periodic): persists LocalProfile + creates a PayCycle',
    () async {
      final payday = DateTime(2026, 12, 1);
      final expenses = [
        MandatoryExpenseItem()
          ..name = 'Kos'
          ..amount = 800000,
      ];

      await repository.completeOnboarding(
        incomeFrequency: IncomeFrequency.periodic,
        incomeIntervalType: IncomeIntervalType.monthly,
        nextPaydayDate: payday,
        initialIncomeAmount: 5000000,
        mandatoryExpenses: expenses,
      );

      final profile = await isar.localProfiles.where().findFirst();
      expect(profile, isNotNull);
      expect(profile!.onboardingComplete, isTrue);
      expect(profile.incomeFrequency, IncomeFrequency.periodic);
      expect(profile.incomeIntervalType, IncomeIntervalType.monthly);
      expect(profile.nextPaydayDate, payday);
      expect(profile.fixedSalary, 5000000);
      // Mode A's list lives on PayCycle, not LocalProfile.
      expect(profile.mandatoryExpenses, isEmpty);

      final cycles = await isar.payCycles.where().findAll();
      expect(cycles, hasLength(1));
      expect(cycles.first.fixedSalary, 5000000);
      expect(cycles.first.paydayDate, payday);
      expect(cycles.first.mandatoryExpenses, hasLength(1));
      expect(cycles.first.mandatoryExpenses.first.name, 'Kos');
      expect(cycles.first.mandatoryExpenses.first.amount, 800000);

      final watched = await repository.watchProfile().first;
      expect(watched?.onboardingComplete, isTrue);
    },
  );

  test('Mode B (daily): seeds carryOverBalance, no PayCycle created', () async {
    final expenses = [
      MandatoryExpenseItem()
        ..name = 'Ongkos'
        ..amount = 15000,
    ];

    await repository.completeOnboarding(
      incomeFrequency: IncomeFrequency.daily,
      initialIncomeAmount: 50000,
      mandatoryExpenses: expenses,
    );

    final profile = await isar.localProfiles.where().findFirst();
    expect(profile, isNotNull);
    expect(profile!.onboardingComplete, isTrue);
    expect(profile.incomeFrequency, IncomeFrequency.daily);
    expect(profile.carryOverBalance, 50000);
    expect(profile.fixedSalary, 0);
    expect(profile.nextPaydayDate, isNull);
    expect(profile.incomeIntervalType, isNull);
    expect(profile.mandatoryExpenses, hasLength(1));
    expect(profile.mandatoryExpenses.first.name, 'Ongkos');

    final cycles = await isar.payCycles.where().findAll();
    expect(cycles, isEmpty);
  });

  test(
    're-running onboarding updates the singleton, never inserts a second row',
    () async {
      await repository.completeOnboarding(
        incomeFrequency: IncomeFrequency.daily,
        initialIncomeAmount: 10000,
        mandatoryExpenses: const [],
      );
      await repository.completeOnboarding(
        incomeFrequency: IncomeFrequency.daily,
        initialIncomeAmount: 20000,
        mandatoryExpenses: const [],
      );

      final allProfiles = await isar.localProfiles.where().findAll();
      expect(allProfiles, hasLength(1));
      expect(allProfiles.single.carryOverBalance, 20000);
    },
  );
}
