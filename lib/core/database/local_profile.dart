import 'package:isar_community/isar.dart';

part 'local_profile.g.dart';

/// User's income pattern — decides which Smart Daily Budget formula
/// (`docs/PRD.md` §7.1 BR-01) applies: Mode A (periodic lump-sum) reads
/// [LocalProfile.nextPaydayDate]; Mode B (daily) reads
/// [LocalProfile.carryOverBalance] instead. See decision D5 in
/// `docs/DECISIONS.md` — never hardcode a monthly-only assumption anywhere
/// that reads this.
enum IncomeFrequency { periodic, daily }

/// App display language (FR-09, dwibahasa ID/EN).
enum AppLanguage { id, en }

/// App theme setting (FR-09). Deliberately only dark/light — no "system" —
/// `docs/PRD.md` §8 specifies exactly these two values. Named distinctly
/// from Flutter's own `ThemeMode` (used by `core/theme/theme_provider.dart`
/// for the live UI state) to avoid confusing the persisted setting with the
/// in-memory one.
enum AppThemeSetting { dark, light }

/// Single-row settings/profile collection — exactly one [LocalProfile]
/// should exist per install (PRD §8). No uniqueness is enforced by Isar
/// itself; the repository that reads/writes this (a later milestone) is
/// responsible for treating it as a singleton.
///
/// Monetary fields on this collection ([fixedSalary], [carryOverBalance])
/// are whole-Rupiah [int] — see the Decimal-representation note in
/// `lib/core/database/isar_provider.dart` for the full rationale.
@collection
class LocalProfile {
  Id id = Isar.autoIncrement;

  /// Whole-Rupiah int. See decimal-representation note in
  /// `lib/core/database/isar_provider.dart`.
  int fixedSalary = 0;

  @enumerated
  IncomeFrequency incomeFrequency = IncomeFrequency.periodic;

  /// Only meaningful when [incomeFrequency] is [IncomeFrequency.periodic].
  DateTime? nextPaydayDate;

  /// Only meaningful when [incomeFrequency] is [IncomeFrequency.daily].
  /// Whole-Rupiah int, default 0 per PRD §8.
  int carryOverBalance = 0;

  @enumerated
  AppLanguage language = AppLanguage.id;

  @enumerated
  AppThemeSetting theme = AppThemeSetting.dark;

  bool notifDailyReminderEnabled = true;

  /// Time-of-day stored as minutes since midnight (0-1439) — Isar has no
  /// native Time type. Default 1260 == 21:00 per PRD §8's default.
  int notifDailyReminderTime = 21 * 60;

  bool notifLimitAlertEnabled = true;

  bool notifPayCycleEnabled = true;

  bool notifGoalMilestoneEnabled = true;
}
