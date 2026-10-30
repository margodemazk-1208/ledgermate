import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/app_localizations.dart';
import '../application/onboarding_providers.dart';
import '../application/onboarding_wizard_state.dart';
import 'widgets/income_frequency_step.dart';
import 'widgets/initial_income_step.dart';
import 'widgets/mandatory_expenses_step.dart';
import 'widgets/wallet_setup_step.dart';

/// Hosts the 3-step Onboarding Wizard (FR-01). Gates entry to Home —
/// `app.dart` only shows this screen while
/// `LocalProfile.onboardingComplete` is false/absent.
class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingWizardProvider);
    final notifier = ref.read(onboardingWizardProvider.notifier);

    ref.listen(onboardingWizardProvider, (previous, next) {
      if (next.submitError != null &&
          next.submitError != previous?.submitError) {
        final message = next.submitError == incompleteOnboardingDataErrorCode
            ? AppLocalizations.of(context)!.onboardingScreenIncompleteDataError
            : next.submitError!;
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(message)));
      }
    });

    return PopScope(
      // M19/D18: system back (gesture/button) on a non-first step must step
      // the wizard backward, not exit the app — OnboardingScreen has no
      // previous route to pop to since it gates app entry, so without this
      // the system back action silently closes the whole app.
      canPop: state.step == OnboardingStep.incomeFrequency,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (!state.isSubmitting) notifier.goBack();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: KeyedSubtree(
                    key: ValueKey(state.step),
                    child: switch (state.step) {
                      OnboardingStep.incomeFrequency =>
                        const IncomeFrequencyStep(),
                      OnboardingStep.walletSetup => const WalletSetupStep(),
                      OnboardingStep.initialIncome => const InitialIncomeStep(),
                      OnboardingStep.mandatoryExpenses =>
                        const MandatoryExpensesStep(),
                    },
                  ),
                ),
              ),
              _WizardNavBar(state: state, notifier: notifier),
            ],
          ),
        ),
      ),
    );
  }
}

class _WizardNavBar extends StatelessWidget {
  const _WizardNavBar({required this.state, required this.notifier});

  final OnboardingWizardState state;
  final OnboardingWizardNotifier notifier;

  bool get _canGoNext => switch (state.step) {
    OnboardingStep.incomeFrequency => state.canLeaveFrequencyStep,
    OnboardingStep.walletSetup => state.canLeaveWalletStep,
    OnboardingStep.initialIncome => state.canLeaveIncomeStep,
    OnboardingStep.mandatoryExpenses => state.canFinish,
  };

  bool get _isLastStep => state.step == OnboardingStep.mandatoryExpenses;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.onSurface
                .withValues(alpha: 0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          if (state.step != OnboardingStep.incomeFrequency)
            TextButton(
              key: const ValueKey('onboarding_back_button'),
              onPressed: state.isSubmitting ? null : notifier.goBack,
              child: Text(
                AppLocalizations.of(context)!.onboardingScreenBackButton,
              ),
            )
          else
            const SizedBox.shrink(),
          const Spacer(),
          FilledButton(
            key: const ValueKey('onboarding_next_button'),
            onPressed: !_canGoNext || state.isSubmitting
                ? null
                : () {
                    if (_isLastStep) {
                      notifier.submit();
                    } else {
                      notifier.goNext();
                    }
                  },
            child: state.isSubmitting
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    _isLastStep
                        ? AppLocalizations.of(context)!
                              .onboardingScreenFinishButton
                        : AppLocalizations.of(context)!
                              .onboardingScreenNextButton,
                  ),
          ),
        ],
      ),
    );
  }
}
