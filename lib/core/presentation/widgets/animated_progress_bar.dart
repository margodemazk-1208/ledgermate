// Animated progress-bar fill per `docs/DESIGN.md` §Motion touchpoint 7:
// "Animates smoothly from old % to new % (not an instant jump) whenever the
// underlying percentage changes" — Goal cards and the Goals overview card.
import 'package:flutter/material.dart';

import '../../motion/motion_durations.dart';

/// Drop-in animated replacement for a static `LinearProgressIndicator`
/// bound directly to a `value`. Tweens the displayed value whenever [value]
/// changes instead of jumping instantly.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.value,
    this.minHeight = 8,
    this.backgroundColor,
    required this.valueColor,
    this.duration = MotionDurations.progressFill,
  });

  final double value;
  final double minHeight;
  final Color? backgroundColor;
  final Color valueColor;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final animDuration = motionDuration(context, duration);
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.clamp(0.0, 1.0)),
      duration: animDuration,
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return LinearProgressIndicator(
          value: animatedValue,
          minHeight: minHeight,
          backgroundColor: backgroundColor,
          valueColor: AlwaysStoppedAnimation<Color>(valueColor),
        );
      },
    );
  }
}
