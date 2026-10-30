// M18 Performance Optimization (docs/ROADMAP.md M18, item 5): the
// persistent bottom-nav shell. Pre-M18, `AppBottomNav._navigate` drove tab
// switches via `Navigator.push`/`pushReplacement`/`pushAndRemoveUntil`,
// which tore down and fully rebuilt the destination tab's widget tree
// (losing scroll position, the Transaksi filter selection, in-flight
// animations, etc) on every single switch, AND silently broke the
// Android back-button contract: switching Home -> Transaksi used
// `pushReplacement`, which REMOVES Home from the navigation stack, so
// pressing back from Transaksi had nothing left to pop to and exited the
// app instead of returning to Home.
//
// `AppShell` keeps all 6 tabs mounted simultaneously (`Offstage` for the
// inactive ones, with a structurally-identical `SlideTransition` wrapper
// kept on EVERY tab at all times — see the per-slot comment in `build()`
// for why that consistency matters) — this is what actually preserves
// their state, matching `IndexedStack`'s guarantee, while still
// reproducing the M14-mandated horizontal slide transition
// (`docs/DESIGN.md` §Motion touchpoint 1) between the outgoing/incoming
// tab with the SAME direction-aware logic `AppBottomNav` already had.
// `PopScope` makes the back button return to Home from any other tab
// instead of exiting the app, matching standard Android app-shell
// expectations.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../motion/motion_durations.dart';
import '../../../features/analytics/presentation/analytics_screen.dart';
import '../../../features/assets/presentation/assets_screen.dart';
import '../../../features/budget_engine/presentation/budget_home_screen.dart';
import '../../../features/goals/presentation/goals_screen.dart';
import '../../../features/settings/presentation/settings_screen.dart';
import '../../../features/transactions/presentation/transactions_screen.dart';

/// Which of the 6 bottom-nav tabs is currently visible. Mutated by
/// [AppBottomNav] taps and by any in-app deep link that wants to switch
/// tabs (e.g. Home's "Lihat Selengkapnya" row) instead of pushing a
/// duplicate, independently-provider-watching instance of the destination
/// screen on top of the shell.
class CurrentTabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) => state = index;
}

final currentTabIndexProvider = NotifierProvider<CurrentTabIndexNotifier, int>(
  CurrentTabIndexNotifier.new,
);

/// The 6 main tabs, in bottom-nav order. `const` so the SAME widget
/// instances are reused across every `AppShell` rebuild — combined with
/// `Offstage` (not removal from the tree), this is what lets Flutter's
/// element-reuse keep each tab's `State` (scroll offsets, the Transaksi
/// type filter, in-flight Isar stream subscriptions) alive across tab
/// switches instead of disposing and recreating it.
const _tabs = <Widget>[
  BudgetHomeScreen(),
  TransactionsScreen(),
  GoalsScreen(),
  AssetsScreen(),
  AnalyticsScreen(),
  SettingsScreen(),
];

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _currentIndex = 0;
  int? _previousIndex;
  bool _fromLeft = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: MotionDurations.navigation,
          value: 1,
        )..addStatusListener((status) {
          // Transition finished — the outgoing tab can go back to a plain
          // `Offstage` (cheaper than an off-screen `SlideTransition`) until
          // the next switch.
          if (status == AnimationStatus.completed && mounted) {
            setState(() => _previousIndex = null);
          }
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleIndexChange(int newIndex) {
    if (newIndex == _currentIndex) return;
    setState(() {
      _previousIndex = _currentIndex;
      _fromLeft = newIndex < _currentIndex;
      _currentIndex = newIndex;
    });
    _controller
      ..duration = motionDuration(context, MotionDurations.navigation)
      ..value = 0
      ..forward();
  }

  @override
  Widget build(BuildContext context) {
    // Fires on every FUTURE tab-index change (AppBottomNav taps, or a deep
    // link like Home's "Lihat Selengkapnya") — not for the current value,
    // so this never fights with `_currentIndex`'s own initial value.
    ref.listen<int>(currentTabIndexProvider, (previous, next) {
      _handleIndexChange(next);
    });

    return PopScope(
      // D18/M18 item 5: only let the system back gesture actually pop (and
      // exit the app, Home being the shell's root) when already on Home —
      // from any other tab, intercept it and return to Home instead.
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        ref.read(currentTabIndexProvider.notifier).setIndex(0);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          for (var i = 0; i < _tabs.length; i++)
            // Every slot keeps the EXACT SAME widget-tree shape
            // (Offstage -> SlideTransition -> tab) on every single build,
            // with only `offstage`/`position` varying — this is what
            // actually preserves each tab's Element/State (scroll
            // offsets, filters, in-flight Isar subscriptions) across a
            // switch. An earlier version of this fix swapped between a
            // bare `KeyedSubtree` wrapper for the active/previous tabs and
            // an `Offstage` wrapper for the rest: since those are
            // DIFFERENT widget types at the same Stack position, Flutter's
            // reconciliation discarded and recreated the Element the
            // moment a tab's wrapper type changed — silently defeating
            // the whole point of this milestone item. Keeping one
            // consistent wrapper type per slot, always, is required for
            // `canUpdate` to actually reuse the Element.
            Offstage(
              key: ValueKey('app_shell_tab_$i'),
              offstage: i != _currentIndex && i != _previousIndex,
              child: SlideTransition(
                position: _offsetAnimationFor(i),
                child: _tabs[i],
              ),
            ),
        ],
      ),
    );
  }

  /// The horizontal slide offset animation for tab [index]. Only the
  /// currently-entering/exiting pair gets a moving `Tween`; every other
  /// tab (including the settled current tab outside of a transition)
  /// gets a constant zero-offset `Animation` — cheap, and critically the
  /// SAME `SlideTransition` widget type/shape as the animated case, so no
  /// slot's child subtree is ever rebuilt by a type change (see [build]'s
  /// comment).
  Animation<Offset> _offsetAnimationFor(int index) {
    if (_previousIndex == null ||
        (index != _currentIndex && index != _previousIndex)) {
      return const AlwaysStoppedAnimation<Offset>(Offset.zero);
    }

    final isEntering = index == _currentIndex;
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final beginOffset = _fromLeft ? const Offset(-1, 0) : const Offset(1, 0);
    final exitOffset = _fromLeft ? const Offset(1, 0) : const Offset(-1, 0);
    final tween = isEntering
        ? Tween<Offset>(begin: beginOffset, end: Offset.zero)
        : Tween<Offset>(begin: Offset.zero, end: exitOffset);

    return tween.animate(curved);
  }
}
