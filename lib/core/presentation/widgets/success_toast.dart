// Save-success feedback per `docs/DESIGN.md` §Motion touchpoint 8: a custom
// crafted toast — checkmark animates in, holds briefly, fades out (~2s
// total), non-blocking overlay — explicitly NOT Flutter's default plain
// `SnackBar`.
import 'package:flutter/material.dart';

import '../../motion/motion_durations.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_typography.dart';

/// Shows the crafted success toast as a non-blocking [OverlayEntry] above
/// everything (including the bottom nav), auto-dismissing itself. Safe to
/// call right before `Navigator.pop()` — the entry lives on the app-level
/// `Overlay` (shared across routes), so it survives the calling screen
/// being popped.
void showSuccessToast(BuildContext context, String message) {
  final overlayState = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) =>
        _SuccessToast(message: message, onDismissed: () => entry.remove()),
  );
  overlayState.insert(entry);
}

class _SuccessToast extends StatefulWidget {
  const _SuccessToast({required this.message, required this.onDismissed});

  final String message;
  final VoidCallback onDismissed;

  @override
  State<_SuccessToast> createState() => _SuccessToastState();
}

class _SuccessToastState extends State<_SuccessToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: MotionDurations.toastIn,
  );
  bool _scheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_scheduled) {
      _scheduled = true;
      _run();
    }
  }

  Future<void> _run() async {
    final reduced = isReducedMotion(context);
    final inDuration = reduced
        ? MotionDurations.reduced
        : MotionDurations.toastIn;
    final holdDuration = reduced
        ? MotionDurations.reduced
        : MotionDurations.toastHold;
    final outDuration = reduced
        ? MotionDurations.reduced
        : MotionDurations.toastOut;

    // All three phases are driven by the SAME ticker-backed
    // AnimationController (the "hold" phase animates to its own current
    // value) rather than a raw `Future.delayed` — a bare Timer isn't tied
    // to a scheduled animation frame, so `tester.pumpAndSettle()` in widget
    // tests never advances it, leaving a dangling Timer that fails the test
    // with "A Timer is still pending even after the widget tree was
    // disposed."
    await _controller.animateTo(
      1,
      duration: inDuration,
      curve: Curves.easeOutBack,
    );
    if (!mounted) return;
    await _controller.animateTo(1, duration: holdDuration);
    if (!mounted) return;
    await _controller.animateTo(
      0,
      duration: outDuration,
      curve: Curves.easeOut,
    );
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    final scale = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    return Positioned(
      left: 24,
      right: 24,
      bottom: 110,
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.bottomCenter,
          child: FadeTransition(
            opacity: opacity,
            child: ScaleTransition(
              scale: scale,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.inverseSurface,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.savingsGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          widget.message,
                          style: AppTypography.mono(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onInverseSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
