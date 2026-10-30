// Full click-through UI tests for the M2 Onboarding Wizard (FR-01):
// mode selection, interval + payday date, income validation, mandatory
// expenses add/remove, and Next/Back/Finish wiring (antislop R-26 — every
// interactive element must do something real, not sit dead). Uses
// [FakeOnboardingRepository] so these run under plain `testWidgets()`
// without the real-Isar hang described in `onboarding_repository.dart`.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/features/onboarding/application/onboarding_providers.dart';
import 'package:ledgermate/features/onboarding/presentation/onboarding_screen.dart';

import 'fake_onboarding_repository.dart';

void main() {
  late FakeOnboardingRepository fakeRepository;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    fakeRepository = FakeOnboardingRepository();
  });

  tearDown(() {
    fakeRepository.dispose();
  });

  Future<void> pumpScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWithValue(fakeRepository),
        ],
        child: const MaterialApp(
          locale: Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Mode B (Harian): full click-through submits the right data', (
    tester,
  ) async {
    await pumpScreen(tester);

    expect(find.text('Pola Pendapatanmu'), findsOneWidget);
    final nextButtonFinder = find.byKey(
      const ValueKey('onboarding_next_button'),
    );

    // Next starts disabled — no mode picked yet (R-26: disabled, not dead).
    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNull);
    expect(find.byKey(const ValueKey('onboarding_back_button')), findsNothing);

    await tester.tap(find.byKey(const ValueKey('mode_card_harian')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('next_payday_picker_button')),
      findsNothing,
    );
    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNotNull);

    // Step 1 -> Step 2: Wallet Setup
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Atur Dompet Pertamamu'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('onboarding_wallet_name_field')),
      'Dompet Utama',
    );
    await tester.pumpAndSettle();

    // Step 2 -> Step 3: Income
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Bekel Awal Hari Ini'), findsOneWidget);
    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNull);

    // Negative/zero/empty must be rejected (FR-02 validation style).
    await tester.enterText(
      find.byKey(const ValueKey('initial_income_field')),
      '0',
    );
    await tester.pumpAndSettle();
    expect(find.text('Jumlah tidak boleh negatif atau nol'), findsOneWidget);
    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNull);

    await tester.enterText(
      find.byKey(const ValueKey('initial_income_field')),
      '50000',
    );
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNotNull);

    await tester.tap(find.byKey(const ValueKey('onboarding_back_button')));
    await tester.pumpAndSettle();
    expect(find.text('Atur Dompet Pertamamu'), findsOneWidget);
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    // Step (c): add + remove + add again, to prove both controls work.
    expect(
      find.text('Belum ada pengeluaran wajib ditambahkan.'),
      findsOneWidget,
    );
    await tester.tap(find.byKey(const ValueKey('add_expense_button')));
    await tester.pumpAndSettle();
    expect(find.text('Nama tidak boleh kosong'), findsOneWidget);

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
    expect(find.text('Kos'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('expense_name_field')),
      'Pulsa',
    );
    await tester.enterText(
      find.byKey(const ValueKey('expense_amount_field')),
      '50000',
    );
    await tester.tap(find.byKey(const ValueKey('add_expense_button')));
    await tester.pumpAndSettle();
    expect(find.text('Pulsa'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('remove_expense_0')));
    await tester.pumpAndSettle();
    expect(find.text('Kos'), findsNothing);
    expect(find.text('Pulsa'), findsOneWidget);

    expect(find.text('Selesai'), findsOneWidget);
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    expect(fakeRepository.completedCalls, hasLength(1));
    final call = fakeRepository.completedCalls.single;
    expect(call.incomeFrequency, IncomeFrequency.daily);
    expect(call.initialIncomeAmount, 50000);
    expect(call.mandatoryExpenses, hasLength(1));
    expect(call.mandatoryExpenses.single.name, 'Pulsa');
    expect(call.mandatoryExpenses.single.amount, 50000);
    expect(call.nextPaydayDate, isNull);
    expect(call.incomeIntervalType, isNull);
  });

  testWidgets('Mode A (Periodik): interval + payday date are required', (
    tester,
  ) async {
    await pumpScreen(tester);

    final nextButtonFinder = find.byKey(
      const ValueKey('onboarding_next_button'),
    );

    await tester.tap(find.byKey(const ValueKey('mode_card_periodik')));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('next_payday_picker_button')),
      findsOneWidget,
    );
    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNull);

    await tester.tap(find.byKey(const ValueKey('interval_chip_biweekly')));
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNull);

    final paydayButtonFinder = find.byKey(
      const ValueKey('next_payday_picker_button'),
    );
    await tester.ensureVisible(paydayButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(paydayButtonFinder);
    await tester.pumpAndSettle();
    // Indonesian Material localizations translate the date picker's OK
    // button to "OKE".
    await tester.tap(find.text('OKE'));
    await tester.pumpAndSettle();

    expect(tester.widget<FilledButton>(nextButtonFinder).onPressed, isNotNull);
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Atur Dompet Pertamamu'), findsOneWidget);
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    expect(find.text('Gaji Siklus Ini'), findsOneWidget);
    await tester.enterText(
      find.byKey(const ValueKey('initial_income_field')),
      '5000000',
    );
    await tester.pumpAndSettle();
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    expect(fakeRepository.completedCalls, hasLength(1));
    final call = fakeRepository.completedCalls.single;
    expect(call.incomeFrequency, IncomeFrequency.periodic);
    expect(call.incomeIntervalType, IncomeIntervalType.biweekly);
    expect(call.nextPaydayDate, isNotNull);
    expect(call.initialIncomeAmount, 5000000);
    expect(call.mandatoryExpenses, isEmpty);
  });

  testWidgets('submit failure keeps the wizard up and shows the error', (
    tester,
  ) async {
    fakeRepository.failWith = Exception('disk full');
    await pumpScreen(tester);

    final nextButtonFinder = find.byKey(
      const ValueKey('onboarding_next_button'),
    );
    await tester.tap(find.byKey(const ValueKey('mode_card_harian')));
    await tester.pumpAndSettle();
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('initial_income_field')),
      '10000',
    );
    await tester.pumpAndSettle();
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();
    await tester.tap(nextButtonFinder);
    await tester.pumpAndSettle();

    expect(find.textContaining('disk full'), findsOneWidget);
    // Still on the wizard, not silently stuck or crashed.
    expect(find.text('Pengeluaran Wajib'), findsOneWidget);
  });

  group('M19/D18: system back steps the wizard back, never exits early', () {
    testWidgets(
      'PopScope.canPop is false on step 2+, and invoking the pop handler '
      'steps the wizard back instead of letting it close',
      (tester) async {
        await pumpScreen(tester);
        final nextButtonFinder = find.byKey(
          const ValueKey('onboarding_next_button'),
        );

        await tester.tap(find.byKey(const ValueKey('mode_card_harian')));
        await tester.pumpAndSettle();
        await tester.tap(nextButtonFinder);
        await tester.pumpAndSettle();
        expect(find.text('Atur Dompet Pertamamu'), findsOneWidget);

        final popScope = tester.widget<PopScope>(
          find.byWidgetPredicate((w) => w is PopScope),
        );
        // Not the first step -> system back must NOT be allowed to pop the
        // (only) route, or it would silently exit the app.
        expect(popScope.canPop, isFalse);

        // Simulate what the system back button/gesture triggers: Flutter
        // calls onPopInvokedWithResult(false, null) whenever canPop is
        // false and a pop was attempted.
        popScope.onPopInvokedWithResult!(false, null);
        await tester.pumpAndSettle();

        // Intercepted into a wizard step-back, not an app exit.
        expect(find.byType(OnboardingScreen), findsOneWidget);
        expect(find.text('Pola Pendapatanmu'), findsOneWidget);
      },
    );

    testWidgets(
      'PopScope.canPop is true on the first step (nothing left for the '
      'wizard to intercept; normal app-exit territory)',
      (tester) async {
        await pumpScreen(tester);
        expect(find.text('Pola Pendapatanmu'), findsOneWidget);

        final popScope = tester.widget<PopScope>(
          find.byWidgetPredicate((w) => w is PopScope),
        );
        expect(popScope.canPop, isTrue);
      },
    );
  });
}
