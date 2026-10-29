// Shared motion/reduce-motion helper for `docs/DESIGN.md` §Motion (M14).
//
// Every animated touchpoint in the app routes its Duration through this
// function so `MediaQuery.disableAnimations` (Android's system-wide
// reduce-motion setting) is honored consistently: durations collapse to a
// near-instant single frame rather than skipping the state change entirely
// (per the explicit instruction in §Motion — "so nothing looks broken, it's
// just not performing").
import 'package:flutter/material.dart';

/// Canonical per-touchpoint durations from `docs/DESIGN.md` §Motion, kept in
/// one place so every widget cites the same constant instead of re-guessing.
abstract final class MotionDurations {
  /// Screen/tab navigation slide (~200ms, Curves.easeOutCubic).
  static const navigation = Duration(milliseconds: 200);

  /// "Uang Jajan Aman Hari Ini" count-up/down tween (~500-700ms ease-out).
  static const countUp = Duration(milliseconds: 600);

  /// New transaction/goal list-item slide-in + fade (~250ms).
  static const listInsert = Duration(milliseconds: 250);

  /// FAB speed-dial total staggered reveal/collapse duration (5 items,
  /// ~50ms stagger between each → 4 gaps + 1 item's own fade/scale).
  static const fabSpeedDial = Duration(milliseconds: 450);

  /// Button/card press-down scale (~0.96) — snappy, not the release spring.
  static const pressDown = Duration(milliseconds: 100);

  /// Button/card release spring-back.
  static const pressRelease = Duration(milliseconds: 180);

  /// Goal/budget progress bar fill width transition (~400-500ms ease-out).
  static const progressFill = Duration(milliseconds: 450);

  /// Save-success toast: scale/fade in.
  static const toastIn = Duration(milliseconds: 250);

  /// Save-success toast: hold before fading.
  static const toastHold = Duration(milliseconds: 1300);

  /// Save-success toast: fade out.
  static const toastOut = Duration(milliseconds: 350);

  /// Near-instant collapse used in place of any of the above when
  /// `disableAnimations` is on — non-zero so the animation still "completes"
  /// a frame rather than silently skipping the state change.
  static const reduced = Duration(milliseconds: 1);
}

/// Returns [duration] unless the user has the system reduce-motion setting
/// on (`MediaQuery.disableAnimations`), in which case it collapses to
/// [MotionDurations.reduced].
Duration motionDuration(BuildContext context, Duration duration) {
  final disableAnimations =
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  return disableAnimations ? MotionDurations.reduced : duration;
}

/// Same as [motionDuration], but usable from places that only have a
/// [BuildContext] that might already be unmounted-adjacent (e.g. a route's
/// `navigator?.context`). Returns `null` semantics are not needed since both
/// branches return a valid Duration.
bool isReducedMotion(BuildContext context) =>
    MediaQuery.maybeOf(context)?.disableAnimations ?? false;
