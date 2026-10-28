import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/category.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/analytics/domain/analytics_models.dart';

void main() {
  group('AnalyticsCalculationEngine - Date Range', () {
    final fixedDate = DateTime(2026, 10, 28, 14, 30); // Wednesday

    test(
      'daily range covers exact calendar day from 00:00 to 23:59:59.999',
      () {
        final range = AnalyticsCalculationEngine.getDateRange(
          PeriodFilter.daily,
          fixedDate,
        );
        expect(range.start, DateTime(2026, 10, 28, 0, 0, 0));
        expect(range.end, DateTime(2026, 10, 28, 23, 59, 59, 999));
        expect(range.label, '28 Oktober 2026');
        expect(range.contains(DateTime(2026, 10, 28, 0, 0, 0)), isTrue);
        expect(range.contains(DateTime(2026, 10, 28, 23, 59, 59)), isTrue);
        expect(range.contains(DateTime(2026, 10, 27, 23, 59, 59)), isFalse);
        expect(range.contains(DateTime(2026, 10, 29, 0, 0, 0)), isFalse);
      },
    );

    test('weekly range covers Monday to Sunday', () {
      final range = AnalyticsCalculationEngine.getDateRange(
        PeriodFilter.weekly,
        fixedDate, // Wednesday Oct 28 -> Mon Oct 26 to Sun Nov 1
      );
      expect(range.start, DateTime(2026, 10, 26, 0, 0, 0));
      expect(range.end, DateTime(2026, 11, 1, 23, 59, 59, 999));
      expect(range.label, '26 Oktober - 1 November 2026');
      expect(range.contains(DateTime(2026, 10, 26, 0, 0)), isTrue);
      expect(range.contains(DateTime(2026, 11, 1, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 10, 25, 23, 59)), isFalse);
    });

    test('monthly range covers 1st to last day of month', () {
      final range = AnalyticsCalculationEngine.getDateRange(
        PeriodFilter.monthly,
        fixedDate,
      );
      expect(range.start, DateTime(2026, 10, 1, 0, 0, 0));
      expect(range.end, DateTime(2026, 10, 31, 23, 59, 59, 999));
      expect(range.label, 'Oktober 2026');
      expect(range.contains(DateTime(2026, 10, 1, 0, 0)), isTrue);
      expect(range.contains(DateTime(2026, 10, 31, 23, 59)), isTrue);
      expect(range.contains(DateTime(2026, 9, 30, 23, 59)), isFalse);
    });
  });

  group('AnalyticsCalculationEngine - Period Analytics Aggregation', () {
    final fixedDate = DateTime(2026, 10, 28, 12, 0);
    final categories = [
      Category()
        ..id = 1
        ..name = 'Makan',
      Category()
        ..id = 2
        ..name = 'Transport',
      Category()
        ..id = 3
        ..name = 'Tagihan',
    ];

    test('empty transactions returns empty summary with isEmpty=true', () {
      final summary = AnalyticsCalculationEngine.computePeriodAnalytics(
        transactions: [],
        categories: categories,
        period: PeriodFilter.monthly,
        referenceNow: fixedDate,
      );

      expect(summary.isEmpty, isTrue);
      expect(summary.totalExpense, 0);
      expect(summary.totalIncome, 0);
      expect(summary.categoryBreakdowns, isEmpty);
      expect(summary.transactionCount, 0);
      expect(summary.expenseToIncomeRatio, isNull);
      expect(summary.netBalance, 0);
    });

    test(
      'aggregates income and expenses correctly in range and ignores outside',
      () {
        final transactions = [
          // In range (October 2026)
          db.Transaction()
            ..id = 1
            ..type = db.TransactionType.expense
            ..amount = 50000
            ..categoryId =
                1 // Makan
            ..date = DateTime(2026, 10, 10),
          db.Transaction()
            ..id = 2
            ..type = db.TransactionType.expense
            ..amount = 30000
            ..categoryId =
                1 // Makan
            ..date = DateTime(2026, 10, 12),
          db.Transaction()
            ..id = 3
            ..type = db.TransactionType.expense
            ..amount = 20000
            ..categoryId =
                2 // Transport
            ..date = DateTime(2026, 10, 15),
          db.Transaction()
            ..id = 4
            ..type = db.TransactionType.income
            ..amount = 200000
            ..categoryId = 1
            ..date = DateTime(2026, 10, 5),
          // Outside range (September 2026)
          db.Transaction()
            ..id = 5
            ..type = db.TransactionType.expense
            ..amount = 100000
            ..categoryId = 3
            ..date = DateTime(2026, 9, 25),
        ];

        final summary = AnalyticsCalculationEngine.computePeriodAnalytics(
          transactions: transactions,
          categories: categories,
          period: PeriodFilter.monthly,
          referenceNow: fixedDate,
        );

        expect(summary.isEmpty, isFalse);
        expect(summary.transactionCount, 4);
        expect(summary.totalExpense, 100000); // 50k + 30k + 20k
        expect(summary.totalIncome, 200000);
        expect(summary.netBalance, 100000);
        expect(summary.expenseToIncomeRatio, 0.5); // 100k / 200k

        expect(summary.categoryBreakdowns.length, 2);
        // Makan: 80k (80%), 2 transactions
        expect(summary.categoryBreakdowns[0].categoryName, 'Makan');
        expect(summary.categoryBreakdowns[0].totalExpense, 80000);
        expect(summary.categoryBreakdowns[0].percentage, 80.0);
        expect(summary.categoryBreakdowns[0].transactionCount, 2);

        // Transport: 20k (20%), 1 transaction
        expect(summary.categoryBreakdowns[1].categoryName, 'Transport');
        expect(summary.categoryBreakdowns[1].totalExpense, 20000);
        expect(summary.categoryBreakdowns[1].percentage, 20.0);
        expect(summary.categoryBreakdowns[1].transactionCount, 1);
      },
    );

    test('handles unknown category gracefully by labeling as Lainnya', () {
      final transactions = [
        db.Transaction()
          ..id = 1
          ..type = db.TransactionType.expense
          ..amount = 45000
          ..categoryId =
              999 // Unregistered
          ..date = DateTime(2026, 10, 20),
      ];

      final summary = AnalyticsCalculationEngine.computePeriodAnalytics(
        transactions: transactions,
        categories: categories,
        period: PeriodFilter.monthly,
        referenceNow: fixedDate,
      );

      expect(summary.categoryBreakdowns.length, 1);
      expect(summary.categoryBreakdowns.first.categoryName, 'Lainnya');
      expect(summary.categoryBreakdowns.first.totalExpense, 45000);
      expect(summary.categoryBreakdowns.first.percentage, 100.0);
    });
  });

  group('AnalyticsCalculationEngine - Month-over-Month Comparison', () {
    final fixedDate = DateTime(2026, 10, 28, 12, 0);
    final categories = [
      Category()
        ..id = 1
        ..name = 'Makan',
      Category()
        ..id = 2
        ..name = 'Transport',
    ];

    test('empty transactions returns empty MoM summary', () {
      final mom = AnalyticsCalculationEngine.computeMonthOverMonth(
        transactions: [],
        categories: categories,
        referenceNow: fixedDate,
      );
      expect(mom.isEmpty, isTrue);
      expect(mom.currentMonthExpense, 0);
      expect(mom.previousMonthExpense, 0);
      expect(mom.expenseDifference, 0);
      expect(mom.expenseChangePercentage, isNull);
      expect(mom.categoryComparisons, isEmpty);
    });

    test('computes overall and per-category MoM differences accurately', () {
      final transactions = [
        // Previous month (September 2026)
        db.Transaction()
          ..type = db.TransactionType.expense
          ..amount = 100000
          ..categoryId =
              1 // Makan
          ..date = DateTime(2026, 9, 10),
        db.Transaction()
          ..type = db.TransactionType.expense
          ..amount = 50000
          ..categoryId =
              2 // Transport
          ..date = DateTime(2026, 9, 15),
        db.Transaction()
          ..type = db.TransactionType.income
          ..amount = 1000000
          ..categoryId = 1
          ..date = DateTime(2026, 9, 1),

        // Current month (October 2026)
        db.Transaction()
          ..type = db.TransactionType.expense
          ..amount =
              120000 // Makan went up by 20k (+20%)
          ..categoryId = 1
          ..date = DateTime(2026, 10, 5),
        db.Transaction()
          ..type = db.TransactionType.expense
          ..amount =
              40000 // Transport went down by 10k (-20%)
          ..categoryId = 2
          ..date = DateTime(2026, 10, 10),
        db.Transaction()
          ..type = db.TransactionType.income
          ..amount =
              1200000 // Income went up by 200k (+20%)
          ..categoryId = 1
          ..date = DateTime(2026, 10, 1),
      ];

      final mom = AnalyticsCalculationEngine.computeMonthOverMonth(
        transactions: transactions,
        categories: categories,
        referenceNow: fixedDate,
      );

      expect(mom.isEmpty, isFalse);
      expect(mom.previousMonthExpense, 150000);
      expect(mom.currentMonthExpense, 160000);
      expect(mom.expenseDifference, 10000);
      expect(mom.expenseChangePercentage, closeTo(6.66, 0.05));

      expect(mom.previousMonthIncome, 1000000);
      expect(mom.currentMonthIncome, 1200000);
      expect(mom.incomeDifference, 200000);
      expect(mom.incomeChangePercentage, 20.0);

      // Per-category comparisons
      expect(mom.categoryComparisons.length, 2);

      // Makan
      final makanComp = mom.categoryComparisons.firstWhere(
        (c) => c.categoryName == 'Makan',
      );
      expect(makanComp.currentMonthExpense, 120000);
      expect(makanComp.previousMonthExpense, 100000);
      expect(makanComp.difference, 20000);
      expect(makanComp.changePercentage, 20.0);

      // Transport
      final transportComp = mom.categoryComparisons.firstWhere(
        (c) => c.categoryName == 'Transport',
      );
      expect(transportComp.currentMonthExpense, 40000);
      expect(transportComp.previousMonthExpense, 50000);
      expect(transportComp.difference, -10000);
      expect(transportComp.changePercentage, -20.0);
    });

    test(
      'handles category with zero previous expense without division by zero',
      () {
        final transactions = [
          // Current month only
          db.Transaction()
            ..type = db.TransactionType.expense
            ..amount = 75000
            ..categoryId = 1
            ..date = DateTime(2026, 10, 10),
        ];

        final mom = AnalyticsCalculationEngine.computeMonthOverMonth(
          transactions: transactions,
          categories: categories,
          referenceNow: fixedDate,
        );

        expect(mom.previousMonthExpense, 0);
        expect(mom.currentMonthExpense, 75000);
        expect(mom.expenseDifference, 75000);
        expect(mom.expenseChangePercentage, isNull);

        final catComp = mom.categoryComparisons.first;
        expect(catComp.currentMonthExpense, 75000);
        expect(catComp.previousMonthExpense, 0);
        expect(catComp.difference, 75000);
        expect(catComp.changePercentage, isNull);
      },
    );
  });
}
