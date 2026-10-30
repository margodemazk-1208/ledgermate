// Confirms the Onboarding Wizard renders cleanly in BOTH themes
// (docs/DESIGN.md + AGENTS.md antislop R-21/R-34 — dark and light must
// both be fully functional, not light-as-an-afterthought). Walks every
// step (including a populated expenses list and the Mode A date field)
// under each theme and asserts no uncaught framework exceptions.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/core/theme/app_theme.dart';
import 'package:ledgermate/features/onboarding/application/onboarding_providers.dart';
import 'package:ledgermate/features/onboarding/presentation/onboarding_screen.dart';

import 'fake_onboarding_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  Future<void> walkWizard(WidgetTester tester, ThemeData theme) async {
    final fakeRepository = FakeOnboardingRepository();
    addTearDown(fakeRepository.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: MaterialApp(
          theme: theme,
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mode_card_periodik')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('interval_chip_weekly')));
    await tester.pumpAndSettle();

    final paydayButtonFinder = find.byKey(
      const ValueKey('next_payday_picker_button'),
    );
    await tester.ensureVisible(paydayButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(paydayButtonFinder);
    await tester.pumpAndSettle();
    // Indonesian Material localizations translate the date picker's OK
    // button to "OKE" — confirms the picker is actually running under the
    // real id locale now that the test MaterialApp pins it explicitly.
    await tester.tap(find.text('OKE'));
    await tester.pumpAndSettle();

    // Step 1 -> Step 2 (wallet setup)
    await tester.tap(find.byKey(const ValueKey('onboarding_next_button')));
    await tester.pumpAndSettle();

    // Step 2 (wallet setup) -> Step 3 (income)
    await tester.tap(find.byKey(const ValueKey('onboarding_next_button')));
    await tester.pumpAndSettle();

    // Step 3: enter income
    await tester.enterText(
      find.byKey(const ValueKey('initial_income_field')),
      '3000000',
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('onboarding_next_button')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('expense_name_field')),
      'Kos',
    );
    await tester.enterText(
      find.byKey(const ValueKey('expense_amount_field')),
      '800000',
    );
    await tester.tap(find.byKey(const ValueKey('add_expense_button')));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  }

  testWidgets('dark theme (default) renders every step without error', (
    tester,
  ) async {
    await walkWizard(tester, AppTheme.dark);
  });

  testWidgets('light theme renders every step without error', (tester) async {
    await walkWizard(tester, AppTheme.light);
  });
}
