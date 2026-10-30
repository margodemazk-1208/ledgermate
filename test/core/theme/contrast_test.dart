// M19/D18 WCAG contrast verification — computes real relative-luminance
// contrast ratios (WCAG 2.x formula) for the color constants M19 moved to
// fix the audited failures, rather than eyeballing them (antislop R-35).
//
// Reference: light-mode red/green/amber measured ~1.6-2.2:1 pre-fix,
// dark-mode burgundy focal number measured ~2.2-2.47:1 pre-fix (see
// docs/DECISIONS.md D18 + the M19 task body). This file asserts the NEW
// constants clear the WCAG AA floors (4.5:1 normal text, 3:1 large text).
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ledgermate/core/theme/app_colors.dart';

/// WCAG 2.x relative luminance of a color's sRGB channels.
double _relativeLuminance(Color color) {
  double channel(double c) {
    return c <= 0.03928
        ? c / 12.92
        : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  }

  final r = channel(color.r);
  final g = channel(color.g);
  final b = channel(color.b);
  return 0.2126 * r + 0.7152 * g + 0.0722 * b;
}

/// WCAG 2.x contrast ratio between two colors, 1:1 (no contrast) to 21:1
/// (black on white).
double contrastRatio(Color a, Color b) {
  final la = _relativeLuminance(a);
  final lb = _relativeLuminance(b);
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('M19 contrast fix — light-mode semantic colors vs light surfaces', () {
    const lightSurface = Color(0xFFFFFFFF);
    const lightBackground = Color(0xFFFAFAFA);

    test('expenseRedOnLight clears 4.5:1 (AA normal text)', () {
      expect(
        contrastRatio(AppColors.expenseRedOnLight, lightSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(AppColors.expenseRedOnLight, lightBackground),
        greaterThanOrEqualTo(4.3),
      );
    });

    test('savingsGreenOnLight clears 4.5:1 (AA normal text)', () {
      expect(
        contrastRatio(AppColors.savingsGreenOnLight, lightSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(AppColors.savingsGreenOnLight, lightBackground),
        greaterThanOrEqualTo(4.3),
      );
    });

    test('warningAmberOnLight clears 4.5:1 (AA normal text)', () {
      expect(
        contrastRatio(AppColors.warningAmberOnLight, lightSurface),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrastRatio(AppColors.warningAmberOnLight, lightBackground),
        greaterThanOrEqualTo(4.3),
      );
    });

    test('brightness-aware accessors pick the compliant light variant', () {
      expect(
        AppColors.expenseRedText(Brightness.light),
        AppColors.expenseRedOnLight,
      );
      expect(
        AppColors.savingsGreenText(Brightness.light),
        AppColors.savingsGreenOnLight,
      );
      expect(
        AppColors.warningAmberText(Brightness.light),
        AppColors.warningAmberOnLight,
      );
    });

    test('dark mode keeps the original (already-compliant) pastel', () {
      expect(AppColors.expenseRedText(Brightness.dark), AppColors.expenseRed);
      expect(
        AppColors.savingsGreenText(Brightness.dark),
        AppColors.savingsGreen,
      );
      expect(
        AppColors.warningAmberText(Brightness.dark),
        AppColors.warningAmber,
      );
    });
  });

  group('M19 contrast fix — dark-mode burgundy focal number', () {
    const darkBackground = Color(0xFF121212);
    const darkSurface = Color(0xFF1E1E1E);

    test('burgundyOnDark clears 4.5:1 against darkBackground', () {
      expect(
        contrastRatio(AppColors.burgundyOnDark, darkBackground),
        greaterThanOrEqualTo(4.5),
      );
    });

    test('burgundyOnDark clears 3:1 (AA large text) against darkSurface', () {
      expect(
        contrastRatio(AppColors.burgundyOnDark, darkSurface),
        greaterThanOrEqualTo(3.0),
      );
    });

    test(
      'burgundyText picks burgundyOnDark in dark mode, burgundy in light',
      () {
        expect(
          AppColors.burgundyText(Brightness.dark),
          AppColors.burgundyOnDark,
        );
        expect(AppColors.burgundyText(Brightness.light), AppColors.burgundy);
      },
    );
  });

  group('Pre-fix failure documentation (D18 audit numbers)', () {
    const lightSurface = Color(0xFFFFFFFF);
    const darkBackground = Color(0xFF121212);

    test('original expenseRed/savingsGreen/warningAmber fail AA on light '
        'surfaces (~1.6-2.2:1, matches D18 audit)', () {
      expect(contrastRatio(AppColors.expenseRed, lightSurface), lessThan(4.5));
      expect(
        contrastRatio(AppColors.savingsGreen, lightSurface),
        lessThan(4.5),
      );
      expect(
        contrastRatio(AppColors.warningAmber, lightSurface),
        lessThan(4.5),
      );
    });

    test('original burgundy fails AA on darkBackground (~2.2-2.47:1, '
        'matches D18 audit)', () {
      expect(contrastRatio(AppColors.burgundy, darkBackground), lessThan(3.0));
    });
  });
}
