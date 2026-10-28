import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme_provider.dart';
import 'features/budget_engine/presentation/budget_home_screen.dart';
import 'features/onboarding/application/onboarding_providers.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';

/// Root widget: MaterialApp + theme wiring. M2 adds the boot-time
/// Onboarding/Home gate (FR-01: "Wajib selesai sebelum masuk Home") —
/// `main.dart` opens Isar before `runApp`, so `isarProvider` is always
/// available once this widget builds.
class LedgerMateApp extends ConsumerWidget {
  const LedgerMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    return MaterialApp(
      title: 'LedgerMate',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      // ID/EN dwibahasa per FR-09; full .arb-backed l10n lands in M10 —
      // this just proves the delegates wire up without errors in M0.
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('id'), Locale('en')],
      home: const _OnboardingGate(),
    );
  }
}

/// Routes to Onboarding while incomplete, Home placeholder once done.
/// Also covers the loading/error states around the first Isar read
/// (antislop R-27 — every data-backed screen needs these, including the
/// very first one at boot).
class _OnboardingGate extends ConsumerWidget {
  const _OnboardingGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardingComplete = ref.watch(onboardingCompleteProvider);
    return onboardingComplete.when(
      data: (isComplete) =>
          isComplete ? const BudgetHomeScreen() : const OnboardingScreen(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Gagal memuat data: $error'),
          ),
        ),
      ),
    );
  }
}
