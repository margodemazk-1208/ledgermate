// Fake Pay Cycle Repository for widget and unit tests.
import 'dart:async';

import 'package:ledgermate/core/database/local_profile.dart';
import 'package:ledgermate/core/database/pay_cycle.dart';
import 'package:ledgermate/core/database/transaction.dart' as db;
import 'package:ledgermate/features/pay_cycle/data/pay_cycle_repository.dart';

class FakePayCycleRepository implements PayCycleRepositoryBase {
  LocalProfile? currentProfile;
  PayCycle? latestCycle;
  List<PayCycle> cycles = [];
  List<db.Transaction> transactions = [];

  final _profileController = StreamController<LocalProfile?>.broadcast();
  final _cycleController = StreamController<PayCycle?>.broadcast();
  final _txsController = StreamController<List<db.Transaction>>.broadcast();

  Object? failWith;
  int modeATransitionCount = 0;
  int modeBTransitionCount = 0;

  void emitProfile(LocalProfile? p) {
    currentProfile = p;
    _profileController.add(p);
  }

  void emitCycle(PayCycle? c) {
    latestCycle = c;
    _cycleController.add(c);
  }

  void emitTransactions(List<db.Transaction> txs) {
    transactions = txs;
    _txsController.add(txs);
  }

  @override
  Stream<LocalProfile?> watchProfile() => _profileController.stream;

  @override
  Future<LocalProfile?> getProfile() async => currentProfile;

  @override
  Stream<PayCycle?> watchLatestPayCycle() => _cycleController.stream;

  @override
  Future<PayCycle?> getLatestPayCycle() async => latestCycle;

  @override
  Future<List<PayCycle>> getAllPayCycles() async => cycles;

  @override
  Stream<List<db.Transaction>> watchTransactions() => _txsController.stream;

  @override
  Future<List<db.Transaction>> getTransactions() async => transactions;

  @override
  Future<void> completeModeATransition({
    required int fixedSalary,
    required DateTime nextPaydayDate,
    IncomeIntervalType? incomeIntervalType,
    required List<MandatoryExpenseItem> mandatoryExpenses,
    DateTime? referenceNow,
  }) async {
    if (failWith != null) {
      final err = failWith!;
      failWith = null;
      throw err;
    }
    modeATransitionCount++;
    final newCycle = PayCycle()
      ..fixedSalary = fixedSalary
      ..paydayDate = nextPaydayDate
      ..startDate = referenceNow ?? DateTime.now()
      ..mandatoryExpenses = mandatoryExpenses;
    latestCycle = newCycle;
    cycles.insert(0, newCycle);
    _cycleController.add(newCycle);

    if (currentProfile != null) {
      currentProfile!.fixedSalary = fixedSalary;
      currentProfile!.nextPaydayDate = nextPaydayDate;
      currentProfile!.mandatoryExpenses = [];
      _profileController.add(currentProfile);
    }
  }

  @override
  Future<void> completeModeBTransition({
    required int carryOverBalance,
    required List<MandatoryExpenseItem> todayMandatoryExpenses,
    int? todayBekelIncome,
    DateTime? referenceNow,
  }) async {
    if (failWith != null) {
      final err = failWith!;
      failWith = null;
      throw err;
    }
    modeBTransitionCount++;
    if (currentProfile != null) {
      currentProfile!.carryOverBalance = carryOverBalance;
      currentProfile!.mandatoryExpenses = todayMandatoryExpenses;
      currentProfile!.lastRolloverDate = referenceNow ?? DateTime.now();
      _profileController.add(currentProfile);
    }
  }

  void dispose() {
    _profileController.close();
    _cycleController.close();
    _txsController.close();
  }
}
