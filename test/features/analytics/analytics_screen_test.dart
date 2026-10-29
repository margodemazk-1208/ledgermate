import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/theme/theme_provider.dart';
import 'package:ledgermate/features/analytics/application/analytics_providers.dart';
import 'package:ledgermate/features/analytics/presentation/analytics_screen.dart';
import 'package:ledgermate/features/analytics/presentation/widgets/analytics_empty_state.dart';
import 'package:ledgermate/features/analytics/presentation/widgets/category_breakdown_card.dart';
import 'package:ledgermate/features/analytics/presentation/widgets/income_expense_ratio_card.dart';
import 'package:ledgermate/features/analytics/presentation/widgets/month_over_month_section.dart';
import 'package:ledgermate/features/transactions/presentation/transaction_form_screen.dart';

import 'fake_analytics_repository.dart';

void main() {
  late FakeAnalyticsRepository repository;
  final fixedNow = DateTime(2026, 10, 28, 14, 0); // October 28, 2026

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    final categories = [
      Category()
        ..id = 1
        ..name = 'Makan'
        ..isDefault = true,
      Category()
        ..id = 2
        ..name = 'Transport'
        ..isDefault = true,
      Category()
        ..id = 3
        ..name = 'Tagihan'
        ..isDefault = true,
    ];
    repository = FakeAnalyticsRepository(initialCategories: categories);
  });

  tearDown(() {
    repository.dispose();
  });

  Widget buildTestWidget({
    Widget? child,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      overrides: [
        analyticsRepositoryProvider.overrideWithValue(repository),
        analyticsReferenceDateProvider.overrideWithValue(fixedNow),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final darkTheme = ref.watch(darkThemeProvider);
          final lightTheme = ref.watch(lightThemeProvider);
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            home: child ?? const AnalyticsScreen(),
          );
        },
      ),
    );
  }

  group('AnalyticsScreen presentation (FR-07, antislop R-26, R-27, R-34)', () {
    testWidgets('renders empty state when no transactions exist (R-27)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Visual Analitik'), findsOneWidget);
      expect(find.byType(AnalyticsEmptyState), findsOneWidget);
      expect(
        find.text('Belum ada transaksi pada periode ini.'),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('analytics_empty_catat_button')),
        findsOneWidget,
      );
    });

    testWidgets('empty state CTA navigates to TransactionFormScreen (R-26)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final ctaButton = find.byKey(
        const ValueKey('analytics_empty_catat_button'),
      );
      expect(ctaButton, findsOneWidget);
      await tester.tap(ctaButton);
      await tester.pumpAndSettle();

      expect(find.byType(TransactionFormScreen), findsOneWidget);
      expect(find.text('Catat Transaksi'), findsOneWidget);
    });

    testWidgets('FAB navigates to TransactionFormScreen', (tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      final fab = find.byKey(const ValueKey('analytics_add_transaction_fab'));
      expect(fab, findsOneWidget);
      await tester.tap(fab);
      await tester.pumpAndSettle();

      expect(find.byType(TransactionFormScreen), findsOneWidget);
      expect(find.text('Catat Transaksi'), findsOneWidget);
    });

    testWidgets(
      'renders income vs expense ratio card, breakdown, and MoM when transactions exist',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        // Set up transactions in current and previous months
        repository.setTransactions([
          // October 2026 (current)
          db.Transaction()
            ..id = 1
            ..type = db.TransactionType.expense
            ..amount = 150000
            ..categoryId =
                1 // Makan
            ..date = DateTime(2026, 10, 10),
          db.Transaction()
            ..id = 2
            ..type = db.TransactionType.expense
            ..amount = 50000
            ..categoryId =
                2 // Transport
            ..date = DateTime(2026, 10, 15),
          db.Transaction()
            ..id = 3
            ..type = db.TransactionType.income
            ..amount = 500000
            ..categoryId = 1
            ..date = DateTime(2026, 10, 5),
          // September 2026 (previous month for MoM)
          db.Transaction()
            ..id = 4
            ..type = db.TransactionType.expense
            ..amount = 120000
            ..categoryId = 1
            ..date = DateTime(2026, 9, 12),
          db.Transaction()
            ..id = 5
            ..type = db.TransactionType.income
            ..amount = 400000
            ..categoryId = 1
            ..date = DateTime(2026, 9, 2),
        ]);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Empty state should NOT be present
        expect(find.byType(AnalyticsEmptyState), findsNothing);

        // Ratio Card should be present
        expect(find.byType(IncomeExpenseRatioCard), findsOneWidget);
        expect(find.text('Ringkasan Keuangan Periode'), findsOneWidget);
        expect(find.text('Total Pemasukan'), findsOneWidget);
        expect(find.text('Total Pengeluaran'), findsOneWidget);
        expect(find.text('Tabungan Bersih'), findsOneWidget);

        // Category Breakdown Card should be present
        expect(find.byType(CategoryBreakdownCard), findsOneWidget);
        expect(find.text('Proporsi Pengeluaran per Kategori'), findsOneWidget);
        expect(find.text('Makan'), findsAtLeastNWidgets(1));
        expect(find.text('Transport'), findsAtLeastNWidgets(1));

        // MoM Section should be present
        expect(find.byType(MonthOverMonthSection), findsOneWidget);
        expect(find.text('Tren Bulan-ke-Bulan (MoM)'), findsOneWidget);
      },
    );

    testWidgets(
      'CategoryBreakdownCard toggles between Pie and Bar chart views',
      (tester) async {
        repository.setTransactions([
          db.Transaction()
            ..id = 1
            ..type = db.TransactionType.expense
            ..amount = 100000
            ..categoryId = 1
            ..date = DateTime(2026, 10, 10),
          db.Transaction()
            ..id = 2
            ..type = db.TransactionType.expense
            ..amount = 50000
            ..categoryId = 2
            ..date = DateTime(2026, 10, 15),
        ]);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Toggle button should be present
        final toggleBtn = find.byKey(
          const ValueKey('toggle_chart_type_button'),
        );
        expect(toggleBtn, findsOneWidget);

        // Tap Toggle (Pie -> Bar)
        await tester.tap(toggleBtn);
        await tester.pumpAndSettle();

        // Tap Toggle again (Bar -> Pie)
        await tester.tap(toggleBtn);
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'Period filter selector switches between Harian, Mingguan, and Bulanan',
      (tester) async {
        repository.setTransactions([
          // Today (Oct 28)
          db.Transaction()
            ..id = 1
            ..type = db.TransactionType.expense
            ..amount = 25000
            ..categoryId = 1
            ..date = DateTime(2026, 10, 28, 10, 0),
          // Earlier this week (Oct 26)
          db.Transaction()
            ..id = 2
            ..type = db.TransactionType.expense
            ..amount = 40000
            ..categoryId = 2
            ..date = DateTime(2026, 10, 26, 9, 0),
          // Earlier this month (Oct 5)
          db.Transaction()
            ..id = 3
            ..type = db.TransactionType.expense
            ..amount = 80000
            ..categoryId = 3
            ..date = DateTime(2026, 10, 5, 12, 0),
        ]);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        // Bulanan is default - should show Oktober 2026
        expect(find.text('Oktober 2026'), findsOneWidget);

        // Tap Harian segment
        final harianSegment = find.text('Harian');
        expect(harianSegment, findsOneWidget);
        await tester.tap(harianSegment);
        await tester.pumpAndSettle();

        expect(find.text('28 Oktober 2026'), findsOneWidget);

        // Tap Mingguan segment
        final mingguanSegment = find.text('Mingguan');
        expect(mingguanSegment, findsOneWidget);
        await tester.tap(mingguanSegment);
        await tester.pumpAndSettle();

        expect(find.text('26 Oktober - 1 November 2026'), findsOneWidget);
      },
    );

    testWidgets(
      'Theme toggle button works in both dark and light mode (antislop R-21/R-34)',
      (tester) async {
        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        final themeBtn = find.byKey(
          const ValueKey('analytics_theme_toggle_button'),
        );
        expect(themeBtn, findsOneWidget);

        // Tap toggle
        await tester.tap(themeBtn);
        await tester.pumpAndSettle();

        // Tap toggle again
        await tester.tap(themeBtn);
        await tester.pumpAndSettle();
      },
    );
  });
}
