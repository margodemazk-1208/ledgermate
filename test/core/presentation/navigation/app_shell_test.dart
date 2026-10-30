// M18 Performance Optimization (docs/ROADMAP.md M18, item 5): `AppShell`
// replaces the old push/pushReplacement/pushAndRemoveUntil bottom-nav
// wiring with a persistent, `IndexedStack`-equivalent shell (`Offstage` per
// inactive tab) so switching tabs no longer tears down and rebuilds the
// other tabs' state, and the Android back button returns to Home from any
// other tab instead of exiting the app. The direction-aware horizontal
// slide transition (`docs/DESIGN.md` §Motion touchpoint 1) is preserved on
// top of that persistent structure — see `app_shell.dart`'s header.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/formulas/daily_budget_formulas.dart';
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/core/presentation/navigation/app_shell.dart';
import 'package:ledgermate/core/theme/app_theme.dart';
import 'package:ledgermate/features/analytics/application/analytics_providers.dart';
import 'package:ledgermate/features/assets/application/assets_providers.dart';
import 'package:ledgermate/features/budget_engine/application/budget_providers.dart';
import 'package:ledgermate/features/goals/application/goals_providers.dart';
import 'package:ledgermate/features/settings/application/settings_providers.dart';
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';
import 'package:ledgermate/features/transactions/presentation/transactions_screen.dart';

import '../../../features/analytics/fake_analytics_repository.dart';
import '../../../features/assets/fake_assets_repository.dart';
import '../../../features/goals/fake_goals_repository.dart';
import '../../../features/settings/fake_settings_repository.dart';
import '../../../features/transactions/fake_transaction_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  const summary = DailyBudgetSummary(
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

  Widget buildTestWidget({FakeTransactionRepository? repository}) {
    return ProviderScope(
      overrides: [
        dailyBudgetSummaryProvider.overrideWithValue(
          const AsyncValue.data(summary),
        ),
        // M18 item 5: AppShell mounts ALL 6 tabs simultaneously (Offstage,
        // not removed from the tree) so every tab's own data dependencies
        // are real/active at once, unlike the pre-M18 push-based wiring
        // where only the current route's providers were ever built. Each
        // fake below mirrors what that tab's OWN screen test already uses
        // to avoid the real-Isar-hangs-under-testWidgets() issue (see
        // `widget_test.dart`'s header comment).
        transactionRepositoryProvider.overrideWithValue(
          repository ?? FakeTransactionRepository(),
        ),
        goalsRepositoryProvider.overrideWithValue(FakeGoalsRepository()),
        assetsRepositoryProvider.overrideWithValue(FakeAssetsRepository()),
        analyticsRepositoryProvider.overrideWithValue(
          FakeAnalyticsRepository(),
        ),
        analyticsReferenceDateProvider.overrideWithValue(
          DateTime(2026, 10, 30),
        ),
        settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
      ],
      child: MaterialApp(
        theme: AppTheme.dark,
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AppShell(),
      ),
    );
  }

  group('AppShell bottom-nav persistence (M18/D18 perf item 5)', () {
    testWidgets('tapping each tab switches the visible content', (
      tester,
    ) async {
      // Default test window is tiny (~267x200 logical px) — large enough
      // viewport needed so the empty-state Columns on Goals/Aset don't
      // overflow (same convention `assets_screen_test.dart`/
      // `goals_screen_test.dart` already use).
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Jatah Hari Ini'), findsOneWidget);

      for (final (label, marker) in [
        ('Transaksi', 'Daftar Transaksi'),
        ('Goals', 'Target Tabungan'),
        ('Aset', 'Aset & Investasi'),
        ('Analitik', 'Visual Analitik'),
        ('Pengaturan', 'Pengaturan'),
      ]) {
        await tester.tap(find.text(label).first);
        await tester.pumpAndSettle();
        expect(
          find.text(marker),
          findsWidgets,
          reason: 'tapping $label should reveal "$marker"',
        );
      }

      // Back to Home.
      await tester.tap(find.text('Home').first);
      await tester.pumpAndSettle();
      expect(find.text('Jatah Hari Ini'), findsOneWidget);
    });

    testWidgets(
      'switching away and back preserves scroll position (state is NOT '
      'torn down/rebuilt, unlike the old push/pushReplacement wiring)',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final now = DateTime.now();
        final transactions = List.generate(40, (i) {
          return db.Transaction()
            ..id = i + 1
            ..type = db.TransactionType.expense
            ..amount = 10000 + i * 1000
            ..categoryId = 1
            ..date = now.subtract(Duration(days: i));
        });
        final repository = FakeTransactionRepository(
          initialTransactions: transactions,
        );
        addTearDown(repository.dispose);

        await tester.pumpWidget(buildTestWidget(repository: repository));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Transaksi').first);
        await tester.pumpAndSettle();

        // Several tabs are mounted at once (Offstage, not removed) — target
        // the Transaksi list specifically, not whichever Scrollable happens
        // to come first in the widget tree.
        Finder transactionsListFinder() => find
            .descendant(
              of: find.byType(TransactionsScreen),
              matching: find.byType(Scrollable),
            )
            .first;

        await tester.drag(transactionsListFinder(), const Offset(0, -600));
        await tester.pumpAndSettle();

        final scrolledPosition = tester
            .state<ScrollableState>(transactionsListFinder())
            .position
            .pixels;
        expect(
          scrolledPosition,
          greaterThan(0),
          reason: 'the drag should have actually scrolled the list',
        );

        // Switch to Home and back to Transaksi.
        await tester.tap(find.text('Home').first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Transaksi').first);
        await tester.pumpAndSettle();

        final preservedPosition = tester
            .state<ScrollableState>(transactionsListFinder())
            .position
            .pixels;
        expect(
          preservedPosition,
          scrolledPosition,
          reason:
              'M18 item 5: tab switches must not tear down/rebuild the '
              'other tabs — scroll position should survive a round trip',
        );
      },
    );

    testWidgets(
      'Android back button returns to Home from another tab instead of '
      'exiting the app (M18/D18 perf item 5)',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        await tester.tap(find.text('Transaksi').first);
        await tester.pumpAndSettle();
        expect(find.text('Daftar Transaksi'), findsOneWidget);

        final handled = await tester.binding.handlePopRoute();
        await tester.pumpAndSettle();

        expect(
          handled,
          isTrue,
          reason: 'PopScope must intercept the back gesture on a non-Home tab',
        );
        expect(
          find.text('Jatah Hari Ini'),
          findsOneWidget,
          reason: 'back from a non-Home tab must return to Home, not exit',
        );
        // AppShell itself must still be mounted (never popped/exited).
        expect(find.byType(AppShell), findsOneWidget);
      },
    );

    testWidgets('tab switch slides horizontally, not an instant swap '
        '(docs/DESIGN.md §Motion touchpoint 1)', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Analitik').first);
      await tester.pump(); // transition starts
      await tester.pump(const Duration(milliseconds: 50)); // mid-flight

      final midPosition = tester.getTopLeft(find.text('Visual Analitik').first);

      await tester.pumpAndSettle();
      final restPosition = tester.getTopLeft(find.text('Visual Analitik'));

      expect(
        midPosition.dx,
        isNot(restPosition.dx),
        reason:
            'mid-transition the incoming tab should still be offset from '
            'its final resting position, not an instant swap',
      );
    });
  });
}
