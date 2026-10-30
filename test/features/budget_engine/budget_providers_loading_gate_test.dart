// Unit tests for dailyBudgetSummaryProvider's loading-gate (D18/M16 bug #8).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/database/financial_goal.dart';
import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/core/database/wallet.dart';
import 'package:ledgermate/features/budget_engine/application/budget_providers.dart';
import 'package:ledgermate/features/wallets/application/wallet_providers.dart';

void main() {
  group('dailyBudgetSummaryProvider loading gate (D18/M16 bug #8)', () {
    late StreamController<LocalProfile?> profileController;
    late StreamController<PayCycle?> cycleController;
    late StreamController<List<db.Transaction>> txsController;
    late StreamController<List<FinancialGoal>> goalsController;
    late StreamController<List<Wallet>> walletsController;
    late ProviderContainer container;

    setUp(() {
      profileController = StreamController<LocalProfile?>.broadcast();
      cycleController = StreamController<PayCycle?>.broadcast();
      txsController = StreamController<List<db.Transaction>>.broadcast();
      goalsController = StreamController<List<FinancialGoal>>.broadcast();
      walletsController = StreamController<List<Wallet>>.broadcast();

      container = ProviderContainer(
        overrides: [
          budgetProfileStreamProvider.overrideWith(
            (ref) => profileController.stream,
          ),
          budgetLatestPayCycleStreamProvider.overrideWith(
            (ref) => cycleController.stream,
          ),
          budgetTransactionsStreamProvider.overrideWith(
            (ref) => txsController.stream,
          ),
          budgetGoalsStreamProvider.overrideWith(
            (ref) => goalsController.stream,
          ),
          walletsStreamProvider.overrideWith((ref) => walletsController.stream),
        ],
      );
    });

    tearDown(() {
      container.dispose();
      profileController.close();
      cycleController.close();
      txsController.close();
      goalsController.close();
      walletsController.close();
    });

    test(
      'stays in loading state until the PayCycle stream emits, even once '
      'profile/transactions/goals already have (previously only those 3 '
      'were gated, letting a wrong number compute with latestCycle=null)',
      () async {
        container.listen(dailyBudgetSummaryProvider, (_, _) {});

        final profile = LocalProfile()
          ..incomeFrequency = IncomeFrequency.periodic
          ..fixedSalary = 3000000
          ..nextPaydayDate = DateTime(2026, 11, 1)
          ..onboardingComplete = true;

        profileController.add(profile);
        txsController.add(const []);
        goalsController.add(const []);
        walletsController.add(const []);
        await Future<void>.delayed(Duration.zero);

        // PayCycle stream has NOT emitted yet — must still be loading.
        expect(
          container.read(dailyBudgetSummaryProvider),
          isA<AsyncLoading<DailyBudgetSummary>>(),
        );

        cycleController.add(null);
        await Future<void>.delayed(const Duration(milliseconds: 20));

        expect(
          container.read(dailyBudgetSummaryProvider),
          isA<AsyncData<DailyBudgetSummary>>(),
        );
      },
    );

    test('stays in loading state until the wallets stream emits, even once '
        'profile/cycle/transactions/goals already have (previously wallet '
        'scoping silently defaulted to "include everything" while wallets '
        'were still loading, producing a transiently wrong number)', () async {
      container.listen(dailyBudgetSummaryProvider, (_, _) {});

      final profile = LocalProfile()
        ..incomeFrequency = IncomeFrequency.daily
        ..carryOverBalance = 100000
        ..onboardingComplete = true;

      profileController.add(profile);
      cycleController.add(null);
      txsController.add(const []);
      goalsController.add(const []);
      await Future<void>.delayed(Duration.zero);

      expect(
        container.read(dailyBudgetSummaryProvider),
        isA<AsyncLoading<DailyBudgetSummary>>(),
      );

      walletsController.add(const []);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(
        container.read(dailyBudgetSummaryProvider),
        isA<AsyncData<DailyBudgetSummary>>(),
      );
    });
  });
}
