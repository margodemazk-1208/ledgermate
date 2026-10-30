import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:ledgermate/core/l10n/app_localizations.dart';
import 'package:ledgermate/core/theme/theme_provider.dart';
import 'package:ledgermate/features/analytics/application/analytics_providers.dart';
import 'package:ledgermate/features/assets/application/assets_providers.dart';
import 'package:ledgermate/features/assets/presentation/asset_form_screen.dart';
import 'package:ledgermate/features/assets/presentation/assets_screen.dart';

import '../analytics/fake_analytics_repository.dart';
import 'fake_assets_repository.dart';

void main() {
  late FakeAssetsRepository repository;

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  setUp(() {
    repository = FakeAssetsRepository();
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
        assetsRepositoryProvider.overrideWithValue(repository),
        analyticsRepositoryProvider.overrideWithValue(
          FakeAnalyticsRepository(),
        ),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final darkTheme = ref.watch(darkThemeProvider);
          final lightTheme = ref.watch(lightThemeProvider);
          return MaterialApp(
            theme: lightTheme,
            darkTheme: darkTheme,
            themeMode: themeMode,
            locale: const Locale('id'),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            // M21/Bug 1: `AssetsScreen` is now bare body content (no own
            // `Scaffold`) — wrap it here so ink effects have a `Material`
            // ancestor, matching what `AppShell` supplies in production.
            home: child == null || child is AssetsScreen
                ? Scaffold(body: child ?? const AssetsScreen())
                : child,
          );
        },
      ),
    );
  }

  group('AssetsScreen presentation (FR-10, antislop R-26, R-27)', () {
    testWidgets('renders empty state when no assets exist (R-27)', (
      tester,
    ) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Belum Ada Aset Terdaftar'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('empty_add_asset_button')),
        findsOneWidget,
      );
      // M21/Bug 1: the "+" FAB and the bottom nav bar are hoisted to
      // `AppShell` and no longer part of the bare `AssetsScreen` widget —
      // covered by `app_shell_test.dart`, not here.
    });

    testWidgets(
      'renders portfolio summary card and asset cards when assets exist',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await repository.saveAsset(
          name: 'Emas Antam 10g',
          type: 'Emas',
          purchaseValue: 10000000,
          currentValue: 12500000,
        );
        await repository.saveAsset(
          name: 'Saham BBCA',
          type: 'Saham',
          purchaseValue: 5000000,
          currentValue: 4500000,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(find.text('Total Portofolio Aset'), findsOneWidget);
        expect(find.text('2 Aset'), findsOneWidget);
        expect(find.text('Emas Antam 10g'), findsOneWidget);
        expect(find.text('Saham BBCA'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('total_assets_value')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'M19/D18: no RenderFlex overflow at 360dp width with a large gain/loss',
      (tester) async {
        tester.view.physicalSize = const Size(360, 800);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await repository.saveAsset(
          name: 'Reksadana Saham Agresif Jangka Panjang',
          type: 'Reksadana',
          purchaseValue: 50000000,
          currentValue: 987654321,
        );

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(
          find.text('Reksadana Saham Agresif Jangka Panjang'),
          findsOneWidget,
        );
      },
    );

    testWidgets('UpdateValueDialog updates asset current value successfully', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final asset = await repository.saveAsset(
        name: 'Emas Antam',
        type: 'Emas',
        purchaseValue: 10000000,
        currentValue: 11000000,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap Update Nilai button on AssetCard
      final updateButton = find.byKey(
        ValueKey('update_value_button_${asset.id}'),
      );
      expect(updateButton, findsOneWidget);
      await tester.tap(updateButton);
      await tester.pumpAndSettle();

      // Dialog appears
      expect(find.text('Update Nilai Aset'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('update_asset_value_input')),
        findsOneWidget,
      );

      // Enter new value: 13,000,000
      await tester.enterText(
        find.byKey(const ValueKey('update_asset_value_input')),
        '13000000',
      );
      await tester.pumpAndSettle();

      // Tap simpan
      await tester.tap(find.byKey(const ValueKey('save_update_value_button')));
      await tester.pumpAndSettle();

      // Verify repository updated
      final updated = await repository.getAssetById(asset.id);
      expect(updated!.currentValue, 13000000);
    });

    testWidgets('Delete asset confirms and removes asset from list', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final asset = await repository.saveAsset(
        name: 'Kripto Lama',
        type: 'Kripto',
        purchaseValue: 2000000,
        currentValue: 1000000,
      );

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Tap delete button
      await tester.tap(find.byKey(ValueKey('delete_asset_button_${asset.id}')));
      await tester.pumpAndSettle();

      // Confirm dialog appears
      expect(find.text('Hapus Aset?'), findsOneWidget);
      await tester.tap(
        find.byKey(const ValueKey('delete_asset_confirm_button')),
      );
      await tester.pumpAndSettle();

      // Verify asset removed
      expect(find.text('Kripto Lama'), findsNothing);
      expect(find.text('Belum Ada Aset Terdaftar'), findsOneWidget);
    });

    testWidgets(
      'Light and Dark themes render without error (antislop R-21, R-34)',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await repository.saveAsset(
          name: 'Reksadana Saham Favorit',
          type: 'Reksadana',
          purchaseValue: 1000000,
          currentValue: 1200000,
        );

        // Dark theme
        await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.dark));
        await tester.pumpAndSettle();
        expect(find.text('Reksadana Saham Favorit'), findsOneWidget);

        // Light theme
        await tester.pumpWidget(buildTestWidget(themeMode: ThemeMode.light));
        await tester.pumpAndSettle();
        expect(find.text('Reksadana Saham Favorit'), findsOneWidget);
      },
    );
  });

  group('AssetFormScreen (FR-10, DECISIONS.md D8)', () {
    testWidgets(
      'creates a new asset successfully with live gain/loss preview',
      (tester) async {
        tester.view.physicalSize = const Size(800, 1600);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() => tester.view.resetPhysicalSize());

        await tester.pumpWidget(
          buildTestWidget(child: const AssetFormScreen()),
        );
        await tester.pumpAndSettle();

        expect(find.widgetWithText(AppBar, 'Tambah Aset'), findsOneWidget);

        // Fill Form
        await tester.enterText(
          find.byKey(const ValueKey('asset_name_input')),
          'Emas Batangan',
        );
        await tester.enterText(
          find.byKey(const ValueKey('asset_type_input')),
          'Emas',
        );
        await tester.enterText(
          find.byKey(const ValueKey('asset_purchase_value_input')),
          '10000000',
        );
        await tester.enterText(
          find.byKey(const ValueKey('asset_current_value_input')),
          '12000000',
        );
        await tester.pumpAndSettle();

        // Gain loss preview card visible
        expect(
          find.byKey(const ValueKey('gain_loss_preview_card')),
          findsOneWidget,
        );

        // Save
        await tester.tap(find.byKey(const ValueKey('save_asset_button')));
        await tester.pumpAndSettle();

        final assets = await repository.getAssets();
        expect(assets.length, 1);
        expect(assets.first.assetName, 'Emas Batangan');
        expect(assets.first.purchaseValue, 10000000);
        expect(assets.first.currentValue, 12000000);
      },
    );

    testWidgets('validates required fields in AssetFormScreen', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(buildTestWidget(child: const AssetFormScreen()));
      await tester.pumpAndSettle();

      // Tap save without filling
      await tester.tap(find.byKey(const ValueKey('save_asset_button')));
      await tester.pumpAndSettle();

      expect(find.text('Nama aset tidak boleh kosong.'), findsOneWidget);
      expect(find.text('Tipe aset tidak boleh kosong.'), findsOneWidget);
    });

    // "bottom navigation bar navigates to Analytics" used to live here, but
    // M18 (D18 perf item 5) moved tab-switch handling out of each
    // standalone screen and into the persistent `AppShell`/`AppBottomNav`
    // pair (`AppBottomNav` now only mutates `currentTabIndexProvider`,
    // relying on `AppShell` to react to it — a bare `AssetsScreen` pumped
    // without an `AppShell` ancestor has nothing listening for that
    // change). That behavior, plus the back-button and slide-transition
    // guarantees, is now covered end-to-end by
    // `test/core/presentation/navigation/app_shell_test.dart`.
  });
}
