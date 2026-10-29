import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/formulas/daily_budget_formulas.dart';
import 'package:ledgermate/core/theme/app_colors.dart';
import 'package:ledgermate/core/theme/theme_provider.dart';
import 'package:ledgermate/features/analytics/application/analytics_providers.dart';
import 'package:ledgermate/features/analytics/presentation/analytics_screen.dart';
import 'package:ledgermate/features/budget_engine/application/budget_providers.dart';
import 'package:ledgermate/features/budget_engine/presentation/budget_home_screen.dart';
import 'package:ledgermate/features/pay_cycle/application/pay_cycle_providers.dart';
import 'package:ledgermate/features/pay_cycle/presentation/pay_cycle_transition_screen.dart';
import 'package:ledgermate/features/transactions/application/transaction_providers.dart';
import 'package:ledgermate/features/transactions/presentation/transaction_form_screen.dart';

import '../analytics/fake_analytics_repository.dart';
import '../pay_cycle/fake_pay_cycle_repository.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  const modeASummary = DailyBudgetSummary(
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

  const modeBSummary = DailyBudgetSummary(
    incomeFrequency: IncomeFrequency.daily,
    uangJajanAmanHariIni: 105000,
    dailySavingsReserve: 15000,
    modeB: ModeBBudgetResult(
      saldoCarryOver: 100000,
      bekelHariIni: 50000,
      pengeluaranWajibHariIni: 10000,
      pengeluaranHariIni: 20000,
      dailySavingsReserve: 15000,
      uangJajanAmanHariIni: 105000,
    ),
  );

  const negativeSummary = DailyBudgetSummary(
    incomeFrequency: IncomeFrequency.periodic,
    uangJajanAmanHariIni: -50000,
    dailySavingsReserve: 20000,
    modeA: ModeABudgetResult(
      remainingDays: 5,
      remainingBalance: -150000,
      dailySpendingAllowance: -30000,
      dailySavingsReserve: 20000,
      uangJajanAmanHariIni: -50000,
    ),
  );

  Widget buildTestWidget({
    required AsyncValue<DailyBudgetSummary> budgetValue,
    ThemeMode themeMode = ThemeMode.dark,
    LocalProfile? profile,
  }) {
    final fakeRepo = FakePayCycleRepository();
    final testProfile =
        profile ??
        (LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..incomeIntervalType = IncomeIntervalType.monthly
          ..fixedSalary = 5000000
          ..nextPaydayDate = DateTime(2026, 11, 25)
          ..onboardingComplete = true);

    return ProviderScope(
      overrides: [
        dailyBudgetSummaryProvider.overrideWithValue(budgetValue),
        themeModeProvider.overrideWith(() => _TestThemeNotifier(themeMode)),
        payCycleRepositoryProvider.overrideWithValue(fakeRepo),
        budgetProfileStreamProvider.overrideWith(
          (ref) => Stream.value(testProfile),
        ),
        budgetLatestPayCycleStreamProvider.overrideWith(
          (ref) => Stream.value(null),
        ),
        budgetTransactionsStreamProvider.overrideWith(
          (ref) => Stream.value([]),
        ),
        budgetGoalsStreamProvider.overrideWith((ref) => Stream.value([])),
        analyticsRepositoryProvider.overrideWithValue(
          FakeAnalyticsRepository(),
        ),
        // Home (M13) also renders Total Saldo/wallet cards/Rincian Transaksi
        // preview — deterministic empty data for these UI-only assertions.
        transactionsStreamProvider.overrideWith((ref) => Stream.value([])),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          return MaterialApp(
            themeMode: ref.watch(themeModeProvider),
            theme: ref.watch(lightThemeProvider),
            darkTheme: ref.watch(darkThemeProvider),
            home: const BudgetHomeScreen(),
          );
        },
      ),
    );
  }

  group('BudgetHomeScreen UI & Identity Motif', () {
    testWidgets('Mode A renders focal number, badge, and breakdown card', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(budgetValue: const AsyncValue.data(modeASummary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode Periodik'), findsOneWidget);
      // Label wording per docs/design/mockups (renders/01_*): "Jatah Hari Ini"
      // replaces the pre-M13 "Uang Jajan Aman Hari Ini" label text.
      expect(find.text('Jatah Hari Ini'), findsOneWidget);

      // Identity motif check: daily safe-spend number is present
      final focalFinder = find.byKey(const ValueKey('daily_safe_spend_number'));
      expect(focalFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(focalFinder);
      expect(textWidget.data, 'Rp 150.000');
      expect(textWidget.style?.color, AppColors.brandTeal);

      // Subtitle
      expect(
        find.text('Sisa 15 hari sampai jadwal payday berikutnya'),
        findsOneWidget,
      );

      // Breakdown card rows
      expect(find.text('Rincian Perhitungan'), findsOneWidget);
      expect(find.text('Sisa Saldo Siklus'), findsOneWidget);
      expect(find.text('Rp 3.000.000'), findsOneWidget);
      expect(find.text('Jatah Kotor / Hari'), findsOneWidget);
      expect(find.text('Rp 200.000'), findsOneWidget);
      expect(find.text('Tabungan Goal / Hari'), findsOneWidget);
      expect(find.text('- Rp 50.000'), findsOneWidget);
    });

    testWidgets('Mode B renders carry-over metrics and today bekel breakdown', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(budgetValue: const AsyncValue.data(modeBSummary)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mode Harian (Bekel)'), findsOneWidget);
      expect(find.text('Rp 105.000'), findsOneWidget);
      expect(
        find.text('Akumulasi carry-over kemarin & bekel hari ini'),
        findsOneWidget,
      );

      expect(find.text('Saldo Carry-Over Kemarin'), findsOneWidget);
      expect(find.text('Rp 100.000'), findsOneWidget);
      expect(find.text('Bekel Masuk Hari Ini'), findsOneWidget);
      expect(find.text('+ Rp 50.000'), findsOneWidget);
      expect(find.text('Pengeluaran Wajib Hari Ini'), findsOneWidget);
      expect(find.text('- Rp 10.000'), findsOneWidget);
      expect(find.text('Pengeluaran Dicatat Hari Ini'), findsOneWidget);
      expect(find.text('- Rp 20.000'), findsOneWidget);
      expect(find.text('Tabungan Goal / Hari'), findsOneWidget);
      expect(find.text('- Rp 15.000'), findsOneWidget);
    });

    testWidgets('Negative budget renders with expenseRed (overspent)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(budgetValue: const AsyncValue.data(negativeSummary)),
      );
      await tester.pumpAndSettle();

      final focalFinder = find.byKey(const ValueKey('daily_safe_spend_number'));
      expect(focalFinder, findsOneWidget);
      final textWidget = tester.widget<Text>(focalFinder);
      expect(textWidget.data, 'Rp -50.000');
      expect(textWidget.style?.color, AppColors.expenseRed);
    });

    testWidgets(
      'Both dark and light theme render correctly (antislop R-21/R-34)',
      (tester) async {
        // Dark theme check
        await tester.pumpWidget(
          buildTestWidget(
            budgetValue: const AsyncValue.data(modeASummary),
            themeMode: ThemeMode.dark,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Rp 150.000'), findsOneWidget);

        // Light theme check
        await tester.pumpWidget(
          buildTestWidget(
            budgetValue: const AsyncValue.data(modeASummary),
            themeMode: ThemeMode.light,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Rp 150.000'), findsOneWidget);
      },
    );

    testWidgets(
      'Theme toggle via Settings path is unaffected by this screen (moved off AppBar per mockup header)',
      (tester) async {
        // Home's AppBar is now the minimal mockup header (logo + date only,
        // per docs/design/mockups) — the quick theme-toggle action moved
        // entirely to Settings (already has a dedicated dark-mode switch),
        // so there is no in-AppBar toggle left to test here.
        await tester.pumpWidget(
          buildTestWidget(budgetValue: const AsyncValue.data(modeASummary)),
        );
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('theme_toggle_button')), findsNothing);
      },
    );

    testWidgets(
      'FAB opens speed-dial overlay, Catat Pengeluaran navigates to TransactionFormScreen (antislop R-26)',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(budgetValue: const AsyncValue.data(modeASummary)),
        );
        await tester.pumpAndSettle();

        final fab = find.byKey(const ValueKey('home_fab_speed_dial'));
        expect(fab, findsOneWidget);
        await tester.tap(fab);
        await tester.pumpAndSettle();

        final expenseOption = find.byKey(const ValueKey('fab_option_expense'));
        expect(expenseOption, findsOneWidget);
        await tester.tap(expenseOption);
        await tester.pumpAndSettle();

        expect(find.byType(TransactionFormScreen), findsOneWidget);
      },
    );

    testWidgets('Bottom nav renders all 6 tabs with Home active', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(budgetValue: const AsyncValue.data(modeASummary)),
      );
      await tester.pumpAndSettle();

      for (final label in [
        'Home',
        'Transaksi',
        'Goals',
        'Aset',
        'Analitik',
        'Pengaturan',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('Bottom nav item 4 navigates to AnalyticsScreen (M8 FR-07)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildTestWidget(budgetValue: const AsyncValue.data(modeASummary)),
      );
      await tester.pumpAndSettle();

      final navItem = find.text('Analitik');
      expect(navItem, findsOneWidget);
      await tester.tap(navItem);
      await tester.pumpAndSettle();

      expect(find.byType(AnalyticsScreen), findsOneWidget);
    });

    testWidgets('Loading and error states (antislop R-27)', (tester) async {
      // Loading
      await tester.pumpWidget(
        buildTestWidget(budgetValue: const AsyncValue.loading()),
      );
      await tester.pump();
      expect(
        find.byKey(const ValueKey('budget_loading_indicator')),
        findsOneWidget,
      );

      // Error
      await tester.pumpWidget(
        buildTestWidget(
          budgetValue: AsyncValue.error(
            Exception('db error'),
            StackTrace.empty,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Gagal memuat budget'), findsOneWidget);
    });

    testWidgets(
      'Cycle transition banner appears when isCycleExpired is true (Mode A)',
      (tester) async {
        const expiredSummary = DailyBudgetSummary(
          incomeFrequency: IncomeFrequency.periodic,
          uangJajanAmanHariIni: 0,
          dailySavingsReserve: 0,
          isCycleExpired: true,
        );

        await tester.pumpWidget(
          buildTestWidget(budgetValue: const AsyncValue.data(expiredSummary)),
        );
        await tester.pumpAndSettle();

        final banner = find.byKey(const ValueKey('cycle_transition_banner'));
        expect(banner, findsOneWidget);
        expect(find.text('Siklus Gajian Berakhir'), findsOneWidget);

        final button = find.byKey(const ValueKey('cycle_transition_button'));
        expect(button, findsOneWidget);
        expect(find.text('Mulai Siklus Baru'), findsOneWidget);

        await tester.tap(button);
        await tester.pumpAndSettle();

        expect(find.byType(PayCycleTransitionScreen), findsOneWidget);
      },
    );

    testWidgets(
      'Cycle transition banner appears when isCycleExpired is true (Mode B)',
      (tester) async {
        const rolloverSummary = DailyBudgetSummary(
          incomeFrequency: IncomeFrequency.daily,
          uangJajanAmanHariIni: 50000,
          dailySavingsReserve: 0,
          isCycleExpired: true,
        );

        await tester.pumpWidget(
          buildTestWidget(budgetValue: const AsyncValue.data(rolloverSummary)),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('cycle_transition_banner')),
          findsOneWidget,
        );
        expect(find.text('Rollover Harian Dibutuhkan'), findsOneWidget);
        expect(find.text('Rollover Hari Ini'), findsOneWidget);
      },
    );

    testWidgets(
      'Cycle transition banner is hidden when isCycleExpired is false',
      (tester) async {
        await tester.pumpWidget(
          buildTestWidget(budgetValue: const AsyncValue.data(modeASummary)),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('cycle_transition_banner')),
          findsNothing,
        );
      },
    );
  });
}

class _TestThemeNotifier extends ThemeModeNotifier {
  _TestThemeNotifier(this._initial);
  final ThemeMode _initial;

  @override
  ThemeMode build() => _initial;
}
