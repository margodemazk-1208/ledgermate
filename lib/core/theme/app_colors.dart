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

  // Semantic status colors — the base (dark-mode) values stay exactly as
  // designed (~8-11:1 against the dark surfaces, plenty of margin).
  static const expenseRed = Color(0xFFE0A0A0); // --down
  static const savingsGreen = Color(0xFF9FD6A8); // --up
  static const warningAmber = Color(0xFFF5A623);

  // M19/D18 WCAG contrast fix: the same pastel values measured ~1.6-2.2:1
  // against the light surfaces (`docs/DECISIONS.md` D18 audit) — well below
  // the 4.5:1 AA floor for normal text. These are darker-lightness variants
  // of the SAME hue/saturation (not a palette change, see docs/DESIGN.md
  // §Palette + the explicit "don't change hue identity" instruction on the
  // M19 task), picked so they clear 4.5:1 against both `lightSurface`
  // (#FFFFFF) and `lightBackground` (#FAFAFA) — verified in
  // `test/core/theme/contrast_test.dart`.
  static const expenseRedOnLight = Color(0xFFC64F4F);
  static const savingsGreenOnLight = Color(0xFF398545);
  static const warningAmberOnLight = Color(0xFFA56A08);

  /// Brightness-aware accessor for semantic-color TEXT (data figures,
  /// validation messages, status labels) rendered directly on a plain
  /// surface/background. Dark mode keeps the original pastel (already
  /// compliant); light mode uses the darker on-light variant above.
  /// Decorative uses (icon badges on their own tinted container, borders,
  /// background tints) are NOT required to switch — only readable text.
  static Color expenseRedText(Brightness brightness) =>
      brightness == Brightness.dark ? expenseRed : expenseRedOnLight;
  static Color savingsGreenText(Brightness brightness) =>
      brightness == Brightness.dark ? savingsGreen : savingsGreenOnLight;
  static Color warningAmberText(Brightness brightness) =>
      brightness == Brightness.dark ? warningAmber : warningAmberOnLight;

  // M19/D18 WCAG contrast fix: the dark-mode focal "Uang Jajan Aman" number
  // (and the couple of equivalent single-focal-number spots on other
  // screens — Wallets' Total Saldo, Goals' overall progress %) rendered
  // `burgundy` text directly on `darkSurface`/`darkBackground`, measuring
  // ~2.2-2.47:1 (D18 audit). This is a LIGHTER variant of the same hue,
  // picked to clear 4.5:1 against `darkBackground` (and comfortably clear
  // 3:1 — the "large text" AA floor — against `darkSurface`) without
  // touching `burgundy`'s many other (button/badge/border) uses, which are
  // fine as-is in both themes.
  static const burgundyOnDark = Color(0xFFB06C73);
  static Color burgundyText(Brightness brightness) =>
      brightness == Brightness.dark ? burgundyOnDark : burgundy;

  // Component tokens from style.css
  static const whitePill = Color(0xFFF2F2F0);
  static const darkNavBg = Color(0xFF161616);
  static const iconCircleBg = Color(0xFF2E2E2E);
  static const iconCircleBgLight = Color(0xFFEBEBEA);
}
