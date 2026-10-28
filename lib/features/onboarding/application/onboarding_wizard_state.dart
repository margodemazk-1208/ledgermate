// Wizard form state for the M2 Onboarding flow (FR-01). Deliberately a
// plain immutable data class (no external codegen package) — the state
// shape is small and stable, and `docs/ARCHITECTURE.md` reserves codegen
// providers for Riverpod, not extra value-type packages.
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';

/// The 3 steps from the task spec: (0) income frequency, (1) initial
/// income amount, (2) mandatory expenses list.
enum OnboardingStep { incomeFrequency, initialIncome, mandatoryExpenses }

class OnboardingWizardState {
  const OnboardingWizardState({
    this.step = OnboardingStep.incomeFrequency,
    this.incomeFrequency,
    this.incomeIntervalType,
    this.nextPaydayDate,
    this.initialIncomeAmount,
    this.expenses = const [],
    this.isSubmitting = false,
    this.submitError,
  });

  final OnboardingStep step;
  final IncomeFrequency? incomeFrequency;
  final IncomeIntervalType? incomeIntervalType;
  final DateTime? nextPaydayDate;
  final int? initialIncomeAmount;
  final List<MandatoryExpenseItem> expenses;
  final bool isSubmitting;
  final String? submitError;

  bool get isPeriodic => incomeFrequency == IncomeFrequency.periodic;

  /// Step 0 (income frequency) is complete enough to advance.
  bool get canLeaveFrequencyStep {
    if (incomeFrequency == null) return false;
    if (incomeFrequency == IncomeFrequency.daily) return true;
    return incomeIntervalType != null && nextPaydayDate != null;
  }

  /// Step 1 (initial income) is complete enough to advance.
  bool get canLeaveIncomeStep =>
      initialIncomeAmount != null && initialIncomeAmount! > 0;

  /// Step 2 (mandatory expenses) is always navigable since the list is
  /// allowed to be empty (not every user has recurring obligations) —
  /// per-row validation happens in the UI before a row is added.
  bool get canFinish => true;

  OnboardingWizardState copyWith({
    OnboardingStep? step,
    IncomeFrequency? incomeFrequency,
    bool clearIncomeFrequency = false,
    IncomeIntervalType? incomeIntervalType,
    bool clearIncomeIntervalType = false,
    DateTime? nextPaydayDate,
    bool clearNextPaydayDate = false,
    int? initialIncomeAmount,
    List<MandatoryExpenseItem>? expenses,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return OnboardingWizardState(
      step: step ?? this.step,
      incomeFrequency: clearIncomeFrequency
          ? null
          : (incomeFrequency ?? this.incomeFrequency),
      incomeIntervalType: clearIncomeIntervalType
          ? null
          : (incomeIntervalType ?? this.incomeIntervalType),
      nextPaydayDate: clearNextPaydayDate
          ? null
          : (nextPaydayDate ?? this.nextPaydayDate),
      initialIncomeAmount: initialIncomeAmount ?? this.initialIncomeAmount,
      expenses: expenses ?? this.expenses,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
