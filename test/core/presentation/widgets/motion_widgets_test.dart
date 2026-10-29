// Widget tests for M14 motion primitives (`docs/DESIGN.md` §Motion).
//
// These exercise the actual production widgets through real state
// transitions (old value -> new value, pointer down -> up, mount of a new
// key) rather than merely asserting an `AnimationController` exists unused,
// per the M14 task's verification requirement.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/presentation/navigation/slide_page_route.dart';
import 'package:ledgermate/core/presentation/widgets/animated_progress_bar.dart';
import 'package:ledgermate/core/presentation/widgets/count_up_rupiah.dart';
import 'package:ledgermate/core/presentation/widgets/press_scale.dart';
import 'package:ledgermate/core/presentation/widgets/slide_fade_in_once.dart';
import 'package:ledgermate/core/presentation/widgets/success_toast.dart';

/// Wraps [child] in a MaterialApp whose ambient MediaQuery can force
/// `disableAnimations`, via the `builder` trick (a bare `MediaQuery` placed
/// ABOVE `MaterialApp` would be overridden by `WidgetsApp`'s own
/// view-derived MediaQuery).
Widget _harness(Widget child, {bool disableAnimations = false}) {
  return MaterialApp(
    builder: (context, app) {
      return MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(disableAnimations: disableAnimations),
        child: app!,
      );
    },
    home: child,
  );
}

void main() {
  group('CountUpRupiah (§Motion touchpoint 2)', () {
    testWidgets('shows the value immediately on first mount (no animation)', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          const Scaffold(
            body: CountUpRupiah(textKey: ValueKey('amount'), value: 150000),
          ),
        ),
      );
      await tester.pump();

      final text = tester.widget<Text>(find.byKey(const ValueKey('amount')));
      expect(text.data, 'Rp 150.000');
    });

    testWidgets(
      'counts through real intermediate values on change, not a jump',
      (tester) async {
        final valueNotifier = ValueNotifier<int>(100000);
        await tester.pumpWidget(
          _harness(
            Scaffold(
              body: ValueListenableBuilder<int>(
                valueListenable: valueNotifier,
                builder: (context, value, _) => CountUpRupiah(
                  textKey: const ValueKey('amount'),
                  value: value,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('amount'))).data,
          'Rp 100.000',
        );

        // Trigger a change and sample mid-flight.
        valueNotifier.value = 700000;
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300)); // ~halfway

        final midText = tester
            .widget<Text>(find.byKey(const ValueKey('amount')))
            .data;
        final midAmount = int.parse(midText!.replaceAll(RegExp(r'[^0-9]'), ''));
        expect(
          midAmount,
          greaterThan(100000),
          reason: 'should have counted up from the old value',
        );
        expect(
          midAmount,
          lessThan(700000),
          reason: 'should not have jumped straight to the new value',
        );

        await tester.pumpAndSettle();
        expect(
          tester.widget<Text>(find.byKey(const ValueKey('amount'))).data,
          'Rp 700.000',
        );
      },
    );

    testWidgets('disableAnimations collapses the count-up to one frame', (
      tester,
    ) async {
      final valueNotifier = ValueNotifier<int>(100000);
      await tester.pumpWidget(
        _harness(
          Scaffold(
            body: ValueListenableBuilder<int>(
              valueListenable: valueNotifier,
              builder: (context, value, _) => CountUpRupiah(
                textKey: const ValueKey('amount'),
                value: value,
              ),
            ),
          ),
          disableAnimations: true,
        ),
      );
      await tester.pumpAndSettle();

      valueNotifier.value = 999000;
      // Rebuild once so the TweenAnimationBuilder's internal controller
      // starts (at its own t=0), then advance well past the collapsed
      // ~1ms duration so it has time to actually report completion.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 20));

      expect(
        tester.widget<Text>(find.byKey(const ValueKey('amount'))).data,
        'Rp 999.000',
      );
    });
  });

  group('AnimatedProgressBar (§Motion touchpoint 7)', () {
    testWidgets('animates width from old % to new %, not an instant jump', (
      tester,
    ) async {
      final valueNotifier = ValueNotifier<double>(0.2);
      await tester.pumpWidget(
        _harness(
          Scaffold(
            body: ValueListenableBuilder<double>(
              valueListenable: valueNotifier,
              builder: (context, value, _) => AnimatedProgressBar(
                key: const ValueKey('bar'),
                value: value,
                valueColor: Colors.green,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        closeTo(0.2, 0.01),
      );

      valueNotifier.value = 0.8;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200)); // mid-flight

      final midValue = tester
          .widget<LinearProgressIndicator>(find.byType(LinearProgressIndicator))
          .value!;
      expect(midValue, greaterThan(0.2));
      expect(midValue, lessThan(0.8));

      await tester.pumpAndSettle();
      expect(
        tester
            .widget<LinearProgressIndicator>(
              find.byType(LinearProgressIndicator),
            )
            .value,
        closeTo(0.8, 0.01),
      );
    });
  });

  group('PressScale (§Motion touchpoint 5)', () {
    testWidgets('scales down on press and springs back on release', (
      tester,
    ) async {
      var tapped = false;
      await tester.pumpWidget(
        _harness(
          Scaffold(
            body: PressScale(
              child: ElevatedButton(
                key: const ValueKey('btn'),
                onPressed: () => tapped = true,
                child: const Text('Simpan'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final scaleFinder = find.byType(AnimatedScale);
      expect(
        tester.widget<AnimatedScale>(scaleFinder).scale,
        1.0,
        reason: 'at rest, not scaled down',
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('btn'))),
      );
      await tester.pump();
      expect(tester.widget<AnimatedScale>(scaleFinder).scale, 0.96);

      await gesture.up();
      await tester.pump();
      expect(tester.widget<AnimatedScale>(scaleFinder).scale, 1.0);

      // The wrapped button's own tap semantics still fire normally.
      await tester.tap(find.byKey(const ValueKey('btn')));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('disabled PressScale does not scale on press', (tester) async {
      await tester.pumpWidget(
        _harness(
          Scaffold(
            body: PressScale(
              enabled: false,
              child: ElevatedButton(
                key: const ValueKey('btn'),
                onPressed: () {},
                child: const Text('Simpan'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final gesture = await tester.startGesture(
        tester.getCenter(find.byKey(const ValueKey('btn'))),
      );
      await tester.pump();
      expect(
        tester.widget<AnimatedScale>(find.byType(AnimatedScale)).scale,
        1.0,
      );
      await gesture.up();
    });
  });

  group('SlideFadeInOnce (§Motion touchpoint 3)', () {
    testWidgets('a newly-mounted item slides/fades in over time', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          const Scaffold(
            body: SlideFadeInOnce(
              key: ValueKey('item-1'),
              child: Text('New item'),
            ),
          ),
        ),
      );
      await tester.pump(); // first frame, animation just started

      final opacityFinder = find.byType(Opacity);
      final initialOpacity = tester.widget<Opacity>(opacityFinder).opacity;
      expect(
        initialOpacity,
        lessThan(1.0),
        reason: 'should still be fading in on the very first frame',
      );

      await tester.pumpAndSettle();
      expect(tester.widget<Opacity>(opacityFinder).opacity, 1.0);
    });

    testWidgets(
      'an EXISTING item (same key) does not re-animate on unrelated rebuilds',
      (tester) async {
        final rebuildNotifier = ValueNotifier<int>(0);
        Widget buildTree() => _harness(
          Scaffold(
            body: ValueListenableBuilder<int>(
              valueListenable: rebuildNotifier,
              builder: (context, _, _) => const SlideFadeInOnce(
                key: ValueKey('stable-item'),
                child: Text('Existing item'),
              ),
            ),
          ),
        );

        await tester.pumpWidget(buildTree());
        await tester.pumpAndSettle();
        expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1.0);

        // Unrelated rebuild — same key/State, must NOT restart the fade.
        rebuildNotifier.value = 1;
        await tester.pump();
        expect(
          tester.widget<Opacity>(find.byType(Opacity)).opacity,
          1.0,
          reason:
              'existing item keeps its settled state; only a genuinely '
              'new item (new key/State) plays the slide-fade-in',
        );
      },
    );
  });

  group('SlidePageRoute (§Motion touchpoint 1)', () {
    testWidgets(
      'push slides the new screen in rather than appearing instantly',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  key: const ValueKey('go'),
                  onPressed: () => Navigator.of(context).push(
                    SlidePageRoute(
                      builder: (_) =>
                          const Scaffold(body: Text('Second screen')),
                    ),
                  ),
                  child: const Text('Go'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('go')));
        await tester.pump(); // start the push transition
        await tester.pump(const Duration(milliseconds: 50)); // mid-flight

        // Checking the rendered global position (rather than reaching into
        // a specific `SlideTransition` instance — a push transiently
        // mounts several, for both the exiting and entering route) proves
        // the incoming screen is still animating into place, not an
        // instant swap.
        final midPosition = tester.getTopLeft(find.text('Second screen'));
        expect(
          midPosition.dx,
          greaterThan(0),
          reason:
              'mid-transition the incoming screen should still be offset '
              'off to the right, not already at its resting x=0',
        );

        await tester.pumpAndSettle();
        final restingPosition = tester.getTopLeft(find.text('Second screen'));
        expect(restingPosition.dx, 0);
      },
    );

    testWidgets('disableAnimations collapses the push to (near) instant', (
      tester,
    ) async {
      await tester.pumpWidget(
        _harness(
          Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                key: const ValueKey('go'),
                onPressed: () => Navigator.of(context).push(
                  SlidePageRoute(
                    builder: (_) => const Scaffold(body: Text('Second screen')),
                  ),
                ),
                child: const Text('Go'),
              ),
            ),
          ),
          disableAnimations: true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const ValueKey('go')));
      // A short pump should already land on the destination screen since
      // the transition duration collapsed to ~1ms.
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 20));

      expect(find.text('Second screen'), findsOneWidget);
    });
  });

  group('Save success toast (§Motion touchpoint 8)', () {
    testWidgets(
      'shows a crafted checkmark toast (not a SnackBar) and auto-dismisses',
      (tester) async {
        await tester.pumpWidget(
          _harness(
            Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  key: const ValueKey('save'),
                  onPressed: () =>
                      showSuccessToast(context, 'Tersimpan dengan sukses'),
                  child: const Text('Simpan'),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byKey(const ValueKey('save')));
        await tester.pump();

        expect(find.text('Tersimpan dengan sukses'), findsOneWidget);
        expect(find.byType(SnackBar), findsNothing);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // Runs the full in -> hold -> out cycle and removes itself.
        await tester.pumpAndSettle(const Duration(milliseconds: 100));
        expect(find.text('Tersimpan dengan sukses'), findsNothing);
      },
    );
  });
}
