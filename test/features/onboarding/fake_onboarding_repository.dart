// Test double for OnboardingRepositoryBase — lets UI-flow widget tests
// exercise the full wizard (including the Finish/submit button) without
// touching real Isar, which hangs under `testWidgets()` (see
// `onboarding_repository.dart`'s doc comment on
// `OnboardingRepositoryBase` for the full explanation).
import 'dart:async';

import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/features/onboarding/data/onboarding_repository.dart';

class RecordedCompleteOnboardingCall {
  RecordedCompleteOnboardingCall({
    required this.incomeFrequency,
    required this.incomeIntervalType,
    required this.nextPaydayDate,
    required this.initialIncomeAmount,
    required this.mandatoryExpenses,
  });

  final IncomeFrequency incomeFrequency;
  final IncomeIntervalType? incomeIntervalType;
  final DateTime? nextPaydayDate;
  final int initialIncomeAmount;
  final List<MandatoryExpenseItem> mandatoryExpenses;
}

class FakeOnboardingRepository implements OnboardingRepositoryBase {
  final List<RecordedCompleteOnboardingCall> completedCalls = [];
  final _controller = StreamController<LocalProfile?>.broadcast();

  /// Set to throw from the next [completeOnboarding] call, to exercise
  /// the wizard's error-handling path.
  Object? failWith;

  @override
  Stream<LocalProfile?> watchProfile() => _controller.stream;

  @override
  Future<void> completeOnboarding({
    required IncomeFrequency incomeFrequency,
    IncomeIntervalType? incomeIntervalType,
    DateTime? nextPaydayDate,
    required int initialIncomeAmount,
    required List<MandatoryExpenseItem> mandatoryExpenses,
  }) async {
    if (failWith != null) {
      final error = failWith!;
      failWith = null;
      throw error;
    }
    completedCalls.add(
      RecordedCompleteOnboardingCall(
        incomeFrequency: incomeFrequency,
        incomeIntervalType: incomeIntervalType,
        nextPaydayDate: nextPaydayDate,
        initialIncomeAmount: initialIncomeAmount,
        mandatoryExpenses: mandatoryExpenses,
      ),
    );
  }

  void dispose() => _controller.close();
}
