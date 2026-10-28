// Riverpod providers for M8 Visual Analytics (FR-07).
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/category.dart';
import '../../../core/database/isar_provider.dart';
import '../../../core/database/transaction.dart' as db;
import '../data/analytics_repository.dart';
import '../domain/analytics_models.dart';

/// Repository provider for analytics data queries.
final analyticsRepositoryProvider = Provider<AnalyticsRepositoryBase>((ref) {
  return AnalyticsRepository(ref.watch(isarProvider));
});

/// Reactive stream of transactions for analytics.
final analyticsTransactionsStreamProvider =
    StreamProvider<List<db.Transaction>>((ref) {
      return ref.watch(analyticsRepositoryProvider).watchTransactions();
    });

/// Reactive stream of categories for analytics.
final analyticsCategoriesStreamProvider = StreamProvider<List<Category>>((ref) {
  return ref.watch(analyticsRepositoryProvider).watchCategories();
});

/// Selected period filter (daily, weekly, monthly). Defaults to monthly.
class PeriodFilterNotifier extends Notifier<PeriodFilter> {
  @override
  PeriodFilter build() => PeriodFilter.monthly;

  void setFilter(PeriodFilter filter) {
    state = filter;
  }
}

final periodFilterProvider =
    NotifierProvider<PeriodFilterNotifier, PeriodFilter>(() {
      return PeriodFilterNotifier();
    });

/// Reference date provider (null means DateTime.now() at calculation time).
/// Overridable in tests to fix 'now' to an exact test fixture date.
final analyticsReferenceDateProvider = Provider<DateTime?>((ref) => null);

/// Reactive summary for the selected period (FR-07: breakdown, ratio, totals).
final periodAnalyticsSummaryProvider =
    Provider<AsyncValue<PeriodAnalyticsSummary>>((ref) {
      final txAsync = ref.watch(analyticsTransactionsStreamProvider);
      final catAsync = ref.watch(analyticsCategoriesStreamProvider);
      final filter = ref.watch(periodFilterProvider);
      final refDate = ref.watch(analyticsReferenceDateProvider);

      if (txAsync.isLoading || catAsync.isLoading) {
        return const AsyncValue.loading();
      }

      if (txAsync.hasError) {
        return AsyncValue.error(txAsync.error!, txAsync.stackTrace!);
      }
      if (catAsync.hasError) {
        return AsyncValue.error(catAsync.error!, catAsync.stackTrace!);
      }

      final transactions = txAsync.value ?? const [];
      final categories = catAsync.value ?? const [];

      final summary = AnalyticsCalculationEngine.computePeriodAnalytics(
        transactions: transactions,
        categories: categories,
        period: filter,
        referenceNow: refDate,
      );

      return AsyncValue.data(summary);
    });

/// Reactive summary for Month-over-Month comparison (FR-07: overall & per category).
final monthOverMonthSummaryProvider =
    Provider<AsyncValue<MonthOverMonthSummary>>((ref) {
      final txAsync = ref.watch(analyticsTransactionsStreamProvider);
      final catAsync = ref.watch(analyticsCategoriesStreamProvider);
      final refDate = ref.watch(analyticsReferenceDateProvider);

      if (txAsync.isLoading || catAsync.isLoading) {
        return const AsyncValue.loading();
      }

      if (txAsync.hasError) {
        return AsyncValue.error(txAsync.error!, txAsync.stackTrace!);
      }
      if (catAsync.hasError) {
        return AsyncValue.error(catAsync.error!, catAsync.stackTrace!);
      }

      final transactions = txAsync.value ?? const [];
      final categories = catAsync.value ?? const [];

      final summary = AnalyticsCalculationEngine.computeMonthOverMonth(
        transactions: transactions,
        categories: categories,
        referenceNow: refDate,
      );

      return AsyncValue.data(summary);
    });
