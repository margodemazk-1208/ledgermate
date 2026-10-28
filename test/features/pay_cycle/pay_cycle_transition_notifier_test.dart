// Unit tests for PayCycleTransitionNotifier (M5).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/features/pay_cycle/application/pay_cycle_providers.dart';

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
}
