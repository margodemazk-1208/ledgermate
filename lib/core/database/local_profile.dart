import 'package:isar_community/isar.dart';

import 'pay_cycle.dart';

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

/// Mode A's "interval length" concept from `docs/PRD.md` FR-01 — Periodik
/// covers "mingguan/2 mingguan/bulanan/custom". M1 did not anticipate a
/// field for this because BR-01's formula (§7.1) only ever reads
/// [LocalProfile.nextPaydayDate] (`RemainingDays` = days from today to
/// that date) — the interval type itself is never consumed by the
/// formula engine. This M2 schema addition persists the user's choice
/// purely so the onboarding/pay-cycle UI can show and pre-fill it later
/// (e.g. a future M5 "same interval as last time" convenience); it is
/// *not* read anywhere in `core/formulas/`. Flagged per M2 task scope as
/// a schema addition, not a silent improvisation.
enum IncomeIntervalType { weekly, biweekly, monthly, custom }

/// Single-row settings/profile collection — exactly one [LocalProfile]
/// should exist per install (PRD §8). No uniqueness is enforced by Isar
/// itself; the repository that reads/writes this (M2's
/// `features/onboarding/data/onboarding_repository.dart`) is responsible
/// for treating it as a singleton.
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

  /// Only meaningful when [incomeFrequency] is [IncomeFrequency.periodic].
  /// See [IncomeIntervalType] doc for why this is UI-convenience-only and
  /// never read by the BR-01 formula engine. `ordinal32` (not the default
  /// `ordinal` byte encoding) is required here — Isar's byte-backed enum
  /// storage cannot be nullable, and this field must be nullable for
  /// Mode B profiles where it has no meaning.
  @Enumerated(EnumType.ordinal32)
  IncomeIntervalType? incomeIntervalType;

  /// Only meaningful when [incomeFrequency] is [IncomeFrequency.daily].
  /// Whole-Rupiah int, default 0 per PRD §8. The onboarding wizard (M2)
  /// seeds this with the user's "initial income amount" for Mode B, since
  /// Mode B has no [PayCycle]/`fixedSalary` concept (BR-01 §7.1 reads
  /// recorded daily transactions instead) — the onboarding figure is
  /// treated as a day-zero starting buffer.
  int carryOverBalance = 0;

  /// M2 schema addition: Mode B (daily income) has **no [PayCycle]**
  /// (M1's own doc on `Transaction.payCycleId` says so explicitly — Mode B
  /// "has no PayCycle concept per BR-01"), so there was nowhere to persist
  /// the onboarding wizard's mandatory-expenses list for that mode. PRD
  /// FR-01's acceptance criteria asks for this list regardless of mode
  /// ("Lanjut input income awal + daftar pengeluaran wajib"). Mode A
  /// continues to store its list on the per-cycle [PayCycle.mandatoryExpenses]
  /// (unchanged, reused as-is); this field is Mode B's equivalent home.
  /// Left empty/unused for Mode A profiles.
  List<MandatoryExpenseItem> mandatoryExpenses = [];

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

  /// M2 schema addition: gates entry to Home per FR-01 ("Wajib selesai
  /// sebelum masuk Home"). Did not exist in M1 because M1 was data-layer
  /// only, with no boot/routing sequence yet to gate. `false` by default
  /// so a freshly-created/implicit profile is correctly treated as
  /// "onboarding not done".
  bool onboardingComplete = false;
}
