// Smoke test for the boot-time Onboarding/Home gate in `app.dart`.
// Deliberately overrides `onboardingCompleteProvider` directly instead of
// `isarProvider`: `testWidgets()`'s test binding hangs indefinitely on
// real Isar async calls (confirmed by direct repro — open/read/write/watch
// all stall under `AutomatedTestWidgetsFlutterBinding`, unrelated to this
// feature's code). Overriding the derived provider tests the exact same
// routing branch (`_OnboardingGate`'s `.when(...)`) without ever touching
// Isar. Real Isar persistence is covered by
// `test/features/onboarding/onboarding_repository_test.dart` (plain
// `test()`, where Isar works fine) and `isar_collections_test.dart`/
// `isar_provider_test.dart` (M1).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/app.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/formulas/daily_budget_formulas.dart';
import 'package:ledgermate/features/budget_engine/application/budget_providers.dart';
import 'package:ledgermate/features/onboarding/application/onboarding_providers.dart';

void main() {
  const sampleSummary = DailyBudgetSummary(
    incomeFrequency: IncomeFrequency.periodic,
    uangJajanAmanHariIni: 150000,
    dailySavingsReserve: 50000,
    modeA: ModeABudgetResult(
      remainingDays: 15,
      remainingBalance: 3000000,
      dailySpendingAllowance: 200000,
      dailySavingsReserve: 50000,
      uangJajanAmanHariIni: 150000,
    ),
  );

  testWidgets('onboarding incomplete shows the Onboarding Wizard', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(
            const AsyncValue.data(false),
          ),
        ],
        child: const LedgerMateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pola Pendapatanmu'), findsOneWidget);
    expect(find.text('Jatah Hari Ini'), findsNothing);
  });

  testWidgets('onboarding complete shows the Budget Home dashboard', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(
            const AsyncValue.data(true),
          ),
          dailyBudgetSummaryProvider.overrideWithValue(
            const AsyncValue.data(sampleSummary),
          ),
        ],
        child: const LedgerMateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jatah Hari Ini'), findsOneWidget);
    expect(find.text('Rp 150.000'), findsOneWidget);
    expect(find.text('Pola Pendapatanmu'), findsNothing);
  });

  testWidgets('loading state shows a spinner, not a blank/broken screen', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(
            const AsyncValue.loading(),
          ),
        ],
        child: const LedgerMateApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('error state shows a message, not a crash (antislop R-27)', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompleteProvider.overrideWithValue(
            AsyncValue.error(Exception('boom'), StackTrace.empty),
          ),
        ],
        child: const LedgerMateApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('Gagal memuat data'), findsOneWidget);
  });
}
