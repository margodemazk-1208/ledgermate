// Count-up/count-down tween for Rupiah amounts per `docs/DESIGN.md`
// §Motion touchpoint 2: "Uang Jajan Aman Hari Ini" value change animates
// from old to new over ~500-700ms ease-out, formatted through the existing
// Rupiah formatter on every intermediate frame (not a blur/placeholder).
import 'package:flutter/material.dart';

import '../../motion/motion_durations.dart';
import '../../utils/rupiah_formatter.dart';

/// Animates [value] from its previous value to the new one whenever it
/// changes, re-formatting through [formatRupiah] on every frame. On first
/// build (no previous value yet) it shows the value immediately without
/// animating — the touchpoint is "value CHANGE", not initial load.
///
/// [textKey] (distinct from the widget's own [key]) is applied to the
/// actual `Text` produced, so existing `find.byKey(...)` widget tests that
/// expect a `Text` at a specific key keep working unchanged.
class CountUpRupiah extends StatefulWidget {
  const CountUpRupiah({
    super.key,
    this.textKey,
    required this.value,
    this.style,
    this.duration = MotionDurations.countUp,
  });

  final Key? textKey;
  final int value;
  final TextStyle? style;
  final Duration duration;

  @override
  State<CountUpRupiah> createState() => _CountUpRupiahState();
}

class _CountUpRupiahState extends State<CountUpRupiah> {
  late int _previousValue;

  @override
  void initState() {
    super.initState();
    _previousValue = widget.value;
  }

  @override
  void didUpdateWidget(covariant CountUpRupiah oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _previousValue = oldWidget.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final duration = motionDuration(context, widget.duration);
    return TweenAnimationBuilder<int>(
      tween: IntTween(begin: _previousValue, end: widget.value),
      duration: duration,
      curve: Curves.easeOut,
      builder: (context, animatedValue, child) {
        return Text(
          formatRupiah(animatedValue),
          key: widget.textKey,
          style: widget.style,
        );
      },
    );
  }
}
