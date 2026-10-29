// Slide-in + fade for a newly-inserted list item per `docs/DESIGN.md`
// §Motion touchpoint 3: "new item enters from ~-16px offset + opacity 0->1
// over ~250ms; do NOT re-animate the entire list on every rebuild, only the
// newly-inserted item."
//
// Implementation note: rather than wiring a full `AnimatedList`, this relies
// on Flutter's own element-reuse rule — as long as the CALLER keys each
// wrapped item by its stable underlying id (transaction id, goal id), an
// existing item keeps the same `State` across rebuilds (so `initState`/the
// one-shot animation never re-fires), while a genuinely new item gets a
// fresh `State` and plays the animation once. This is simpler than
// `AnimatedList` for the "append/prepend one item to an otherwise static
// list" case these two screens need, and sidesteps `AnimatedList`'s
// imperative `insertItem` wiring entirely.
import 'package:flutter/material.dart';

import '../../motion/motion_durations.dart';

class SlideFadeInOnce extends StatefulWidget {
  const SlideFadeInOnce({
    super.key,
    required this.child,
    this.verticalOffset = -16,
    this.duration = MotionDurations.listInsert,
  });

  final Widget child;
  final double verticalOffset;
  final Duration duration;

  @override
  State<SlideFadeInOnce> createState() => _SlideFadeInOnceState();
}

class _SlideFadeInOnceState extends State<SlideFadeInOnce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Runs once per State lifetime (i.e. once per genuinely new list item —
    // see class doc comment), the first time MediaQuery is available.
    if (!_started) {
      _started = true;
      _controller.duration = motionDuration(context, widget.duration);
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: curved,
      child: widget.child,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, widget.verticalOffset * (1 - curved.value)),
            child: child,
          ),
        );
      },
    );
  }
}
