import 'package:flutter/material.dart';

/// Small circular icon badge per `docs/design/mockups/style.css` `.icon-circle`
/// (24-44px dark circle, centered 1.5px-stroke line icon) — the consistent
/// per-row/category/wallet icon container used across every mockup screen.
class IconCircle extends StatelessWidget {
  const IconCircle({
    super.key,
    required this.icon,
    this.size = 40,
    this.iconSize,
    this.color,
    this.background,
  });

  final IconData icon;
  final double size;
  final double? iconSize;
  final Color? color;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bg =
        background ??
        (isDark ? const Color(0xFF2E2E2E) : const Color(0xFFEBEBEA));
    final fg = color ?? theme.textTheme.bodyLarge?.color;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      alignment: Alignment.center,
      child: Icon(icon, size: iconSize ?? size * 0.5, color: fg),
    );
  }
}
