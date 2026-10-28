import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/theme_provider.dart';
import 'features/onboarding/presentation/placeholder_home_screen.dart';

/// Root widget: MaterialApp + theme wiring. Router and real screens land
/// in M2+; M0 only proves the skeleton + both themes render cleanly.
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
      home: const PlaceholderHomeScreen(),
    );
  }
}
