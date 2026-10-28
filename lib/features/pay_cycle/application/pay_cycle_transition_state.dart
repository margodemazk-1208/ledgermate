// State class for Pay Cycle transition flow (FR-05, BR-02).
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';

class PayCycleTransitionState {
  const PayCycleTransitionState({
    required this.incomeFrequency,
    this.nextPaydayDate,
    this.incomeIntervalType,
    this.fixedSalary,
    this.mandatoryExpenses = const [],
    this.yesterdayCarryOver = 0,
    this.todayBekelIncome,
    this.todayMandatoryExpenses = const [],
    this.isSubmitting = false,
    this.submitError,
    this.isSuccess = false,
  });

  final IncomeFrequency incomeFrequency;

  // Mode A fields
  final DateTime? nextPaydayDate;
  final IncomeIntervalType? incomeIntervalType;
  final int? fixedSalary;
  final List<MandatoryExpenseItem> mandatoryExpenses;

  // Mode B fields
  final int yesterdayCarryOver;
  final int? todayBekelIncome;
  final List<MandatoryExpenseItem> todayMandatoryExpenses;

  final bool isSubmitting;
  final String? submitError;
  final bool isSuccess;

  bool get isPeriodic => incomeFrequency == IncomeFrequency.periodic;

  /// Mode A validation: next payday date and fixed salary (> 0) are required
  bool get canSubmitModeA =>
      nextPaydayDate != null && fixedSalary != null && fixedSalary! > 0;

  /// Mode B validation: always submittable since carry-over is pre-calculated,
  /// bekel is optional, and mandatory expenses is optional
  bool get canSubmitModeB => true;

  bool get canSubmit => isPeriodic ? canSubmitModeA : canSubmitModeB;

  PayCycleTransitionState copyWith({
    IncomeFrequency? incomeFrequency,
    DateTime? nextPaydayDate,
    bool clearNextPaydayDate = false,
    IncomeIntervalType? incomeIntervalType,
    int? fixedSalary,
    bool clearFixedSalary = false,
    List<MandatoryExpenseItem>? mandatoryExpenses,
    int? yesterdayCarryOver,
    int? todayBekelIncome,
    bool clearTodayBekelIncome = false,
    List<MandatoryExpenseItem>? todayMandatoryExpenses,
    bool? isSubmitting,
    String? submitError,
    bool clearSubmitError = false,
    bool? isSuccess,
  }) {
    return PayCycleTransitionState(
      incomeFrequency: incomeFrequency ?? this.incomeFrequency,
      nextPaydayDate: clearNextPaydayDate
          ? null
          : (nextPaydayDate ?? this.nextPaydayDate),
      incomeIntervalType: incomeIntervalType ?? this.incomeIntervalType,
      fixedSalary: clearFixedSalary ? null : (fixedSalary ?? this.fixedSalary),
      mandatoryExpenses: mandatoryExpenses ?? this.mandatoryExpenses,
      yesterdayCarryOver: yesterdayCarryOver ?? this.yesterdayCarryOver,
      todayBekelIncome: clearTodayBekelIncome
          ? null
          : (todayBekelIncome ?? this.todayBekelIncome),
      todayMandatoryExpenses:
          todayMandatoryExpenses ?? this.todayMandatoryExpenses,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}
