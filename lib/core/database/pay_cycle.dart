import 'package:isar_community/isar.dart';

part 'pay_cycle.g.dart';

/// One mandatory (wajib) expense item entered manually at the start of a
/// pay cycle — e.g. {name: "Kos", amount: 800000} (`docs/PRD.md` §7.2
/// BR-02: no carry-over/template between cycles, re-entered every time by
/// design).
@embedded
class MandatoryExpenseItem {
  String name = '';

  /// Whole-Rupiah int. See decimal-representation note in
  /// `lib/core/database/isar_provider.dart`.
  int amount = 0;
}

/// Mode A (periodic income, see [IncomeFrequency.periodic] in
/// `local_profile.dart`) pay-cycle snapshot: fixed salary, running variable
/// income, and this cycle's manually-entered mandatory expenses (PRD §8).
@collection
class PayCycle {
  Id id = Isar.autoIncrement;

  DateTime startDate = DateTime.now();

  DateTime paydayDate = DateTime.now();

  /// Whole-Rupiah int. See decimal-representation note in
  /// `lib/core/database/isar_provider.dart`.
  int fixedSalary = 0;

  /// Running total — incremented as income [Transaction]s are recorded
  /// against this cycle. Whole-Rupiah int.
  int variableIncomeTotal = 0;

  List<MandatoryExpenseItem> mandatoryExpenses = [];
}
