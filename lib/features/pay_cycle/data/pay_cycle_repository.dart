// Pay Cycle data layer (M5): handles cycle rollover, transition persistence,
// and query access for PayCycle and LocalProfile collections (FR-05, BR-02).

import 'package:isar_community/isar.dart';

import '../../../core/database/isar_provider.dart';
import '../../../core/database/local_profile.dart';
import '../../../core/database/pay_cycle.dart';
import '../../../core/database/transaction.dart' as db;
import '../../notifications/application/pay_cycle_notification_hook.dart';

/// Abstract interface for Pay Cycle repository, allowing fake implementations
/// in widget/unit tests to avoid real Isar hanging under testWidgets().
abstract class PayCycleRepositoryBase {
  Stream<LocalProfile?> watchProfile();
  Future<LocalProfile?> getProfile();

  Stream<PayCycle?> watchLatestPayCycle();
  Future<PayCycle?> getLatestPayCycle();
  Future<List<PayCycle>> getAllPayCycles();

  Stream<List<db.Transaction>> watchTransactions();
  Future<List<db.Transaction>> getTransactions();

  /// Completes Mode A (Periodik) cycle transition by creating a brand-new [PayCycle]
  /// and updating [LocalProfile] with the new cycle's payday and salary.
  ///
  /// Historical [PayCycle] rows are NEVER deleted or overwritten (M8 analytics integrity).
  Future<void> completeModeATransition({
    required int fixedSalary,
    required DateTime nextPaydayDate,
    IncomeIntervalType? incomeIntervalType,
    required List<MandatoryExpenseItem> mandatoryExpenses,
    DateTime? referenceNow,
  });

  /// Completes Mode B (Daily/Bekel) daily rollover by updating [LocalProfile.carryOverBalance],
  /// replacing today's [LocalProfile.mandatoryExpenses] per BR-02, and updating [lastRolloverDate].
  /// Optionally logs today's bekel income transaction if provided.
  Future<void> completeModeBTransition({
    required int carryOverBalance,
    required List<MandatoryExpenseItem> todayMandatoryExpenses,
    int? todayBekelIncome,
    DateTime? referenceNow,
  });
}

class PayCycleRepository implements PayCycleRepositoryBase {
  PayCycleRepository(this._isar, this._notificationHook);

  final Isar _isar;
  final PayCycleNotificationHook _notificationHook;

  @override
  Stream<LocalProfile?> watchProfile() {
    return _isar.localProfiles
        .where()
        .watch(fireImmediately: true)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  @override
  Future<LocalProfile?> getProfile() {
    return _isar.localProfiles.where().findFirst();
  }

  @override
  Stream<PayCycle?> watchLatestPayCycle() {
    return _isar.payCycles
        .where()
        .sortByStartDateDesc()
        .watch(fireImmediately: true)
        .map((rows) => rows.isEmpty ? null : rows.first);
  }

  @override
  Future<PayCycle?> getLatestPayCycle() {
    return _isar.payCycles.where().sortByStartDateDesc().findFirst();
  }

  @override
  Future<List<PayCycle>> getAllPayCycles() {
    return _isar.payCycles.where().sortByStartDateDesc().findAll();
  }

  @override
  Stream<List<db.Transaction>> watchTransactions() {
    return _isar.transactions.where().sortByDateDesc().watch(
      fireImmediately: true,
    );
  }

  @override
  Future<List<db.Transaction>> getTransactions() {
    return _isar.transactions.where().sortByDateDesc().findAll();
  }

  @override
  Future<void> completeModeATransition({
    required int fixedSalary,
    required DateTime nextPaydayDate,
    IncomeIntervalType? incomeIntervalType,
    required List<MandatoryExpenseItem> mandatoryExpenses,
    DateTime? referenceNow,
  }) async {
    final now = referenceNow ?? DateTime.now();

    await _isar.writeTxn(() async {
      final existing = await _isar.localProfiles.where().findFirst();
      final profile = existing ?? LocalProfile();

      profile.fixedSalary = fixedSalary;
      profile.nextPaydayDate = nextPaydayDate;
      if (incomeIntervalType != null) {
        profile.incomeIntervalType = incomeIntervalType;
      }
      profile.mandatoryExpenses = [];
      profile.lastRolloverDate = null;

      await _isar.localProfiles.put(profile);

      // Create NEW PayCycle row without touching historical rows
      final newCycle = PayCycle()
        ..startDate = now
        ..paydayDate = nextPaydayDate
        ..fixedSalary = fixedSalary
        ..variableIncomeTotal = 0
        ..mandatoryExpenses = mandatoryExpenses;

      await _isar.payCycles.put(newCycle);
    });

    await _notificationHook.onPayCycleStarted(
      incomeFrequency: IncomeFrequency.periodic,
      nextPaydayDate: nextPaydayDate,
      incomeAmount: fixedSalary,
    );
  }

  @override
  Future<void> completeModeBTransition({
    required int carryOverBalance,
    required List<MandatoryExpenseItem> todayMandatoryExpenses,
    int? todayBekelIncome,
    DateTime? referenceNow,
  }) async {
    final now = referenceNow ?? DateTime.now();

    // Resolved BEFORE opening the write transaction below (matches the
    // established pattern in `TransactionRepository.saveTransaction`). D18/
    // M16 bug #3: previously this transaction was written with
    // `walletId == 0` (never reaches a budget-included wallet, so today's
    // bekel never reached the Home number) and category "Makan" (whatever
    // category happened to be first) — both replaced with real, resolved
    // values. Only resolved when actually needed, to avoid creating a
    // system category/wallet on every rollover that logs no bekel.
    int? walletId;
    int? catId;
    if (todayBekelIncome != null && todayBekelIncome > 0) {
      walletId = await resolveDefaultWalletId(_isar);
      catId = await resolveSystemCategoryId(_isar);
    }

    await _isar.writeTxn(() async {
      final existing = await _isar.localProfiles.where().findFirst();
      final profile = existing ?? LocalProfile();

      profile.carryOverBalance = carryOverBalance;
      profile.mandatoryExpenses = todayMandatoryExpenses;
      profile.lastRolloverDate = now;

      await _isar.localProfiles.put(profile);

      if (todayBekelIncome != null && todayBekelIncome > 0) {
        final tx = db.Transaction()
          ..type = db.TransactionType.income
          ..amount = todayBekelIncome
          ..categoryId = catId!
          ..walletId = walletId!
          ..date = now
          ..createdAt = now
          ..notes = 'Bekel hari ini';

        await _isar.transactions.put(tx);
      }
    });

    await _notificationHook.onPayCycleStarted(
      incomeFrequency: IncomeFrequency.daily,
      nextPaydayDate: null,
      incomeAmount: todayBekelIncome ?? 0,
    );
  }
}
