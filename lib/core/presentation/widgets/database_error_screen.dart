// D18/M17 bug #6: shown instead of a blank screen when `Isar.open`/the M12
// migration throws during boot (corrupted DB file on disk, interrupted
// write, out-of-space, etc). There is no `ProviderScope`/persisted
// theme/locale yet at this point in boot (this runs BEFORE any of that is
// known to even be readable), so this screen wraps its own minimal
// `MaterialApp` using the dark theme directly (PRD default) rather than
// depending on `core/theme/theme_provider.dart`.
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../theme/app_typography.dart';

/// Full-app replacement UI for an unrecoverable local-database boot failure.
/// [onRetry] re-attempts the boot sequence (re-opening Isar) — real callers
/// wire this to `main.dart`'s boot function so the user can retry without
/// force-closing the app (e.g. after freeing storage space).
class DatabaseErrorScreen extends StatelessWidget {
  const DatabaseErrorScreen({super.key, required this.error, this.onRetry});

  final Object? error;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LedgerMate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      // No persisted LocalProfile is readable yet at this point in boot
      // (see file header) — pin Indonesian (PRD default) explicitly rather
      // than silently falling back to the test/device's en_US locale.
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final l10n = AppLocalizations.of(context)!;
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.storage_outlined,
                        size: 56,
                        color: AppColors.expenseRed,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        l10n.databaseErrorScreenTitle,
                        key: const ValueKey('database_error_title'),
                        textAlign: TextAlign.center,
                        style: AppTypography.script(fontSize: 22),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        l10n.databaseErrorScreenDescription,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.databaseErrorScreenSuggestion,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (error != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          key: const ValueKey('database_error_detail'),
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(context).dividerColor,
                            ),
                          ),
                          child: Text(
                            error.toString(),
                            style: AppTypography.mono(fontSize: 11),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                      if (onRetry != null)
                        FilledButton.icon(
                          key: const ValueKey('database_error_retry_button'),
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.databaseErrorScreenRetryButton),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
