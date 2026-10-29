import 'package:flutter/foundation.dart' hide Category;

import '../../../core/database/category.dart';
import '../../../core/database/transaction.dart' as db;

/// Filter periode analitik (PRD FR-07 acceptance criteria).
enum PeriodFilter { daily, weekly, monthly }

/// Rentang tanggal inklusif untuk query dan agregasi.
@immutable
class DateRange {
  const DateRange({
    required this.start,
    required this.end,
    required this.label,
  });

  final DateTime start;
  final DateTime end;
  final String label;

  bool contains(DateTime date) {
    return !date.isBefore(start) && !date.isAfter(end);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          start == other.start &&
          end == other.end &&
          label == other.label;

  @override
  int get hashCode => Object.hash(start, end, label);
}

/// Breakdown pengeluaran per kategori pada periode tertentu.
@immutable
class CategoryExpenseBreakdown {
  const CategoryExpenseBreakdown({
    required this.categoryId,
    required this.categoryName,
    required this.totalExpense,
    required this.percentage,
    required this.transactionCount,
  });

  final int categoryId;
  final String categoryName;
  final int totalExpense; // whole-Rupiah int
  final double percentage; // 0.0 .. 100.0
  final int transactionCount;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryExpenseBreakdown &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          totalExpense == other.totalExpense &&
          percentage == other.percentage &&
          transactionCount == other.transactionCount;

  @override
  int get hashCode => Object.hash(
    categoryId,
    categoryName,
    totalExpense,
    percentage,
    transactionCount,
  );
}

/// Ringkasan analitik untuk satu periode yang dipilih.
@immutable
class PeriodAnalyticsSummary {
  const PeriodAnalyticsSummary({
    required this.period,
    required this.dateRange,
    required this.totalExpense,
    required this.totalIncome,
    required this.categoryBreakdowns,
    required this.transactionCount,
  });

  final PeriodFilter period;
  final DateRange dateRange;
  final int totalExpense; // whole-Rupiah int
  final int totalIncome; // whole-Rupiah int
  final List<CategoryExpenseBreakdown> categoryBreakdowns;
  final int transactionCount;

  /// Rasio pengeluaran terhadap pemasukan (0.0 jika pemasukan 0, atau desimal > 0).
  /// Contoh: 0.65 artinya pengeluaran adalah 65% dari pemasukan.
  double? get expenseToIncomeRatio {
    if (totalIncome <= 0) return null;
    return totalExpense / totalIncome;
  }

  /// Tabungan/sisa bersih pada periode ini (income - expense).
  int get netBalance => totalIncome - totalExpense;

  /// Apakah tidak ada transaksi sama sekali di periode ini (empty state trigger).
  bool get isEmpty => transactionCount == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PeriodAnalyticsSummary &&
          runtimeType == other.runtimeType &&
          period == other.period &&
          dateRange == other.dateRange &&
          totalExpense == other.totalExpense &&
          totalIncome == other.totalIncome &&
          listEquals(categoryBreakdowns, other.categoryBreakdowns) &&
          transactionCount == other.transactionCount;

  @override
  int get hashCode => Object.hash(
    period,
    dateRange,
    totalExpense,
    totalIncome,
    Object.hashAll(categoryBreakdowns),
    transactionCount,
  );
}

/// Perbandingan pengeluaran per kategori antara bulan ini vs bulan lalu.
@immutable
class CategoryMonthComparison {
  const CategoryMonthComparison({
    required this.categoryId,
    required this.categoryName,
    required this.currentMonthExpense,
    required this.previousMonthExpense,
    required this.difference,
    required this.changePercentage,
  });

  final int categoryId;
  final String categoryName;
  final int currentMonthExpense;
  final int previousMonthExpense;
  final int difference; // current - previous (positif = naik, negatif = turun)
  final double? changePercentage; // null bila previous == 0

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryMonthComparison &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId &&
          categoryName == other.categoryName &&
          currentMonthExpense == other.currentMonthExpense &&
          previousMonthExpense == other.previousMonthExpense &&
          difference == other.difference &&
          changePercentage == other.changePercentage;

  @override
  int get hashCode => Object.hash(
    categoryId,
    categoryName,
    currentMonthExpense,
    previousMonthExpense,
    difference,
    changePercentage,
  );
}

/// Ringkasan perbandingan bulan-ke-bulan (Month-over-Month / MoM).
@immutable
class MonthOverMonthSummary {
  const MonthOverMonthSummary({
    required this.currentMonthRange,
    required this.previousMonthRange,
    required this.currentMonthExpense,
    required this.previousMonthExpense,
    required this.expenseDifference,
    required this.expenseChangePercentage,
    required this.currentMonthIncome,
    required this.previousMonthIncome,
    required this.incomeDifference,
    required this.incomeChangePercentage,
    required this.categoryComparisons,
    required this.totalTransactionsAnalyzed,
  });

  final DateRange currentMonthRange;
  final DateRange previousMonthRange;
  final int currentMonthExpense;
  final int previousMonthExpense;
  final int expenseDifference; // current - previous
  final double? expenseChangePercentage;
  final int currentMonthIncome;
  final int previousMonthIncome;
  final int incomeDifference;
  final double? incomeChangePercentage;
  final List<CategoryMonthComparison> categoryComparisons;
  final int totalTransactionsAnalyzed;

  bool get isEmpty =>
      currentMonthExpense == 0 &&
      previousMonthExpense == 0 &&
      currentMonthIncome == 0 &&
      previousMonthIncome == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MonthOverMonthSummary &&
          runtimeType == other.runtimeType &&
          currentMonthRange == other.currentMonthRange &&
          previousMonthRange == other.previousMonthRange &&
          currentMonthExpense == other.currentMonthExpense &&
          previousMonthExpense == other.previousMonthExpense &&
          expenseDifference == other.expenseDifference &&
          expenseChangePercentage == other.expenseChangePercentage &&
          currentMonthIncome == other.currentMonthIncome &&
          previousMonthIncome == other.previousMonthIncome &&
          incomeDifference == other.incomeDifference &&
          incomeChangePercentage == other.incomeChangePercentage &&
          listEquals(categoryComparisons, other.categoryComparisons) &&
          totalTransactionsAnalyzed == other.totalTransactionsAnalyzed;

  @override
  int get hashCode => Object.hash(
    currentMonthRange,
    previousMonthRange,
    currentMonthExpense,
    previousMonthExpense,
    expenseDifference,
    expenseChangePercentage,
    currentMonthIncome,
    previousMonthIncome,
    incomeDifference,
    incomeChangePercentage,
    Object.hashAll(categoryComparisons),
    totalTransactionsAnalyzed,
  );
}

/// Pure calculation engine for analytics aggregations.
/// Framework-free, completely isolated and 100% unit-testable.
abstract final class AnalyticsCalculationEngine {
  static const List<String> monthNames = [
    '',
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Menghitung rentang tanggal presisi untuk periode yang dipilih.
  static DateRange getDateRange(PeriodFilter period, [DateTime? referenceNow]) {
    final now = referenceNow ?? DateTime.now();
    switch (period) {
      case PeriodFilter.daily:
        final start = DateTime(now.year, now.month, now.day, 0, 0, 0);
        final end = DateTime(now.year, now.month, now.day, 23, 59, 59, 999);
        return DateRange(
          start: start,
          end: end,
          label: '${now.day} ${monthNames[now.month]} ${now.year}',
        );

      case PeriodFilter.weekly:
        // Monday to Sunday
        final daysSinceMonday = now.weekday - 1;
        final monday = now.subtract(Duration(days: daysSinceMonday));
        final start = DateTime(monday.year, monday.month, monday.day, 0, 0, 0);
        final sunday = monday.add(const Duration(days: 6));
        final end = DateTime(
          sunday.year,
          sunday.month,
          sunday.day,
          23,
          59,
          59,
          999,
        );
        return DateRange(
          start: start,
          end: end,
          label:
              '${monday.day} ${monthNames[monday.month]} - ${sunday.day} ${monthNames[sunday.month]} ${sunday.year}',
        );

      case PeriodFilter.monthly:
        final start = DateTime(now.year, now.month, 1, 0, 0, 0);
        final lastDay = DateTime(now.year, now.month + 1, 0).day;
        final end = DateTime(now.year, now.month, lastDay, 23, 59, 59, 999);
        return DateRange(
          start: start,
          end: end,
          label: '${monthNames[now.month]} ${now.year}',
        );
    }
  }

  /// Menghitung ringkasan pengeluaran & pemasukan serta breakdown kategori
  /// untuk periode tertentu.
  static PeriodAnalyticsSummary computePeriodAnalytics({
    required List<db.Transaction> transactions,
    required List<Category> categories,
    required PeriodFilter period,
    DateTime? referenceNow,
  }) {
    final range = getDateRange(period, referenceNow);
    final categoryMap = {for (final c in categories) c.id: c.name};

    int totalExpense = 0;
    int totalIncome = 0;
    int transactionCount = 0;
    final expenseByCategory = <int, int>{};
    final countByCategory = <int, int>{};

    for (final tx in transactions) {
      if (!range.contains(tx.date)) continue;
      if (tx.type == db.TransactionType.transfer) continue;

      transactionCount++;
      if (tx.type == db.TransactionType.expense) {
        totalExpense += tx.amount;
        expenseByCategory[tx.categoryId] =
            (expenseByCategory[tx.categoryId] ?? 0) + tx.amount;
        countByCategory[tx.categoryId] =
            (countByCategory[tx.categoryId] ?? 0) + 1;
      } else if (tx.type == db.TransactionType.income) {
        totalIncome += tx.amount;
      }
    }

    final breakdowns = <CategoryExpenseBreakdown>[];
    for (final entry in expenseByCategory.entries) {
      final catId = entry.key;
      final amount = entry.value;
      final catName = categoryMap[catId] ?? 'Lainnya';
      final pct = totalExpense > 0 ? (amount / totalExpense) * 100.0 : 0.0;
      breakdowns.add(
        CategoryExpenseBreakdown(
          categoryId: catId,
          categoryName: catName,
          totalExpense: amount,
          percentage: pct,
          transactionCount: countByCategory[catId] ?? 0,
        ),
      );
    }

    // Sort by largest expense first
    breakdowns.sort((a, b) => b.totalExpense.compareTo(a.totalExpense));

    return PeriodAnalyticsSummary(
      period: period,
      dateRange: range,
      totalExpense: totalExpense,
      totalIncome: totalIncome,
      categoryBreakdowns: breakdowns,
      transactionCount: transactionCount,
    );
  }

  /// Menghitung perbandingan bulan ini vs bulan sebelumnya (Month-over-Month).
  static MonthOverMonthSummary computeMonthOverMonth({
    required List<db.Transaction> transactions,
    required List<Category> categories,
    DateTime? referenceNow,
  }) {
    final now = referenceNow ?? DateTime.now();
    final currentRange = getDateRange(PeriodFilter.monthly, now);

    // Bulan sebelumnya (Dart DateTime otomatis handle pergantian tahun)
    final prevMonthDate = DateTime(now.year, now.month - 1, 15);
    final prevRange = getDateRange(PeriodFilter.monthly, prevMonthDate);

    final categoryMap = {for (final c in categories) c.id: c.name};

    int currentExpense = 0;
    int prevExpense = 0;
    int currentIncome = 0;
    int prevIncome = 0;
    int totalCount = 0;

    final currentExpenseByCat = <int, int>{};
    final prevExpenseByCat = <int, int>{};

    for (final tx in transactions) {
      if (tx.type == db.TransactionType.transfer) continue;

      if (currentRange.contains(tx.date)) {
        totalCount++;
        if (tx.type == db.TransactionType.expense) {
          currentExpense += tx.amount;
          currentExpenseByCat[tx.categoryId] =
              (currentExpenseByCat[tx.categoryId] ?? 0) + tx.amount;
        } else if (tx.type == db.TransactionType.income) {
          currentIncome += tx.amount;
        }
      } else if (prevRange.contains(tx.date)) {
        totalCount++;
        if (tx.type == db.TransactionType.expense) {
          prevExpense += tx.amount;
          prevExpenseByCat[tx.categoryId] =
              (prevExpenseByCat[tx.categoryId] ?? 0) + tx.amount;
        } else if (tx.type == db.TransactionType.income) {
          prevIncome += tx.amount;
        }
      }
    }

    final allCategoryIds = {
      ...currentExpenseByCat.keys,
      ...prevExpenseByCat.keys,
    };

    final catComparisons = <CategoryMonthComparison>[];
    for (final catId in allCategoryIds) {
      final curr = currentExpenseByCat[catId] ?? 0;
      final prev = prevExpenseByCat[catId] ?? 0;
      final diff = curr - prev;
      final double? pct = prev > 0 ? (diff / prev) * 100.0 : null;
      catComparisons.add(
        CategoryMonthComparison(
          categoryId: catId,
          categoryName: categoryMap[catId] ?? 'Lainnya',
          currentMonthExpense: curr,
          previousMonthExpense: prev,
          difference: diff,
          changePercentage: pct,
        ),
      );
    }

    // Urutkan kategori berdasarkan total pengeluaran bulan ini (atau bulan lalu jika bulan ini 0)
    catComparisons.sort((a, b) {
      final comp = b.currentMonthExpense.compareTo(a.currentMonthExpense);
      if (comp != 0) return comp;
      return b.previousMonthExpense.compareTo(a.previousMonthExpense);
    });

    final expenseDiff = currentExpense - prevExpense;
    final double? expensePct = prevExpense > 0
        ? (expenseDiff / prevExpense) * 100.0
        : null;

    final incomeDiff = currentIncome - prevIncome;
    final double? incomePct = prevIncome > 0
        ? (incomeDiff / prevIncome) * 100.0
        : null;

    return MonthOverMonthSummary(
      currentMonthRange: currentRange,
      previousMonthRange: prevRange,
      currentMonthExpense: currentExpense,
      previousMonthExpense: prevExpense,
      expenseDifference: expenseDiff,
      expenseChangePercentage: expensePct,
      currentMonthIncome: currentIncome,
      previousMonthIncome: prevIncome,
      incomeDifference: incomeDiff,
      incomeChangePercentage: incomePct,
      categoryComparisons: catComparisons,
      totalTransactionsAnalyzed: totalCount,
    );
  }
}
