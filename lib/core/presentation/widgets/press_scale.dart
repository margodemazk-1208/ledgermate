// Press-down scale feedback per `docs/DESIGN.md` §Motion touchpoint 5:
// scale to ~0.96 on press, spring back on release, + a light haptic pulse.
// Reserved for primary CTAs/consequential actions (Simpan, FAB, Tarik dari
// Goal, Transfer, delete) — NOT every navigational tap (see the explicit
// non-goals list), so this is applied selectively at call sites, not
// globally via a theme/button override.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../motion/motion_durations.dart';

/// Wraps [child] (typically a button) with a press-down scale + haptic.
/// Uses a [Listener] rather than a [GestureDetector] so it observes raw
/// pointer events without entering the gesture arena — the wrapped button
/// keeps handling its own tap/onPressed semantics (including disabled
/// state) exactly as before.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.scale = 0.96,
    this.haptic = true,
    this.enabled = true,
  });

  final Widget child;
  final double scale;
  final bool haptic;

  /// When false, behaves as a transparent passthrough (e.g. a disabled
  /// button shouldn't scale/haptic on press).
  final bool enabled;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (!widget.enabled) return;
    if (_pressed != value) {
      setState(() => _pressed = value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(
      context,
      _pressed ? MotionDurations.pressDown : MotionDurations.pressRelease,
    );
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) {
        if (!widget.enabled) return;
        _setPressed(true);
        if (widget.haptic) {
          HapticFeedback.lightImpact();
        }
      },
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.scale : 1.0,
        duration: duration,
        curve: _pressed ? Curves.easeOut : Curves.easeOutBack,
        child: widget.child,
      ),
    );
  }
}
