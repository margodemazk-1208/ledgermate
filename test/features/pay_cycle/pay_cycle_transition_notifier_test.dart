// Unit tests for PayCycleTransitionNotifier (M5).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/budget_engine/application/budget_providers.dart';
import 'package:ledgermate/features/pay_cycle/application/pay_cycle_providers.dart';
import 'package:ledgermate/features/wallets/application/wallet_providers.dart';

import 'fake_pay_cycle_repository.dart';

void main() {
  late ProviderContainer container;
  late FakePayCycleRepository fakeRepository;

  setUp(() {
    fakeRepository = FakePayCycleRepository();
    container = ProviderContainer(
      overrides: [payCycleRepositoryProvider.overrideWithValue(fakeRepository)],
    );
  });

  tearDown(() {
    container.dispose();
    fakeRepository.dispose();
  });

  test('Mode A validation: requires nextPaydayDate and fixedSalary > 0', () {
    final notifier = container.read(
      payCycleTransitionNotifierProvider.notifier,
    );

    notifier.initialize(
      frequency: IncomeFrequency.periodic,
      initialNextPaydayDate: null,
    );

    var state = container.read(payCycleTransitionNotifierProvider);
    expect(state.canSubmit, isFalse);

    notifier.setNextPaydayDate(DateTime(2026, 11, 25));
    state = container.read(payCycleTransitionNotifierProvider);
    expect(state.canSubmit, isFalse); // still no salary

    notifier.setFixedSalary(0);
    state = container.read(payCycleTransitionNotifierProvider);
    expect(state.canSubmit, isFalse); // salary <= 0

    notifier.setFixedSalary(5000000);
    state = container.read(payCycleTransitionNotifierProvider);
    expect(state.canSubmit, isTrue);
  });

  test('Mode A mandatory expenses add and remove mutation', () {
    final notifier = container.read(
      payCycleTransitionNotifierProvider.notifier,
    );

    notifier.initialize(frequency: IncomeFrequency.periodic);
    final item1 = MandatoryExpenseItem()
      ..name = 'Kos'
      ..amount = 1000000;
    final item2 = MandatoryExpenseItem()
      ..name = 'Listrik'
      ..amount = 200000;

    notifier.addMandatoryExpense(item1);
    notifier.addMandatoryExpense(item2);

    var state = container.read(payCycleTransitionNotifierProvider);
    expect(state.mandatoryExpenses.length, 2);
    expect(state.mandatoryExpenses[0].name, 'Kos');

    notifier.removeMandatoryExpenseAt(0);
    state = container.read(payCycleTransitionNotifierProvider);
    expect(state.mandatoryExpenses.length, 1);
    expect(state.mandatoryExpenses[0].name, 'Listrik');
  });

  test('Mode B submit succeeds and forwards state to repository', () async {
    final notifier = container.read(
      payCycleTransitionNotifierProvider.notifier,
    );

    notifier.initialize(
      frequency: IncomeFrequency.daily,
      yesterdayCarryOver: 75000,
    );
    notifier.setTodayBekel(30000);

    final expense = MandatoryExpenseItem()
      ..name = 'Parkir'
      ..amount = 5000;
    notifier.addTodayMandatoryExpense(expense);

    final success = await notifier.submitTransition();
    expect(success, isTrue);
    expect(fakeRepository.modeBTransitionCount, 1);

    final state = container.read(payCycleTransitionNotifierProvider);
    expect(state.isSuccess, isTrue);
    expect(state.submitError, isNull);
  });

  test('Submit surfaces error on repository failure', () async {
    fakeRepository.failWith = Exception('Database write failed');

    final notifier = container.read(
      payCycleTransitionNotifierProvider.notifier,
    );
    notifier.initialize(
      frequency: IncomeFrequency.periodic,
      initialNextPaydayDate: DateTime(2026, 11, 25),
    );
    notifier.setFixedSalary(5000000);

    final success = await notifier.submitTransition();
    expect(success, isFalse);

    final state = container.read(payCycleTransitionNotifierProvider);
    expect(state.isSuccess, isFalse);
    expect(state.submitError, contains('Database write failed'));
  });

  // D18/M17 bug #5b regression: tapping "Mulai Siklus Baru"/"Mulai Hari Ini"
  // twice before the first submission completed could record the rollover
  // TWICE. `submitTransition()` now guards on `state.isSubmitting`
  // synchronously as its first line.
  test('double-submitting Mode A transition before the first call resolves '
      'only records the transition once', () async {
    final notifier = container.read(
      payCycleTransitionNotifierProvider.notifier,
    );
    notifier.initialize(
      frequency: IncomeFrequency.periodic,
      initialNextPaydayDate: DateTime(2026, 11, 25),
    );
    notifier.setFixedSalary(5000000);

    final first = notifier.submitTransition();
    final second = notifier.submitTransition();

    final results = await Future.wait([first, second]);

    expect(fakeRepository.modeATransitionCount, 1);
    expect(results.where((r) => r).length, 1);
  });

  test('double-submitting Mode B rollover before the first call resolves '
      'only records the rollover once', () async {
    final notifier = container.read(
      payCycleTransitionNotifierProvider.notifier,
    );
    notifier.initialize(
      frequency: IncomeFrequency.daily,
      yesterdayCarryOver: 75000,
    );

    final first = notifier.submitTransition();
    final second = notifier.submitTransition();

    final results = await Future.wait([first, second]);

    expect(fakeRepository.modeBTransitionCount, 1);
    expect(results.where((r) => r).length, 1);
  });

  // D18/M17 bug #5a regression: `build()` previously used `ref.watch(...)`
  // on profile/transactions/goals/wallets streams, so ANY unrelated
  // emission from those streams (e.g. the user editing a category on a
  // different screen while this form sits open) re-ran `build()` and wiped
  // whatever the user had already entered back to the auto-computed
  // defaults. `build()` now uses `ref.read(...)` — only seeding ONCE.
  test('an unrelated profile-stream emission does not reset a user-entered '
      'next payday date mid-form', () async {
    final profileController = StreamController<LocalProfile?>.broadcast();
    addTearDown(profileController.close);

    final isolatedContainer = ProviderContainer(
      overrides: [
        budgetProfileStreamProvider.overrideWith(
          (ref) => profileController.stream,
        ),
        budgetTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value(<db.Transaction>[]),
        ),
        budgetGoalsStreamProvider.overrideWith(
          (ref) => Stream.value(<FinancialGoal>[]),
        ),
        walletsStreamProvider.overrideWith((ref) => Stream.value(<Wallet>[])),
        payCycleRepositoryProvider.overrideWithValue(FakePayCycleRepository()),
      ],
    );
    addTearDown(isolatedContainer.dispose);

    // Subscribe eagerly so the broadcast stream's events aren't dropped
    // before the notifier itself first reads it.
    isolatedContainer.listen(budgetProfileStreamProvider, (_, _) {});

    final profileA = LocalProfile()
      ..incomeFrequency = IncomeFrequency.periodic
      ..incomeIntervalType = IncomeIntervalType.monthly;
    profileController.add(profileA);
    await Future<void>.delayed(Duration.zero);

    // First build seeds the form; the user then picks a custom payday
    // date different from whatever `build()` auto-computed.
    isolatedContainer.read(payCycleTransitionNotifierProvider.notifier);
    final userPickedDate = DateTime(2027, 1, 1);
    isolatedContainer
        .read(payCycleTransitionNotifierProvider.notifier)
        .setNextPaydayDate(userPickedDate);
    expect(
      isolatedContainer.read(payCycleTransitionNotifierProvider).nextPaydayDate,
      userPickedDate,
    );

    // An unrelated profile update elsewhere in the app emits a new
    // profile value through the SAME stream this notifier's build()
    // reads from. Pre-fix (`ref.watch`), this re-ran `build()` and
    // wiped the user's chosen date back to the auto-computed default.
    final profileB = LocalProfile()
      ..incomeFrequency = IncomeFrequency.periodic
      ..incomeIntervalType = IncomeIntervalType.monthly;
    profileController.add(profileB);
    await Future<void>.delayed(Duration.zero);

    final stateAfter = isolatedContainer.read(
      payCycleTransitionNotifierProvider,
    );
    expect(
      stateAfter.nextPaydayDate,
      userPickedDate,
      reason:
          'D18/M17 bug #5a: an unrelated profile stream emission must '
          'not reset the in-progress transition form',
    );
  });
}
