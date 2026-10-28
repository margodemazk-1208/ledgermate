// Chart color palette and theme helpers for M8 Visual Analytics (FR-07).
// Follows docs/DESIGN.md and AGENTS.md antislop guidelines:
// - No decorative neon gradients
// - Grounded in LedgerMate brand teal and semantic status colors
// - High contrast in both dark and light modes
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

abstract final class AnalyticsChartColors {
  /// Deliberate category colors: calm, distinct, not an ad-hoc rainbow.
  static const List<Color> categoryPalette = [
    AppColors.brandTeal, // Color(0xFF0FA37F) - primary/food
    AppColors.warningAmber, // Color(0xFFF5A623) - transport
    Color(0xFF6366F1), // Indigo - bills/utilities
    Color(0xFFEC4899), // Rose - entertainment/leisure
    Color(0xFF8B5CF6), // Violet - shopping
    Color(0xFF14B8A6), // Cyan - health
    Color(0xFF3B82F6), // Blue - education
    Color(0xFF64748B), // Slate - others/miscellaneous
  ];

  /// Maps category to a stable, deterministic color by id or name.
  static Color getCategoryColor(int categoryId, [String? name]) {
    if (name != null) {
      switch (name.trim().toLowerCase()) {
        case 'makan':
          return AppColors.brandTeal;
        case 'transport':
          return AppColors.warningAmber;
        case 'hiburan':
          return const Color(0xFFEC4899);
        case 'tagihan':
          return const Color(0xFF6366F1);
        case 'lainnya':
          return const Color(0xFF64748B);
      }
    }
    final index = (categoryId - 1).abs() % categoryPalette.length;
    return categoryPalette[index];
  }

  /// Bar color for current month in Month-over-Month charts.
  static const Color currentMonthBar = AppColors.brandTeal;

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
