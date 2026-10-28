// Smoke test for the M0 skeleton: the app boots and shows the
// placeholder scaffold with the LedgerMate theme applied. Replaced by
// real feature tests from M2 onward.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ledgermate/app.dart';

void main() {
  testWidgets('LedgerMateApp renders the placeholder home screen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: LedgerMateApp()));
    await tester.pumpAndSettle();

    expect(find.text('LedgerMate'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
  });
}
