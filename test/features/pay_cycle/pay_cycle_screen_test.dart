// Widget tests for PayCycleTransitionScreen (FR-05, BR-02).
// Tests Mode A, Mode B, light and dark themes, validation, and user interaction (antislop R-26, R-21, R-34).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/core/theme/app_theme.dart';
import 'package:ledgermate/features/budget_engine/application/budget_providers.dart';
import 'package:ledgermate/features/pay_cycle/application/pay_cycle_providers.dart';
import 'package:ledgermate/features/pay_cycle/presentation/pay_cycle_transition_screen.dart';

import 'fake_pay_cycle_repository.dart';

void main() {
  late FakePayCycleRepository fakeRepository;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    fakeRepository = FakePayCycleRepository();
  });

  tearDown(() {
    fakeRepository.dispose();
  });

  Widget createWidget({
    required LocalProfile profile,
    PayCycle? cycle,
    List<db.Transaction> transactions = const [],
    ThemeMode themeMode = ThemeMode.dark,
    DateTime? referenceNow,
  }) {
    return ProviderScope(
      overrides: [
        payCycleRepositoryProvider.overrideWithValue(fakeRepository),
        budgetProfileStreamProvider.overrideWith(
          (ref) => Stream.value(profile),
        ),
        budgetLatestPayCycleStreamProvider.overrideWith(
          (ref) => Stream.value(cycle),
        ),
        budgetTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value(transactions),
        ),
        budgetGoalsStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PayCycleTransitionScreen(referenceNow: referenceNow),
      ),
    );
  }

  testWidgets(
    'Mode A: renders salary input, chip choices, and mandatory expense interactions',
    (tester) async {
      final profile = LocalProfile()
        ..fixedSalary = 5000000
        ..nextPaydayDate = DateTime(2026, 10, 25)
        ..incomeFrequency = IncomeFrequency.periodic
        ..incomeIntervalType = IncomeIntervalType.monthly
        ..onboardingComplete = true;

      await tester.pumpWidget(
        createWidget(profile: profile, referenceNow: DateTime(2026, 10, 25)),
      );
      await tester.pumpAndSettle();

      // Header check
      expect(find.text('Siklus Gajian Baru'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('transition_salary_field')),
        findsOneWidget,
      );

      // Submit button disabled initially because salary is empty
      final submitButtonFinder = find.byKey(
        const ValueKey('transition_submit_button'),
      );
      expect(tester.widget<FilledButton>(submitButtonFinder).onPressed, isNull);

      // Enter salary
      await tester.enterText(
        find.byKey(const ValueKey('transition_salary_field')),
        '6000000',
      );
      await tester.pumpAndSettle();

      // Now submit button is enabled
      expect(
        tester.widget<FilledButton>(submitButtonFinder).onPressed,
        isNotNull,
      );

      // Add mandatory expense
      await tester.ensureVisible(
        find.byKey(const ValueKey('transition_expense_name_field')),
      );
      await tester.enterText(
        find.byKey(const ValueKey('transition_expense_name_field')),
        'Sewa Kos',
      );
      await tester.enterText(
        find.byKey(const ValueKey('transition_expense_amount_field')),
        '1500000',
      );
      final addExpenseButton = find.byKey(
        const ValueKey('transition_add_expense_button'),
      );
      await tester.ensureVisible(addExpenseButton);
      await tester.tap(addExpenseButton);
      await tester.pumpAndSettle();

      expect(find.text('Sewa Kos'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('transition_expense_row_0')),
        findsOneWidget,
      );

      // Submit
      await tester.ensureVisible(submitButtonFinder);
      await tester.tap(submitButtonFinder);
      await tester.pumpAndSettle();

      expect(fakeRepository.modeATransitionCount, 1);
    },
  );

  testWidgets('Mode B: renders carry-over card and submits daily rollover', (
    tester,
  ) async {
    final profile = LocalProfile()
      ..incomeFrequency = IncomeFrequency.daily
      ..carryOverBalance = 85000
      ..lastRolloverDate = DateTime(2026, 10, 27)
      ..onboardingComplete = true;

    await tester.pumpWidget(
      createWidget(profile: profile, referenceNow: DateTime(2026, 10, 28)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Rollover Harian'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('transition_carry_over_display')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('transition_bekel_field')),
      findsOneWidget,
    );

    // Mode B is submittable immediately
    final submitButtonFinder = find.byKey(
      const ValueKey('transition_submit_button'),
    );
    expect(
      tester.widget<FilledButton>(submitButtonFinder).onPressed,
      isNotNull,
    );

    // Enter today bekel
    await tester.enterText(
      find.byKey(const ValueKey('transition_bekel_field')),
      '50000',
    );
    await tester.pumpAndSettle();

    await tester.ensureVisible(submitButtonFinder);
    await tester.tap(submitButtonFinder);
    await tester.pumpAndSettle();

    expect(fakeRepository.modeBTransitionCount, 1);
  });

  testWidgets(
    'Light and Dark themes render without error (antislop R-21, R-34)',
    (tester) async {
      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.periodic
        ..fixedSalary = 4000000
        ..nextPaydayDate = DateTime(2026, 10, 25)
        ..onboardingComplete = true;

      // Dark theme
      await tester.pumpWidget(
        createWidget(profile: profile, themeMode: ThemeMode.dark),
      );
      await tester.pumpAndSettle();
      expect(find.text('Siklus Gajian Baru'), findsOneWidget);

      // Light theme
      await tester.pumpWidget(
        createWidget(profile: profile, themeMode: ThemeMode.light),
      );
      await tester.pumpAndSettle();
      expect(find.text('Siklus Gajian Baru'), findsOneWidget);
    },
  );
}
