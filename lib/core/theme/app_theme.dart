import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the two `ThemeData` instances from the `docs/DESIGN.md` palette.
///
/// Dark is the product default; light must render every screen correctly
/// too (AGENTS.md antislop R-21/R-34), so both are built from the same
/// shape rather than one being a quick afterthought of the other.
abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkTextPrimary,
      primary: AppColors.brandTeal,
      onPrimary: AppColors.darkBackground,
      secondary: AppColors.brandTeal,
      error: AppColors.expenseRed,
      onError: AppColors.darkTextPrimary,
    );
    return _build(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      brightness: Brightness.dark,
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightTextPrimary,
      primary: AppColors.brandTeal,
      onPrimary: AppColors.lightBackground,
      secondary: AppColors.brandTeal,
      error: AppColors.expenseRed,
      onError: AppColors.lightTextPrimary,
    );
    return _build(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      brightness: Brightness.light,
    );
  }

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color textPrimary,
    required Color textSecondary,
    required Brightness brightness,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      cardColor: cardColor,
      fontFamily: AppTypography.fontFamily,
      textTheme: AppTypography.textTheme(textPrimary, textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        elevation: 0,
      ),
    );
  }
}
