// Framework-free Smart Daily Budget Engine (BR-01, BR-02, BR-03).
//
// Strictly isolated from Flutter, Riverpod, and Isar per `docs/ARCHITECTURE.md`:
// "core/formulas/ must stay framework-free: plain Dart functions taking
// primitive/model inputs and returning the computed UangJajanAmanHariIni,
// DailySavingsReserve, etc."

import 'dart:math' as math;

/// Goal input data needed for computing daily savings reserve (BR-03, PRD §7.3).
/// Decoupled from Isar's `FinancialGoal` entity to keep formulas framework-free.
class GoalAllocationInput {
  const GoalAllocationInput({
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    this.manualDailyAllocation,
  });

  final int targetAmount;
  final int currentAmount;
  final DateTime targetDate;
  final int? manualDailyAllocation;
}

/// Computed breakdown of Mode A (Periodic / Lump-sum cycle) daily budget.
class ModeABudgetResult {
  const ModeABudgetResult({
    required this.remainingDays,
    required this.remainingBalance,
    required this.dailySpendingAllowance,
    required this.dailySavingsReserve,
    required this.uangJajanAmanHariIni,
  });

  /// Days remaining in the cycle inclusive of today (clamped to min 1).
  final int remainingDays;

  /// (fixedIncome + additionalIncome) - mandatoryExpenses - recordedExpenses.
  final int remainingBalance;

  /// RemainingBalance / RemainingDays before deducting savings reserve.
  final int dailySpendingAllowance;

  /// Sum of active goal daily savings allocations.
  final int dailySavingsReserve;

  /// Final safe spend amount for today: dailySpendingAllowance - dailySavingsReserve.
  final int uangJajanAmanHariIni;
}

/// Computed breakdown of Mode B (Daily / Pocket money / Bekel) daily budget.
class ModeBBudgetResult {
  const ModeBBudgetResult({
    required this.saldoCarryOver,
    required this.bekelHariIni,
    required this.pengeluaranWajibHariIni,
    required this.pengeluaranHariIni,
    required this.dailySavingsReserve,
    required this.uangJajanAmanHariIni,
  });

  /// Accumulated unspent buffer from previous days (never resets to zero).
  final int saldoCarryOver;

  /// Pocket money / income logged today (0 on irregular days without income).
  final int bekelHariIni;

  /// Mandatory daily expense for today (e.g. transport).
  final int pengeluaranWajibHariIni;

  /// Total expense transactions recorded today.
  final int pengeluaranHariIni;

  /// Sum of active goal daily savings allocations.
  final int dailySavingsReserve;

  /// Final safe spend amount for today:
  /// saldoCarryOver + bekelHariIni - pengeluaranWajibHariIni - pengeluaranHariIni - dailySavingsReserve.
  final int uangJajanAmanHariIni;
}

/// Normalizes a [DateTime] to calendar day midnight (00:00:00).
DateTime normalizeDate(DateTime date) {
  return DateTime(date.year, date.month, date.day);
}

/// Checks whether two [DateTime]s fall on the exact same calendar day
/// (year, month, day), ignoring time-of-day. Shared by every feature that
/// buckets transactions by day (Mode B budget calc, carry-over catch-up,
/// FR-03 delete restriction) — see `docs/DECISIONS.md` D18/M16.
bool isSameCalendarDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

/// Calculates `RemainingDays` for Mode A (PRD §7.1):
/// Number of days from [today] until [nextPaydayDate] (inclusive of today).
///
/// If today is the last day before next payday, returns 1.
/// If [today] >= [nextPaydayDate] (cycle due or overdue), safely clamps to 1
/// to prevent division by zero or negative days during M4.
int calculateRemainingDays(DateTime today, DateTime nextPaydayDate) {
  final todayMidnight = normalizeDate(today);
  final paydayMidnight = normalizeDate(nextPaydayDate);
  final diffDays = paydayMidnight.difference(todayMidnight).inDays;
  return diffDays <= 0 ? 1 : diffDays;
}

/// Calculates days remaining to a goal target date from [today].
/// Clamps to at least 1 if target date is today or past, preventing division by zero.
int calculateDaysToGoalDate(DateTime today, DateTime targetDate) {
  final todayMidnight = normalizeDate(today);
  final targetMidnight = normalizeDate(targetDate);
  final diffDays = targetMidnight.difference(todayMidnight).inDays;
  return diffDays <= 0 ? 1 : diffDays;
}

/// Calculates daily savings allocation for a single goal (BR-03, PRD §7.3).
///
/// Rules:
/// - If [manualDailyAllocation] is set, use that value directly (user override).
/// - If the goal is already fulfilled ([currentAmount] >= [targetAmount]), allocation is 0.
/// - Otherwise: `(targetAmount - currentAmount) / SisaHariKeTargetDate`.
/// - Rounding rule: Savings allocation is rounded UP (ceil) so the goal target
///   is fully reached on or before the target date without falling short from truncation.
int calculateGoalDailyAllocation({
  required int targetAmount,
  required int currentAmount,
  required DateTime targetDate,
  required DateTime today,
  int? manualDailyAllocation,
}) {
  if (manualDailyAllocation != null) {
    return math.max(0, manualDailyAllocation);
  }
  if (currentAmount >= targetAmount || targetAmount <= 0) {
    return 0;
  }

  final remaining = targetAmount - currentAmount;
  final days = calculateDaysToGoalDate(today, targetDate);

  // Round up (ceil) so daily savings target is achieved by targetDate.
  return (remaining / days).ceil();
}

/// Sums daily savings reserve across all active goals (BR-03, PRD §7.1 & §7.3).
int calculateDailySavingsReserve({
  required List<GoalAllocationInput> goals,
  required DateTime today,
}) {
  var total = 0;
  for (final goal in goals) {
    total += calculateGoalDailyAllocation(
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount,
      targetDate: goal.targetDate,
      today: today,
      manualDailyAllocation: goal.manualDailyAllocation,
    );
  }
  return total;
}

/// Calculates RemainingBalance for Mode A (PRD §7.1):
/// (IncomeTetapSiklusIni + TotalIncomeTambahanYangSudahMasuk)
/// - TotalPengeluaranWajibSiklusIni
/// - TotalPengeluaranHarianYangSudahDicatatSiklusIni
int calculateRemainingBalance({
  required int fixedIncome,
  required int additionalIncome,
  required int mandatoryExpenses,
  required int recordedExpenses,
}) {
  return (fixedIncome + additionalIncome) -
      mandatoryExpenses -
      recordedExpenses;
}

/// Mode A — Periodik (BR-01, PRD §7.1):
/// `RemainingDays = days until next payday (inclusive of today)`
/// `RemainingBalance = (FixedIncome + AdditionalIncome) - Mandatory - RecordedExpenses`
/// `DailySavingsReserve = sum of active goals daily allocations`
/// `UangJajanAmanHariIni = (RemainingBalance / RemainingDays) - DailySavingsReserve`
///
/// Integer-money discipline & Rounding Rule:
/// Daily spending allowance is rounded down (floor) to whole Rupiah so the user
/// never overspends fractional Rupiah; unspent remainders safely accumulate in
/// the remaining balance for subsequent days.
ModeABudgetResult calculateModeABudget({
  required int fixedIncome,
  required int additionalIncome,
  required int mandatoryExpenses,
  required int recordedExpenses,
  required int remainingDays,
  required int dailySavingsReserve,
}) {
  final safeRemainingDays = remainingDays <= 0 ? 1 : remainingDays;
  final remainingBalance = calculateRemainingBalance(
    fixedIncome: fixedIncome,
    additionalIncome: additionalIncome,
    mandatoryExpenses: mandatoryExpenses,
    recordedExpenses: recordedExpenses,
  );

  // Round down (floor) to whole Rupiah so the user never overspends fractional Rupiah.
  final dailySpendingAllowance = (remainingBalance / safeRemainingDays).floor();
  final uangJajanAmanHariIni = dailySpendingAllowance - dailySavingsReserve;

  return ModeABudgetResult(
    remainingDays: safeRemainingDays,
    remainingBalance: remainingBalance,
    dailySpendingAllowance: dailySpendingAllowance,
    dailySavingsReserve: dailySavingsReserve,
    uangJajanAmanHariIni: uangJajanAmanHariIni,
  );
}

/// Mode B — Harian (BR-01, PRD §7.1):
/// `SaldoCarryOver = accumulated safe allowance from previous days (never resets to zero)`
/// `UangJajanAmanHariIni = SaldoCarryOver + BekelHariIni - PengeluaranWajibHariIni - PengeluaranHariIni - DailySavingsReserve`
ModeBBudgetResult calculateModeBBudget({
  required int saldoCarryOver,
  required int bekelHariIni,
  required int pengeluaranWajibHariIni,
  required int pengeluaranHariIni,
  required int dailySavingsReserve,
}) {
  final uangJajanAmanHariIni =
      saldoCarryOver +
      bekelHariIni -
      pengeluaranWajibHariIni -
      pengeluaranHariIni -
      dailySavingsReserve;

  return ModeBBudgetResult(
    saldoCarryOver: saldoCarryOver,
    bekelHariIni: bekelHariIni,
    pengeluaranWajibHariIni: pengeluaranWajibHariIni,
    pengeluaranHariIni: pengeluaranHariIni,
    dailySavingsReserve: dailySavingsReserve,
    uangJajanAmanHariIni: uangJajanAmanHariIni,
  );
}

/// Advances carry-over balance from one day to the next for Mode B.
///
/// In Mode B, any leftover `UangJajanAmanHariIni` at the end of the day
/// carries over directly into tomorrow's `SaldoCarryOver` (accumulative,
/// never resets to zero, absorbs deficits if overspent).
int calculateNextDayCarryOver(int currentUangJajanAmanHariIni) {
  return currentUangJajanAmanHariIni;
}

/// Checks whether a Mode A pay cycle has reached its boundary / expired (FR-05).
///
/// A cycle expires when [today] (normalized to midnight) is on or after
/// [paydayDate] (normalized to midnight).
bool isModeACycleExpired({
  required DateTime today,
  required DateTime paydayDate,
}) {
  final todayMidnight = normalizeDate(today);
  final paydayMidnight = normalizeDate(paydayDate);
  return !todayMidnight.isBefore(paydayMidnight);
}

/// Checks whether a new calendar day has started for Mode B daily rollover (FR-05).
///
/// Returns true if [today] (normalized to midnight) is strictly after
/// [lastRolloverDate] (normalized to midnight), or if [lastRolloverDate] is null
/// and at least one transaction was recorded on a previous calendar day.
bool isModeBDailyRolloverDue({
  required DateTime today,
  DateTime? lastRolloverDate,
  List<DateTime> transactionDates = const [],
}) {
  final todayMidnight = normalizeDate(today);
  if (lastRolloverDate != null) {
    return todayMidnight.isAfter(normalizeDate(lastRolloverDate));
  }
  if (transactionDates.isNotEmpty) {
    final latestTx = transactionDates.reduce((a, b) => a.isAfter(b) ? a : b);
    return todayMidnight.isAfter(normalizeDate(latestTx));
  }
  return false;
}
