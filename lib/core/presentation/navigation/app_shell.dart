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
//
// M21/Bug 1: pre-M21, each of the 6 tabs was its OWN `Scaffold` with its
// OWN `appBar:`/`bottomNavigationBar:` INSIDE it, and `AppShell` wrapped
// that entire Scaffold+chrome tree in the `SlideTransition` above — so
// switching tabs visually slid the bottom nav and top app bar along with
// the body content, when only the body should move. `AppShell` is now
// the ONE `Scaffold` for the whole app: it owns a single persistent
// `bottomNavigationBar` and a single persistent `appBar` (same
// container/height/color/elevation on every tab — only the title TEXT and
// action icons crossfade per tab, never sliding), and the `Offstage` +
// `SlideTransition` mechanism below wraps ONLY the per-tab bare body
// content. Each of the 6 screen widgets is now bare body content with no
// `Scaffold`/`appBar`/`bottomNavigationBar`/`floatingActionButton` of its
// own — their former per-tab FABs are hoisted here too, swapped per active
// tab via `Scaffold`'s own built-in FAB transition (scale+fade, not a
// slide).
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';
import '../../motion/motion_durations.dart';
import '../../theme/app_typography.dart';
import '../../theme/theme_provider.dart';
import '../../../features/analytics/presentation/analytics_screen.dart';
import '../../../features/assets/presentation/asset_form_screen.dart';
import '../../../features/assets/presentation/assets_screen.dart';
import '../../../features/budget_engine/presentation/budget_home_screen.dart';
import '../../../features/goals/presentation/goal_form_screen.dart';
import '../../../features/goals/presentation/goals_screen.dart';
import '../../../features/settings/presentation/settings_screen.dart';
import '../../../features/transactions/presentation/transaction_form_screen.dart';
import '../../../features/transactions/presentation/transactions_screen.dart';
import '../widgets/app_bottom_nav.dart';
import '../widgets/fab_speed_dial.dart';
import 'slide_page_route.dart';

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

/// The 6 main tabs' BARE body content, in bottom-nav order. `const` so the
/// SAME widget instances are reused across every `AppShell` rebuild —
/// combined with `Offstage` (not removal from the tree), this is what lets
/// Flutter's element-reuse keep each tab's `State` (scroll offsets, the
/// Transaksi type filter, in-flight Isar stream subscriptions) alive
/// across tab switches instead of disposing and recreating it.
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
      child: Scaffold(
        appBar: _buildAppBar(context),
        body: Stack(
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
        // M21/Bug 1: a single persistent bottom nav — reads
        // `currentTabIndexProvider` itself (no `currentIndex` constructor
        // arg), so this exact widget instance never needs replacing on a
        // tab switch and its on-screen position never moves.
        bottomNavigationBar: const AppBottomNav(),
        floatingActionButton: _buildFab(context),
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

  /// M21/Bug 1: ONE static `AppBar` container (same height/color/elevation
  /// on every tab) whose title TEXT and action icons crossfade per active
  /// tab, instead of the whole bar sliding with the body. No tab shows a
  /// leading back arrow — these are shell-root tabs, not pushed routes.
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final fadeDuration = motionDuration(context, MotionDurations.navigation);

    Widget crossFade(Widget child, {required String keyPrefix}) {
      return AnimatedSwitcher(
        duration: fadeDuration,
        transitionBuilder: (child, animation) =>
            FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(
          key: ValueKey('${keyPrefix}_$_currentIndex'),
          child: child,
        ),
      );
    }

    return AppBar(
      key: const ValueKey('app_shell_app_bar'),
      automaticallyImplyLeading: false,
      title: crossFade(_titleFor(context, theme, l10n), keyPrefix: 'title'),
      actions: [
        crossFade(_actionsFor(context, theme, l10n), keyPrefix: 'actions'),
      ],
    );
  }

  Widget _titleFor(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    switch (_currentIndex) {
      case 0:
        return Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text('LedgerMate', style: AppTypography.script(fontSize: 22)),
            const SizedBox(width: 8),
            // M19/D18: at 360dp width, "LedgerMate" + the longest Indonesian
            // weekday names (e.g. "Jumat", "Minggu") together overflowed the
            // title Row — Flexible+ellipsis lets the date clip gracefully
            // instead, since the brand wordmark is the priority element.
            Flexible(
              child: Text(
                DateFormat('EEEE: dd-MMM-yy', 'id_ID').format(DateTime.now()),
                style: AppTypography.mono(
                  fontSize: 11,
                  color: theme.textTheme.bodySmall?.color,
                  letterSpacing: 0.5,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        );
      case 1:
        return Text(
          l10n.transactionsScreenTitle,
          style: AppTypography.script(fontSize: 20),
        );
      case 2:
        return Text(
          l10n.goalsScreenTitle,
          style: AppTypography.script(fontSize: 20),
        );
      case 3:
        return Text(
          l10n.assetsScreenTitle,
          style: AppTypography.script(fontSize: 20),
        );
      case 4:
        return Text(
          l10n.analyticsScreenTitle,
          style: AppTypography.script(fontSize: 18),
        );
      case 5:
      default:
        return Text(
          l10n.settingsScreenTitle,
          style: AppTypography.script(fontSize: 20),
        );
    }
  }

  Widget _actionsFor(
    BuildContext context,
    ThemeData theme,
    AppLocalizations l10n,
  ) {
    switch (_currentIndex) {
      case 3:
        return IconButton(
          key: const ValueKey('appbar_add_asset_button'),
          tooltip: l10n.assetsScreenAddTooltip,
          icon: const Icon(Icons.add),
          onPressed: () {
            Navigator.of(context)
                .push(SlidePageRoute(builder: (_) => const AssetFormScreen()));
          },
        );
      case 4:
        final isDark = theme.brightness == Brightness.dark;
        return IconButton(
          key: const ValueKey('analytics_theme_toggle_button'),
          tooltip: isDark
              ? l10n.analyticsScreenThemeToggleToLight
              : l10n.analyticsScreenThemeToggleToDark,
          icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
          onPressed: () {
            ref
                .read(themeModeProvider.notifier)
                .set(isDark ? ThemeMode.light : ThemeMode.dark);
          },
        );
      default:
        // Key-stable empty placeholder so the `AnimatedSwitcher` above has
        // something to fade in/out, rather than an abrupt disappearance.
        return const SizedBox.shrink();
    }
  }

  /// M21/Bug 1: the FAB is hoisted to the shell and swapped per active tab.
  /// `Scaffold` already animates a floatingActionButton change with its own
  /// built-in scale/fade transition when the child's `Key` changes — no
  /// manual slide, matching "swapping the FAB's action per active tab
  /// without it sliding".
  Widget? _buildFab(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return const FabSpeedDial(key: ValueKey('shell_fab_home'));
      case 1:
        return FloatingActionButton(
          key: const ValueKey('add_transaction_fab'),
          onPressed: () {
            Navigator.of(context).push(
              SlidePageRoute(builder: (_) => const TransactionFormScreen()),
            );
          },
          child: const Icon(Icons.add),
        );
      case 2:
        return FloatingActionButton(
          key: const ValueKey('add_goal_fab'),
          onPressed: () {
            Navigator.of(context)
                .push(SlidePageRoute(builder: (_) => const GoalFormScreen()));
          },
          child: const Icon(Icons.add),
        );
      case 3:
        return FloatingActionButton(
          key: const ValueKey('add_asset_fab'),
          onPressed: () {
            Navigator.of(context)
                .push(SlidePageRoute(builder: (_) => const AssetFormScreen()));
          },
          child: const Icon(Icons.add),
        );
      case 4:
        return FloatingActionButton(
          key: const ValueKey('analytics_add_transaction_fab'),
          onPressed: () {
            Navigator.of(context).push(
              SlidePageRoute(builder: (_) => const TransactionFormScreen()),
            );
          },
          child: const Icon(Icons.add),
        );
      case 5:
      default:
        return null;
    }
  }
}
