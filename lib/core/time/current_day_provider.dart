// D18/M17 bug #4: "Today" never advanced if the app was resumed from the
// background on a later calendar day — `dailyBudgetSummaryProvider` and
// friends only ever recomputed when one of their *data* dependencies
// (profile/transactions/goals/wallets streams) emitted, never merely
// because the wall-clock day rolled over while the app sat backgrounded
// with no new Isar writes. The UI kept showing yesterday's numbers until a
// full cold restart re-ran everything from scratch.
//
// [currentDayProvider] is the single reactive "what day is it" signal every
// date-dependent provider should `ref.watch` instead of calling
// `DateTime.now()` directly inside a `Provider` body (a plain `Provider`
// only recomputes when something it watches changes — calling
// `DateTime.now()` inline is invisible to Riverpod's dependency tracking).
// It updates via two paths:
// 1. A `Timer` scheduled for the next local midnight (self-rescheduling).
// 2. [CurrentDayNotifier.refresh], called by `app.dart`'s
//    `AppLifecycleState.resumed` listener — covers the "backgrounded over a
//    day boundary, then foregrounded" case without waiting for the timer
//    (which doesn't fire at all while the Dart isolate is suspended in the
//    background, per Flutter/OS lifecycle behavior).
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../formulas/daily_budget_formulas.dart';

/// Wall-clock source, overridable in tests so [CurrentDayNotifier] can be
/// driven deterministically instead of depending on the real system clock.
final systemClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

class CurrentDayNotifier extends Notifier<DateTime> {
  Timer? _midnightTimer;

  @override
  DateTime build() {
    ref.onDispose(() {
      _midnightTimer?.cancel();
    });
    _scheduleNextTick();
    return normalizeDate(ref.read(systemClockProvider)());
  }

  /// Re-checks the real current date and updates [state] if the calendar
  /// day has actually changed. Called by the midnight timer AND by
  /// `app.dart`'s lifecycle observer on every `AppLifecycleState.resumed`
  /// event (covers the case where the app was backgrounded across a day
  /// boundary and the timer never got to fire).
  void refresh() {
    final today = normalizeDate(ref.read(systemClockProvider)());
    if (today != state) {
      state = today;
    }
    _scheduleNextTick();
  }

  void _scheduleNextTick() {
    _midnightTimer?.cancel();
    final now = ref.read(systemClockProvider)();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    final delay = nextMidnight.difference(now);
    _midnightTimer = Timer(delay.isNegative ? Duration.zero : delay, refresh);
  }
}

/// Normalized (midnight) "today", reactive to both the midnight timer and
/// app-resume lifecycle events. Every date-dependent `Provider` (daily
/// budget summary, cycle-transition-due check, etc) should `ref.watch` this
/// instead of calling `DateTime.now()` inline.
final currentDayProvider = NotifierProvider<CurrentDayNotifier, DateTime>(
  CurrentDayNotifier.new,
);
