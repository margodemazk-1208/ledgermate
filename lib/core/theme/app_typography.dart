// Typography per `docs/DESIGN.md` v2 (from user's Figma mockups).
//
// - Display/script (`Playfair Display`, italic, weight 500): wordmark, screen titles,
//   card section labels, bottom-nav labels.
// - Data/numeric (`Space Mono`, regular 400 / bold 700): every amount, form input,
//   and label that is data rather than voice.
import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String playfair = 'Playfair Display';
  static const String spaceMono = 'Space Mono';

  /// Base font family for data/numbers and standard text.
  static const String fontFamily = spaceMono;

  /// Script style (Playfair Display, italic, 500) per mockups .script class.
  static TextStyle script({
    double fontSize = 16,
    Color? color,
    FontWeight fontWeight = FontWeight.w500,
    FontStyle fontStyle = FontStyle.italic,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: playfair,
      fontSize: fontSize,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  /// Monospace data style (Space Mono) per mockups.
  static TextStyle mono({
    double fontSize = 14,
    Color? color,
    FontWeight fontWeight = FontWeight.w400,
    FontStyle fontStyle = FontStyle.normal,
    double? height,
    double? letterSpacing,
  }) {
    return TextStyle(
      fontFamily: spaceMono,
      fontSize: fontSize,
      fontStyle: fontStyle,
      fontWeight: fontWeight,
      color: color,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      // Daily safe-spend number is the largest, boldest element
      displayLarge: TextStyle(
        fontFamily: spaceMono,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.1,
      ),
      headlineMedium: TextStyle(
        fontFamily: playfair,
        fontSize: 24,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleLarge: TextStyle(
        fontFamily: playfair,
        fontSize: 20,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: playfair,
        fontSize: 16,
        fontStyle: FontStyle.italic,
        fontWeight: FontWeight.w500,
        color: primary,
      ),
      titleSmall: TextStyle(
        fontFamily: spaceMono,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: spaceMono,
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: spaceMono,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      bodySmall: TextStyle(
        fontFamily: spaceMono,
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: spaceMono,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
      labelMedium: TextStyle(
        fontFamily: spaceMono,
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelSmall: TextStyle(
        fontFamily: spaceMono,
        fontSize: 10,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
    );
  }
}
