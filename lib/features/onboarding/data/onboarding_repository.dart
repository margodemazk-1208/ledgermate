// Onboarding data layer (M2): writes the wizard's result into the M1
// `LocalProfile`/`PayCycle` Isar collections. Per
// `docs/ARCHITECTURE.md` features "do not import each other's
// `presentation/` layer directly" — this is the only place in the
// onboarding feature that touches Isar directly.
import 'package:isar_community/isar.dart';

import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';

/// Interface extracted so widget tests can override
/// `onboardingRepositoryProvider` with an in-memory fake instead of a real
/// Isar instance — `testWidgets()`'s test binding hangs indefinitely on
/// real Isar async calls (open-ended native isolate round-trip that never
/// completes under `AutomatedTestWidgetsFlutterBinding`; confirmed by
/// direct repro, not merely suspected). See
/// `test/features/onboarding/onboarding_screen_test.dart` for the UI-flow
/// tests that rely on this, and
/// `test/features/onboarding/onboarding_repository_test.dart` for the
/// real-Isar persistence tests, which use plain `test()` (not
/// `testWidgets()`) specifically because that hang doesn't occur there.
abstract class OnboardingRepositoryBase {
  Stream<LocalProfile?> watchProfile();

  Future<void> completeOnboarding({
    required IncomeFrequency incomeFrequency,
    IncomeIntervalType? incomeIntervalType,
    DateTime? nextPaydayDate,
    required int initialIncomeAmount,
    required List<MandatoryExpenseItem> mandatoryExpenses,
  });
}

class OnboardingRepository implements OnboardingRepositoryBase {
  OnboardingRepository(this._isar);

  final Isar _isar;

  /// Reactive stream of the singleton [LocalProfile] row, or `null` if it
  /// doesn't exist yet (fresh install, onboarding never started). Used by
  /// `app.dart` to decide whether to route to Onboarding or Home.
  @override
  Stream<LocalProfile?> watchProfile() {
    return _isar.localProfiles
        .where()
        .watch(fireImmediately: true)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  /// Persists the completed wizard: creates/updates the singleton
  /// [LocalProfile] (PRD §8 — "exactly one `LocalProfile` should exist per
  /// install", enforced here by always reusing the first existing row
  /// instead of inserting a second one) and, for Mode A only, creates the
  /// cycle's initial [PayCycle] row (Mode B has no `PayCycle` concept —
  /// see `pay_cycle.dart`/`local_profile.dart` docs).
  @override
  Future<void> completeOnboarding({
    required IncomeFrequency incomeFrequency,
    IncomeIntervalType? incomeIntervalType,
    DateTime? nextPaydayDate,
    required int initialIncomeAmount,
    required List<MandatoryExpenseItem> mandatoryExpenses,
  }) async {
    await _isar.writeTxn(() async {
      final existing = await _isar.localProfiles.where().findFirst();
      final profile = existing ?? LocalProfile();

      profile.incomeFrequency = incomeFrequency;
      profile.onboardingComplete = true;

      if (incomeFrequency == IncomeFrequency.periodic) {
        profile.incomeIntervalType = incomeIntervalType;
        profile.nextPaydayDate = nextPaydayDate;
        profile.fixedSalary = initialIncomeAmount;
        // Mode A's mandatory-expenses list lives per-cycle on PayCycle,
        // not here — leave LocalProfile's list empty for this mode.
        profile.mandatoryExpenses = [];
      } else {
        // Mode B: no PayCycle/fixedSalary concept (BR-01 §7.1 reads
        // recorded daily transactions instead). The onboarding "initial
        // income amount" seeds carryOverBalance as a day-zero buffer, and
        // the mandatory-expenses list is stored directly on the profile
        // (see field doc in local_profile.dart).
        profile.incomeIntervalType = null;
        profile.nextPaydayDate = null;
        profile.carryOverBalance = initialIncomeAmount;
        profile.mandatoryExpenses = mandatoryExpenses;
      }

      await _isar.localProfiles.put(profile);

      if (incomeFrequency == IncomeFrequency.periodic) {
        final cycle = PayCycle()
          ..startDate = DateTime.now()
          ..paydayDate = nextPaydayDate ?? DateTime.now()
          ..fixedSalary = initialIncomeAmount
          ..variableIncomeTotal = 0
          ..mandatoryExpenses = mandatoryExpenses;
        await _isar.payCycles.put(cycle);
      }
    });
  }
}
