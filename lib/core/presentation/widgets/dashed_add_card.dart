import 'package:flutter/material.dart';

import '../../theme/app_typography.dart';

/// Dashed-border "add new" ghost card per mockups (`04_goals.html`,
/// `05_aset.html`) — terminal item at the end of a list inviting the user to
/// create another Goal/Asset, visually distinct from the solid data cards.
class DashedAddCard extends StatelessWidget {
  const DashedAddCard({super.key, required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: CustomPaint(
        painter: _DashedBorderPainter(color: theme.dividerColor),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '+',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: AppTypography.spaceMono,
                  fontStyle: FontStyle.normal,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTypography.script(
                  fontSize: 14,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({required this.color});

  final Color color;
  static const double _dashWidth = 6;
  static const double _dashGap = 4;
  static const double _radius = 18;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(_radius),
    );
    final path = Path()..addRRect(rrect);
    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + _dashWidth;
        dashedPath.addPath(
          metric.extractPath(distance, next.clamp(0, metric.length)),
          Offset.zero,
        );
        distance = next + _dashGap;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
