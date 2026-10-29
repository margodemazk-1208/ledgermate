// Unit tests for OnboardingWizardNotifier's validation-gating + step
// navigation logic (plain `test()` + `ProviderContainer`, no widgets
// involved) — the business rules behind FR-01's "every interactive
// element must actually validate before advancing" requirement.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/features/onboarding/application/onboarding_providers.dart';
import 'package:ledgermate/features/onboarding/application/onboarding_wizard_state.dart';

import 'fake_onboarding_repository.dart';

void main() {
  late FakeOnboardingRepository fakeRepository;
  late ProviderContainer container;

  setUp(() {
    fakeRepository = FakeOnboardingRepository();
    container = ProviderContainer(
      overrides: [
        onboardingRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
  });

  tearDown(() {
    container.dispose();
    fakeRepository.dispose();
  });

  test('goNext is a no-op on step 0 until a mode is picked', () {
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.incomeFrequency,
    );
  });

  test('Mode A requires interval + payday date before advancing', () {
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.selectFrequency(IncomeFrequency.periodic);
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.incomeFrequency,
      reason: 'missing interval type + date should block advancing',
    );

    notifier.selectIntervalType(IncomeIntervalType.weekly);
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.incomeFrequency,
      reason: 'still missing the payday date',
    );

    notifier.setNextPaydayDate(DateTime(2026, 12, 25));
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.walletSetup,
    );
  });

  test('Mode B skips straight past the interval/date requirement', () {
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.selectFrequency(IncomeFrequency.daily);
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.walletSetup,
    );
  });

  test('walletSetup step validation and fields', () {
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.selectFrequency(IncomeFrequency.daily);
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.walletSetup,
    );
    expect(container.read(onboardingWizardProvider).canLeaveWalletStep, isTrue);

    notifier.setWalletName('   ');
    expect(
      container.read(onboardingWizardProvider).canLeaveWalletStep,
      isFalse,
    );
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.walletSetup,
    );

    notifier.setWalletName('Dompet Pribadi');
    notifier.setWalletStartingBalance(500000);
    notifier.setWalletIncludeInDailyBudget(false);
    expect(container.read(onboardingWizardProvider).canLeaveWalletStep, isTrue);
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.initialIncome,
    );
  });

  test('switching mode clears the other mode\'s interval/date fields', () {
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.selectFrequency(IncomeFrequency.periodic);
    notifier.selectIntervalType(IncomeIntervalType.monthly);
    notifier.setNextPaydayDate(DateTime(2026, 12, 25));

    notifier.selectFrequency(IncomeFrequency.daily);
    final state = container.read(onboardingWizardProvider);
    expect(state.incomeIntervalType, isNull);
    expect(state.nextPaydayDate, isNull);
  });

  test('initial income amount of 0 does not satisfy canLeaveIncomeStep', () {
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.selectFrequency(IncomeFrequency.daily);
    notifier.goNext();
    notifier.goNext();
    notifier.setInitialIncomeAmount(0);
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.initialIncome,
    );

    notifier.setInitialIncomeAmount(1000);
    notifier.goNext();
    expect(
      container.read(onboardingWizardProvider).step,
      OnboardingStep.mandatoryExpenses,
    );
  });

  test('addExpense/removeExpenseAt mutate the list immutably', () {
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.addExpense(
      MandatoryExpenseItem()
        ..name = 'Kos'
        ..amount = 800000,
    );
    notifier.addExpense(
      MandatoryExpenseItem()
        ..name = 'Pulsa'
        ..amount = 50000,
    );
    expect(container.read(onboardingWizardProvider).expenses, hasLength(2));

    notifier.removeExpenseAt(0);
    final remaining = container.read(onboardingWizardProvider).expenses;
    expect(remaining, hasLength(1));
    expect(remaining.single.name, 'Pulsa');
  });

  test('submit() forwards the full wizard state to the repository', () async {
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.selectFrequency(IncomeFrequency.daily);
    notifier.setInitialIncomeAmount(25000);
    notifier.addExpense(
      MandatoryExpenseItem()
        ..name = 'Ongkos'
        ..amount = 10000,
    );

    final result = await notifier.submit();

    expect(result, isTrue);
    expect(fakeRepository.completedCalls, hasLength(1));
    final call = fakeRepository.completedCalls.single;
    expect(call.incomeFrequency, IncomeFrequency.daily);
    expect(call.initialIncomeAmount, 25000);
    expect(call.mandatoryExpenses.single.name, 'Ongkos');
    expect(container.read(onboardingWizardProvider).isSubmitting, isFalse);
  });

  test('submit() surfaces repository failures via submitError', () async {
    fakeRepository.failWith = Exception('disk full');
    final notifier = container.read(onboardingWizardProvider.notifier);
    notifier.selectFrequency(IncomeFrequency.daily);
    notifier.setInitialIncomeAmount(25000);

    final result = await notifier.submit();

    expect(result, isFalse);
    expect(
      container.read(onboardingWizardProvider).submitError,
      contains('disk full'),
    );
  });
}
