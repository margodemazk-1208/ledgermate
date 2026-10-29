// Horizontal slide navigation per `docs/DESIGN.md` §Motion touchpoint 1:
// "new screen slides in from the right on push, exits right on pop" for
// stack navigation, and a direction-aware variant for bottom-nav tab
// switches (keyed by tab order so Home->Settings and Settings->Home slide
// opposite ways). Explicitly NOT Hero/shared-element — plain slide only.
import 'package:flutter/material.dart';

import '../../motion/motion_durations.dart';

/// Drop-in replacement for `MaterialPageRoute` that slides horizontally
/// instead of Material 3's default fade-through/zoom transition, per
/// `docs/DESIGN.md` §Motion. Keeps `MaterialPageRoute`'s modal/barrier
/// behavior (back-swipe, route semantics) by subclassing it directly.
class SlidePageRoute<T> extends MaterialPageRoute<T> {
  SlidePageRoute({
    required super.builder,
    super.settings,
    super.fullscreenDialog,
    this.fromLeft = false,
  });

  /// When true, the incoming screen slides in from the LEFT instead of the
  /// right — used by [AppBottomNav] to make moving to an earlier tab feel
  /// like "going back" rather than always sliding in from the right.
  final bool fromLeft;

  @override
  Duration get transitionDuration {
    final ctx = navigator?.context;
    if (ctx != null && isReducedMotion(ctx)) {
      return MotionDurations.reduced;
    }
    return MotionDurations.navigation;
  }

  @override
  Duration get reverseTransitionDuration => transitionDuration;

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final beginOffset = fromLeft ? const Offset(-1, 0) : const Offset(1, 0);
    final primaryCurved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final secondaryCurved = CurvedAnimation(
      parent: secondaryAnimation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );
    final exitOffset = fromLeft ? const Offset(0.3, 0) : const Offset(-0.3, 0);

    return SlideTransition(
      position: Tween<Offset>(
        begin: beginOffset,
        end: Offset.zero,
      ).animate(primaryCurved),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: Offset.zero,
          end: exitOffset,
        ).animate(secondaryCurved),
        child: child,
      ),
    );
  }
}
