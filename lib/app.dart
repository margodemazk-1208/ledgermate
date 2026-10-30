import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_localizations.dart';
import 'core/presentation/navigation/app_shell.dart';
import 'core/theme/theme_provider.dart';
import 'core/time/current_day_provider.dart';
import 'features/onboarding/application/onboarding_providers.dart';
import 'features/onboarding/presentation/onboarding_screen.dart';
import 'features/settings/application/settings_providers.dart';

/// Root widget: MaterialApp + theme wiring. M2 adds the boot-time
/// Onboarding/Home gate (FR-01: "Wajib selesai sebelum masuk Home") —
/// `main.dart` opens Isar before `runApp`, so `isarProvider` is always
/// available once this widget builds.
class LedgerMateApp extends ConsumerWidget {
  const LedgerMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final appLocale = ref.watch(appLocaleProvider);
    return MaterialApp(
      title: 'LedgerMate',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: ref.watch(lightThemeProvider),
      darkTheme: ref.watch(darkThemeProvider),
      locale: appLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const _DayRolloverObserver(child: _OnboardingGate()),
    );
  }
}

/// D18/M17 bug #4: "Today" never advanced if the app was resumed from the
/// background on a later calendar day — nothing previously re-checked the
/// wall-clock date on resume, only on a full cold restart. Wraps the whole
/// app body and forwards every `AppLifecycleState.resumed` event into
/// `currentDayProvider`'s notifier, which every date-dependent provider
/// (daily budget summary, cycle-transition-due check, etc) watches instead
/// of calling `DateTime.now()` inline — see `core/time/current_day_provider.dart`.
class _DayRolloverObserver extends ConsumerStatefulWidget {
  const _DayRolloverObserver({required this.child});

  final Widget child;

  @override
  ConsumerState<_DayRolloverObserver> createState() =>
      _DayRolloverObserverState();
}

class _DayRolloverObserverState extends ConsumerState<_DayRolloverObserver>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.read(currentDayProvider.notifier).refresh();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Routes to Onboarding while incomplete, BudgetHomeScreen once done.
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
          isComplete ? const AppShell() : const OnboardingScreen(),
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, stackTrace) => Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Builder(
              builder: (context) => Text(
                AppLocalizations.of(context)!
                    .appRootDataLoadErrorMessage(error),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
