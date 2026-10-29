// Palette values pulled verbatim from `docs/DESIGN.md` v2 and `docs/design/mockups/style.css`.
//
// Single source of truth for color tokens so screens stay strictly inside
// the LedgerMate Figma design system (see AGENTS.md antislop R-01).
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark base (default per PRD & mockups)
  static const darkBackground = Color(0xFF121212); // --bg
  static const darkSurface = Color(0xFF1E1E1E); // --surface
  static const darkSurface2 = Color(0xFF262626); // --surface-2
  static const darkBorder = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)
  static const darkTextPrimary = Color(0xFFE9E8E4); // --ink
  static const darkTextSecondary = Color(0xFF8A8A86); // --muted
  static const darkTextMuted2 = Color(0xFF6F6F6B); // --muted-2

  // Light base (mandatory per PRD FR-09/AGENTS.md R-21/R-34)
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurface2 = Color(0xFFF2F2F0);
  static const lightBorder = Color(0x14000000); // rgba(0, 0, 0, 0.08)
  static const lightTextPrimary = Color(0xFF14161A);
  static const lightTextSecondary = Color(0xFF5B6370);
  static const lightTextMuted2 = Color(0xFF6F6F6B);

  // Brand accent: doff burgundy (#7d4349) per D17
  // Replaces v1 teal draft — applied deliberately to brand/action moments only
  static const burgundy = Color(0xFF7D4349); // --burgundy
  static const burgundySoft = Color(0xFFA8767B); // --burgundy-soft
  static const burgundyDeep = Color(0xFF5E3236); // --burgundy-deep

  // Backwards compatibility alias for the brand accent
  static const brandTeal = burgundy;
  static const brandBurgundy = burgundy;

  // Semantic status colors (identical in both dark and light mode)
  static const expenseRed = Color(0xFFE0A0A0); // --down
  static const savingsGreen = Color(0xFF9FD6A8); // --up
  static const warningAmber = Color(0xFFF5A623);

  // Component tokens from style.css
  static const whitePill = Color(0xFFF2F2F0);
  static const darkNavBg = Color(0xFF161616);
  static const iconCircleBg = Color(0xFF2E2E2E);
  static const iconCircleBgLight = Color(0xFFEBEBEA);
}
