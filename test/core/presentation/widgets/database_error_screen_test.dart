// Regression test for D18/M17 bug #6's user-facing side: when `Isar.open`
// fails at boot, the app now shows `DatabaseErrorScreen` with a retry
// button instead of `main.dart` leaving a blank/broken screen.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/presentation/widgets/database_error_screen.dart';

void main() {
  testWidgets('shows an error message, not a blank screen', (tester) async {
    await tester.pumpWidget(
      DatabaseErrorScreen(error: Exception('disk corrupted')),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('database_error_title')), findsOneWidget);
    expect(find.textContaining('Gagal Memuat Data Lokal'), findsOneWidget);
    expect(find.byKey(const ValueKey('database_error_detail')), findsOneWidget);
  });

  testWidgets('retry button is real — tapping it invokes onRetry', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      DatabaseErrorScreen(
        error: Exception('disk corrupted'),
        onRetry: () => retried = true,
      ),
    );
    await tester.pumpAndSettle();

    final retryButton = find.byKey(
      const ValueKey('database_error_retry_button'),
    );
    expect(retryButton, findsOneWidget);

    await tester.tap(retryButton);
    await tester.pumpAndSettle();

    expect(retried, isTrue);
  });

  testWidgets('omits the retry button entirely when onRetry is null', (
    tester,
  ) async {
    await tester.pumpWidget(const DatabaseErrorScreen(error: null));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('database_error_retry_button')),
      findsNothing,
    );
  });

  testWidgets('renders correctly without a crash in both themes (R-21/R-34)', (
    tester,
  ) async {
    // DatabaseErrorScreen wraps its own MaterialApp with dark+light themes
    // wired (no ProviderScope/persisted theme exists yet at this point in
    // boot) — just confirm pumping it never throws.
    await tester.pumpWidget(DatabaseErrorScreen(error: Exception('x')));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
