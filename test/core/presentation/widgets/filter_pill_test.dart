// M19/D18: FilterPill's tap target must meet the 48dp Material minimum
// even though its visible pill stays compact per the mockup — the outer
// hit-test area (SizedBox+InkWell) is what's asserted here, not just the
// visual chip size. See filter_pill.dart's doc comment for the rationale.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/presentation/widgets/filter_pill.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(body: Center(child: child)),
  );

  testWidgets('FilterPill tap target height meets the 48dp a11y minimum', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(
        FilterPill(
          key: const ValueKey('test_pill'),
          label: 'Mingguan',
          selected: false,
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final size = tester.getSize(find.byKey(const ValueKey('test_pill')));
    expect(
      size.height,
      greaterThanOrEqualTo(48),
      reason:
          'FilterPill tap target must be >=48dp tall per Material a11y '
          'guidance (antislop R-35: measured, not eyeballed). Got '
          '${size.height}dp.',
    );
  });

  testWidgets('tapping anywhere in the 48dp target (not just the visible '
      'pill) triggers onTap', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      wrap(
        FilterPill(
          key: const ValueKey('test_pill'),
          label: 'Mingguan',
          selected: false,
          onTap: () => tapped = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap the top-left corner of the 48dp box, away from the visually
    // smaller centered pill, to prove the full area is tappable.
    final topLeft = tester.getTopLeft(find.byKey(const ValueKey('test_pill')));
    await tester.tapAt(topLeft + const Offset(2, 2));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('selected/unselected visuals are unchanged by the tap-target '
      'fix', (tester) async {
    await tester.pumpWidget(
      wrap(const FilterPill(label: 'Bulanan', selected: true)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Bulanan'), findsOneWidget);
    final container = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, isNotNull); // burgundy fill when selected
  });
}
