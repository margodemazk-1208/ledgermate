// Palette values pulled verbatim from `docs/DESIGN.md`.
//
// Keep this file as the single source of truth for hex values so no
// screen reaches for a generic Material color instead of the LedgerMate
// palette (see AGENTS.md antislop R-01).
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Dark (default per PRD).
  static const darkBackground = Color(0xFF121417);
  static const darkSurface = Color(0xFF1C1F24);
  static const darkTextPrimary = Color(0xFFF2F3F5);
  static const darkTextSecondary = Color(0xFF9CA3AF);

  // Light (must be fully functional, not an afterthought — R-21/R-34).
  static const lightBackground = Color(0xFFFAFAFA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightTextPrimary = Color(0xFF14161A);
  static const lightTextSecondary = Color(0xFF5B6370);

  // Single brand accent, shared by both themes.
  static const brandTeal = Color(0xFF0FA37F);

  // Semantic status colors encode data, not branding, so they are exempt
  // from the one-accent cap (docs/DESIGN.md).
  static const expenseRed = Color(0xFFE5484D);
  static const savingsGreen = Color(0xFF22C55E);
  static const warningAmber = Color(0xFFF5A623);
}
