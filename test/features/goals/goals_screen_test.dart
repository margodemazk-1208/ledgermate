import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/theme/theme_provider.dart';
import 'package:ledgermate/features/goals/application/goals_providers.dart';
import 'package:ledgermate/features/goals/presentation/goal_form_screen.dart';
import 'package:ledgermate/features/goals/presentation/goals_screen.dart';
import 'package:ledgermate/features/goals/presentation/widgets/realism_warning_dialog.dart';
import 'package:ledgermate/features/goals/presentation/widgets/withdraw_dialog.dart';

import 'fake_goals_repository.dart';

void main() {
  late FakeGoalsRepository repository;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    repository = FakeGoalsRepository();
  });

  tearDown(() {
    repository.dispose();
  });

  Widget buildTestWidget({
    Widget? child,
    ThemeMode themeMode = ThemeMode.dark,
  }) {
    return ProviderScope(
      overrides: [goalsRepositoryProvider.overrideWithValue(repository)],
      child: Consumer(
        builder: (context, ref, _) {
          final darkTheme = ref.watch(darkThemeProvider);
          final lightTheme = ref.watch(lightThemeProvider);
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            home: child ?? const GoalsScreen(),
          );
        },
      ),
    );
  }

  group('GoalsScreen presentation (FR-06, antislop R-26, R-27)', () {
    testWidgets('renders empty state when no goals exist (R-27)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Target Tabungan'), findsOneWidget);
      expect(find.text('Belum Ada Target Tabungan'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('create_first_goal_button')),
        findsOneWidget,
      );
    });

    testWidgets('renders goals overview card and goal cards when goals exist', (
      tester,
    ) async {
      await repository.saveGoal(
        name: 'Dana Darurat',
        targetAmount: 10000000,
        currentAmount: 2500000,
        targetDate: DateTime(2027, 1, 1),
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Progres Tabungan'), findsOneWidget);
      expect(find.text('Dana Darurat'), findsOneWidget);
      expect(find.textContaining('25%'), findsWidgets);
      expect(find.byKey(const ValueKey('add_goal_fab')), findsOneWidget);
    });

    testWidgets(
      'renders both Light and Dark themes without error (R-21, R-34)',
      (tester) async {
        await repository.saveGoal(
          name: 'Liburan',
          targetAmount: 5000000,
          currentAmount: 1000000,
          targetDate: DateTime(2027, 6, 1),
        );

        // Dark Theme
        await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
        await tester.pumpAndSettle();
        expect(find.text('Liburan'), findsOneWidget);

        // Light Theme
        await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.light));
        await tester.pumpAndSettle();
        expect(find.text('Liburan'), findsOneWidget);
      },
    );

    testWidgets(
      'M19/D18: no RenderFlex overflow at 360dp width with large amounts',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await repository.saveGoal(
          name: 'Dana Darurat Keluarga Besar Jangka Panjang',
          targetAmount: 999999999999,
          currentAmount: 123456789012,
          targetDate: DateTime(2027, 1, 1),
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text('Dana Darurat Keluarga Besar Jangka Panjang'),
          findsOneWidget,
        );
      },
    );
  });

  group('GoalFormScreen (FR-06, FR-06b, BR-03)', () {
    testWidgets('creates a new goal successfully', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const GoalFormScreen()));
      await tester.pumpAndSettle();

      // Enter goal name
      await tester.enterText(
        find.byKey(const ValueKey('goal_name_field')),
        'Beli Mobil',
      );
      // Enter target amount
      await tester.enterText(
        find.byKey(const ValueKey('goal_target_amount_field')),
        '100000000',
      );
      // Enter initial amount
      await tester.enterText(
        find.byKey(const ValueKey('goal_current_amount_field')),
        '10000000',
      );

      await tester.pumpAndSettle();

      // Submit form
      await tester.tap(find.byKey(const ValueKey('save_goal_button')));
      await tester.pumpAndSettle();

      final all = await repository.getAllGoals();
      expect(all.length, 1);
      expect(all.first.goalName, 'Beli Mobil');
      expect(all.first.targetAmount, 100000000);
      expect(all.first.currentAmount, 10000000);
    });

    testWidgets('validates required fields', (tester) async {
      await tester.pumpWidget(buildTestWidget(child: const GoalFormScreen()));
      await tester.pumpAndSettle();

      // Submit empty form
      await tester.tap(find.byKey(const ValueKey('save_goal_button')));
      await tester.pumpAndSettle();

      expect(find.text('Nama target tidak boleh kosong'), findsOneWidget);
      expect(await repository.getAllGoals(), isEmpty);
    });
  });

  group('RealismWarningDialog (FR-06b, BR-03)', () {
    testWidgets('displays projected numbers and actions', (tester) async {
      RealismWarningAction? selectedAction;

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (ctx) => Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  selectedAction = await showDialog<RealismWarningAction>(
                    context: ctx,
                    builder: (_) => const RealismWarningDialog(
                      projectedUangJajanAman: -25000,
                      projectedDailyReserve: 150000,
                    ),
                  );
                },
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Target Mungkin Terlalu Berat'), findsOneWidget);
      expect(find.textContaining('Rp -25.000'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('realism_extend_date_button')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('realism_proceed_button')),
        findsOneWidget,
      );

      // Tap proceed
      await tester.tap(find.byKey(const ValueKey('realism_proceed_button')));
      await tester.pumpAndSettle();
      expect(selectedAction, RealismWarningAction.proceed);
    });
  });

  group('WithdrawDialog (FR-06c)', () {
    testWidgets('preset percentage chips set amount correctly and withdraws', (
      tester,
    ) async {
      final goal = await repository.saveGoal(
        name: 'Tabungan',
        targetAmount: 2000000,
        currentAmount: 1000000,
        targetDate: DateTime(2027, 1, 1),
      );

      await tester.pumpWidget(
        buildTestWidget(child: WithdrawDialog(goal: goal)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tarik dari Goal'), findsOneWidget);

      // Tap 50% chip -> 500,000
      await tester.tap(find.byKey(const ValueKey('withdraw_chip_50')));
      await tester.pumpAndSettle();

      // Tap "Lanjut Tarik"
      await tester.tap(find.byKey(const ValueKey('withdraw_submit_button')));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Konfirmasi Penarikan'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('withdraw_confirm_submit_button')),
      );
      await tester.pumpAndSettle();

      // Verify amount reduced in repository
      final updated = await repository.getGoalById(goal.id);
      expect(updated!.currentAmount, 500000);
    });
  });
}
