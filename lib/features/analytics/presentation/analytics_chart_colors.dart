// Chart color palette and theme helpers for M8 Visual Analytics (FR-07).
// Recolored for M13 (v1.2) per docs/design/mockups/06_analytics.html's inline
// SVG stroke values (#9c5c62/#9a9a94/#5c5c58) — muted burgundy/grey tones
// matching the dark-monochrome-plus-burgundy-accent system (docs/DESIGN.md),
// not an ad-hoc rainbow. High contrast maintained in both dark and light modes.
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

abstract final class AnalyticsChartColors {
  /// Deliberate category colors lifted from the mockup's pie-chart strokes,
  /// extended with the existing semantic/brand palette for >3 categories.
  static const List<Color> categoryPalette = [
    Color(0xFF9C5C62), // muted burgundy — primary/food (06_analytics.html)
    Color(0xFF9A9A94), // warm grey — transport (06_analytics.html)
    Color(0xFF5C5C58), // dark grey — bills/utilities (06_analytics.html)
    AppColors.burgundySoft, // soft burgundy — entertainment/leisure
    AppColors.warningAmber, // amber — shopping
    Color(0xFF6B7280), // slate — health
    AppColors.burgundyDeep, // deep burgundy — education
    Color(0xFF3F3F3B), // near-black grey — others/miscellaneous
  ];

  /// Maps category to a stable, deterministic color by id or name.
  static Color getCategoryColor(int categoryId, [String? name]) {
    if (name != null) {
      switch (name.trim().toLowerCase()) {
        case 'makan':
          return categoryPalette[0];
        case 'transport':
          return categoryPalette[1];
        case 'hiburan':
          return categoryPalette[3];
        case 'tagihan':
          return categoryPalette[2];
        case 'lainnya':
          return categoryPalette[7];
      }
    }
    final index = (categoryId - 1).abs() % categoryPalette.length;
    return categoryPalette[index];
  }

  /// Bar color for current month in Month-over-Month charts.
  static const Color currentMonthBar = AppColors.burgundySoft;

  /// Bar color for previous month in Month-over-Month charts.
  /// Muted tone so current month has clear visual hierarchy.
  static Color previousMonthBar(bool isDark) {
    return isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8);
  }

  /// Subtle gridline color that maintains legibility without visual noise.
  static Color gridLineColor(bool isDark) {
    return isDark ? const Color(0xFF262C36) : const Color(0xFFE2E8F0);
  }

  /// Axis label and border styling.
  static Color axisBorderColor(bool isDark) {
    return isDark ? const Color(0xFF333D4B) : const Color(0xFFCBD5E1);
  }

  /// Semantic colors for income vs expense ratio.
  static const Color incomeColor = AppColors.savingsGreen;
  static const Color expenseColor = AppColors.expenseRed;
}
