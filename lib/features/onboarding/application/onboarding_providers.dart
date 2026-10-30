// Riverpod providers for the M2 Onboarding feature.
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../settings/application/settings_providers.dart';
import '../data/onboarding_repository.dart';
import 'onboarding_wizard_state.dart';

final onboardingRepositoryProvider = Provider<OnboardingRepositoryBase>((ref) {
  return OnboardingRepository(ref.watch(isarProvider));
});

/// Reactive singleton [LocalProfile] row — `null` until onboarding has
/// ever been completed once. `app.dart` watches this (via
/// [onboardingCompleteProvider]) to decide Onboarding vs. Home routing.
final localProfileStreamProvider = StreamProvider<LocalProfile?>((ref) {
  return ref.watch(onboardingRepositoryProvider).watchProfile();
});

/// `true` once onboarding is complete, `false` while incomplete/pending,
/// surfaced as the loading/error states a `StreamProvider` naturally
/// exposes (antislop R-27 — this app must show loading/error, not just
/// the happy path, even at boot).
final onboardingCompleteProvider = Provider<AsyncValue<bool>>((ref) {
  final profileAsync = ref.watch(localProfileStreamProvider);
  return profileAsync.whenData(
    (profile) => profile?.onboardingComplete ?? false,
  );
});

class OnboardingWizardNotifier extends Notifier<OnboardingWizardState> {
  @override
  OnboardingWizardState build() => const OnboardingWizardState();

  void selectFrequency(IncomeFrequency frequency) {
    if (frequency == state.incomeFrequency) return;
    state = state.copyWith(
      incomeFrequency: frequency,
      clearIncomeIntervalType: true,
      clearNextPaydayDate: true,
    );
  }

  void selectIntervalType(IncomeIntervalType type) {
    state = state.copyWith(incomeIntervalType: type);
  }

  void setNextPaydayDate(DateTime date) {
    state = state.copyWith(nextPaydayDate: date);
  }

  void setWalletName(String name) {
    state = state.copyWith(walletName: name, clearSubmitError: true);
  }

  void setWalletIcon(String icon) {
    state = state.copyWith(walletIcon: icon, clearSubmitError: true);
  }

  void setWalletStartingBalance(int balance) {
    state = state.copyWith(
      walletStartingBalance: balance,
      clearSubmitError: true,
    );
  }

  void setWalletIncludeInDailyBudget(bool include) {
    state = state.copyWith(walletIncludeInDailyBudget: include);
  }

  void setInitialIncomeAmount(int? amount) {
    state = state.copyWith(initialIncomeAmount: amount);
  }

  void addExpense(MandatoryExpenseItem item) {
    state = state.copyWith(expenses: [...state.expenses, item]);
  }

  void removeExpenseAt(int index) {
    final updated = [...state.expenses]..removeAt(index);
    state = state.copyWith(expenses: updated);
  }

  void goToStep(OnboardingStep step) {
    state = state.copyWith(step: step, clearSubmitError: true);
  }

  void goNext() {
    switch (state.step) {
      case OnboardingStep.incomeFrequency:
        if (state.canLeaveFrequencyStep) {
          goToStep(OnboardingStep.walletSetup);
        }
      case OnboardingStep.walletSetup:
        if (state.canLeaveWalletStep) {
          goToStep(OnboardingStep.initialIncome);
        }
      case OnboardingStep.initialIncome:
        if (state.canLeaveIncomeStep) {
          goToStep(OnboardingStep.mandatoryExpenses);
        }
      case OnboardingStep.mandatoryExpenses:
        break;
    }
  }

  void goBack() {
    switch (state.step) {
      case OnboardingStep.incomeFrequency:
        break;
      case OnboardingStep.walletSetup:
        goToStep(OnboardingStep.incomeFrequency);
      case OnboardingStep.initialIncome:
        goToStep(OnboardingStep.walletSetup);
      case OnboardingStep.mandatoryExpenses:
        goToStep(OnboardingStep.initialIncome);
    }
  }

  /// Persists the wizard result via [OnboardingRepository]. Returns `true`
  /// on success; on failure leaves `submitError` set for the UI to show.
  Future<bool> submit() async {
    final frequency = state.incomeFrequency;
    final amount = state.initialIncomeAmount;
    if (frequency == null || amount == null) {
      state = state.copyWith(
        submitError: 'Data belum lengkap — kembali ke langkah sebelumnya.',
      );
      return false;
    }

    state = state.copyWith(isSubmitting: true, clearSubmitError: true);
    try {
      await ref
          .read(onboardingRepositoryProvider)
          .completeOnboarding(
            incomeFrequency: frequency,
            incomeIntervalType: state.incomeIntervalType,
            nextPaydayDate: state.nextPaydayDate,
            initialIncomeAmount: amount,
            mandatoryExpenses: state.expenses,
            walletName: state.walletName,
            walletIcon: state.walletIcon,
            walletStartingBalance: state.walletStartingBalance,
            walletIncludeInDailyBudget: state.walletIncludeInDailyBudget,
          );
      // D18/M17 bug #2: onboarding completion is the first guaranteed
      // moment a fresh install has a persisted LocalProfile to read
      // defaults from — bootstrap the (default-enabled) notifications here
      // so a new install's reminders actually fire without the user ever
      // having to visit Settings. Best-effort: a notification-scheduling
      // failure must never block onboarding from completing.
      try {
        await ref
            .read(settingsRepositoryProvider)
            .bootstrapDefaultNotificationsIfNeeded();
      } catch (_) {
        // Notification setup is a nicety, not a blocker for onboarding.
      }
      state = state.copyWith(isSubmitting: false);
      return true;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, submitError: e.toString());
      return false;
    }
  }
}

final onboardingWizardProvider =
    NotifierProvider<OnboardingWizardNotifier, OnboardingWizardState>(
      OnboardingWizardNotifier.new,
    );
