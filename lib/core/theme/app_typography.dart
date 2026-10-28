// Typography per `docs/DESIGN.md`.
//
// DESIGN.md names Inter but explicitly allows "platform default if Inter
// adds APK size concerns — decide at M0". No font package/asset is in
// this milestone's dependency list, so M0 ships the platform default
// (`fontFamily: null`) rather than declaring 'Inter' without bundling it
// — claiming a font that isn't actually there would silently fall back
// while looking intentional. Revisit in a UI milestone if Inter is
// wanted: add `google_fonts` or bundle static Inter assets then set
// `fontFamily` here.
import 'package:flutter/material.dart';

abstract final class AppTypography {
  static const String? fontFamily = null;

  static TextTheme textTheme(Color primary, Color secondary) {
    return TextTheme(
      // The daily safe-spend number is always the largest, boldest
      // element on screen (docs/DESIGN.md identity motif) — displayLarge
      // is reserved for it.
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 56,
        fontWeight: FontWeight.w700,
        color: primary,
        height: 1.1,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: primary,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: secondary,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: primary,
      ),
    );
  }
}
