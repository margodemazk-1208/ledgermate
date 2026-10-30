// Regression test for D18/M17 bug #4: "Today" never advanced if the app
// was resumed from the background on a later calendar day — nothing
// re-checked the wall-clock date except on a full cold restart.
// `currentDayProvider` is the fix; this test drives it via the injectable
// `systemClockProvider` (no real Timer/midnight wait needed) and confirms
// both (a) the midnight-timer-equivalent recompute path and (b) the
// `refresh()` method `app.dart`'s `AppLifecycleState.resumed` listener
// calls actually update the day AND propagate to dependents.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/time/current_day_provider.dart';

void main() {
  group('currentDayProvider (D18/M17 bug #4)', () {
    test('initial value is the (normalized) current day from the clock', () {
      var fakeNow = DateTime(2026, 10, 30, 23, 59);
      final container = ProviderContainer(
        overrides: [systemClockProvider.overrideWithValue(() => fakeNow)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentDayProvider), DateTime(2026, 10, 30));
    });

    test('refresh() advances the day once the clock crosses midnight — this '
        'is exactly the call app.dart makes on AppLifecycleState.resumed', () {
      var fakeNow = DateTime(2026, 10, 30, 23, 59);
      final container = ProviderContainer(
        overrides: [systemClockProvider.overrideWithValue(() => fakeNow)],
      );
      addTearDown(container.dispose);

      expect(container.read(currentDayProvider), DateTime(2026, 10, 30));

      // Simulate the app being backgrounded across midnight, then
      // resumed the next day — the timer never fires while backgrounded,
      // so `refresh()` (the resume hook) is the only thing that can
      // catch this up.
      fakeNow = DateTime(2026, 10, 31, 0, 5);
      container.read(currentDayProvider.notifier).refresh();

      expect(container.read(currentDayProvider), DateTime(2026, 10, 31));
    });

    test('refresh() is a no-op (no rebuild) when the day has not changed', () {
      var fakeNow = DateTime(2026, 10, 30, 12, 0);
      final container = ProviderContainer(
        overrides: [systemClockProvider.overrideWithValue(() => fakeNow)],
      );
      addTearDown(container.dispose);

      var rebuildCount = 0;
      container.listen(currentDayProvider, (prev, next) => rebuildCount++);

      fakeNow = DateTime(2026, 10, 30, 18, 0); // same calendar day
      container.read(currentDayProvider.notifier).refresh();

      expect(rebuildCount, 0);
      expect(container.read(currentDayProvider), DateTime(2026, 10, 30));
    });

    test('a dependent provider watching currentDayProvider recomputes when '
        'the day rolls over, even with no other data change — this is the '
        'actual mechanism dailyBudgetSummaryProvider relies on', () {
      var fakeNow = DateTime(2026, 10, 30, 23, 59);
      final container = ProviderContainer(
        overrides: [systemClockProvider.overrideWithValue(() => fakeNow)],
      );
      addTearDown(container.dispose);

      final dependentProvider = Provider<String>((ref) {
        final day = ref.watch(currentDayProvider);
        return 'day:${day.toIso8601String()}';
      });

      final before = container.read(dependentProvider);
      expect(before, contains('2026-10-30'));

      fakeNow = DateTime(2026, 10, 31, 0, 1);
      container.read(currentDayProvider.notifier).refresh();

      final after = container.read(dependentProvider);
      expect(after, contains('2026-10-31'));
      expect(after, isNot(before));
    });
  });
}
