import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_typography.dart';

/// Builds the dark and light `ThemeData` from the `docs/DESIGN.md` v2 palette
/// and `docs/design/mockups/style.css` token specifications.
///
/// Dark is the product default; light must render every screen correctly too
/// (AGENTS.md antislop R-21/R-34) with inverted neutral surfaces and consistent accents.
abstract final class AppTheme {
  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkTextPrimary,
      primary: AppColors.burgundy,
      onPrimary: Colors.white,
      secondary: AppColors.burgundySoft,
      onSecondary: Colors.white,
      error: AppColors.expenseRed,
      onError: Colors.white,
      outline: AppColors.darkBorder,
    );
    return _build(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.darkBackground,
      cardColor: AppColors.darkSurface,
      cardBorder: AppColors.darkBorder,
      textPrimary: AppColors.darkTextPrimary,
      textSecondary: AppColors.darkTextSecondary,
      navBackground: AppColors.darkNavBg,
      unselectedNav: AppColors.darkTextMuted2,
      surface2: AppColors.darkSurface2,
      brightness: Brightness.dark,
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightTextPrimary,
      primary: AppColors.burgundy,
      onPrimary: Colors.white,
      secondary: AppColors.burgundySoft,
      onSecondary: Colors.white,
      // M19/D18: `expenseRed` only clears ~2:1 against light surfaces —
      // every Flutter-default form validation message (`TextFormField`'s
      // `errorText`, which styles itself from `colorScheme.error`) was
      // inheriting that failing color. `expenseRedOnLight` is the same hue,
      // darkened to clear 4.5:1 — see `test/core/theme/contrast_test.dart`.
      error: AppColors.expenseRedOnLight,
      onError: Colors.white,
      outline: AppColors.lightBorder,
    );
    return _build(
      colorScheme: colorScheme,
      scaffoldBackground: AppColors.lightBackground,
      cardColor: AppColors.lightSurface,
      cardBorder: AppColors.lightBorder,
      textPrimary: AppColors.lightTextPrimary,
      textSecondary: AppColors.lightTextSecondary,
      navBackground: AppColors.lightSurface,
      unselectedNav: AppColors.lightTextMuted2,
      surface2: AppColors.lightSurface2,
      brightness: Brightness.light,
    );
  }

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color cardColor,
    required Color cardBorder,
    required Color textPrimary,
    required Color textSecondary,
    required Color navBackground,
    required Color unselectedNav,
    required Color surface2,
    required Brightness brightness,
  }) {
    final textTheme = AppTypography.textTheme(textPrimary, textSecondary);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      cardColor: cardColor,
      dividerColor: cardBorder,
      fontFamily: AppTypography.fontFamily,
      textTheme: textTheme,
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        margin: const EdgeInsets.only(bottom: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: cardBorder),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackground,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.script(fontSize: 20, color: textPrimary),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.burgundy,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: navBackground,
        selectedItemColor: AppColors.burgundySoft,
        unselectedItemColor: unselectedNav,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: AppTypography.script(
          fontSize: 10,
          color: AppColors.burgundySoft,
        ),
        unselectedLabelStyle: AppTypography.script(
          fontSize: 10,
          color: unselectedNav,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.burgundy,
          foregroundColor: Colors.white,
          textStyle: AppTypography.mono(
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: BorderSide(color: cardBorder),
          textStyle: AppTypography.mono(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.burgundySoft),
        ),
        labelStyle: AppTypography.mono(fontSize: 12, color: textSecondary),
        hintStyle: AppTypography.mono(fontSize: 14, color: textSecondary),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : unselectedNav,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? AppColors.burgundy
              : surface2,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
    );
  }
}
