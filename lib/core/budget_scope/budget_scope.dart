// Shared "which transactions count toward the Smart Daily Budget Engine"
// helper (BR-01 §7.1, BR-04 §7.4, D16, D18/M16 bug #4 & #7).
//
// Before M16, four separate call sites each reimplemented their own
// transfer-exclusion / wallet-scoping filtering logic: Home's budget
// calculation (`budget_engine/application/budget_providers.dart`), Mode B's
// carry-over math (`pay_cycle/application/pay_cycle_providers.dart`), the
// limit-exceeded alert hook (`notifications/application/limit_alert_hook.dart`),
// and the goal-realism-warning check (`goals/application/goals_providers.dart`).
// They drifted out of sync with each other (exactly bugs #4 and #7 in
// `docs/DECISIONS.md` D18) — this file is the SINGLE source of truth all
// four now call into. Do not add a fifth reimplementation; extend this file.
//
// Deliberately NOT placed under `core/formulas/` — that module must stay
// 100% framework-free per `docs/ARCHITECTURE.md` (plain primitives only),
// while this helper operates directly on the Isar `Transaction`/`Wallet`
// models, same tier as `features/*/data/*_repository.dart`.

import '../database/transaction.dart' as db;
import '../database/wallet.dart';
import '../formulas/daily_budget_formulas.dart';
import '../database/pay_cycle.dart' show MandatoryExpenseItem;

/// The net budget-relevant income/expense contributed by a single
/// transaction, honoring BR-04 wallet scoping and D16's transfer-exclusion
/// rule:
/// - income/expense in an included wallet counts normally.
/// - income/expense in a non-included wallet counts as zero.
/// - a transfer entirely within included wallets (or entirely outside them)
///   is NET ZERO — it never counts as income or expense (D16).
/// - a transfer crossing the scope boundary counts as an expense (leaving
///   the budget-scoped pool) or income (entering it) for the amount that
///   actually crosses — this is intentional per BR-04, not a bug.
class BudgetTransactionEffect {
  const BudgetTransactionEffect({this.income = 0, this.expense = 0});

  final int income;
  final int expense;

  static const zero = BudgetTransactionEffect();
}

/// Computes the wallet-id set with `includeInDailyBudget == true` from a
/// loaded [Wallet] list. Returns `null` only when [wallets] is empty
/// (pre-migration/legacy data with no Wallet rows at all, or wallets simply
/// haven't been seeded yet) — callers treat `null` as "no scoping known,
/// include everything" per the existing `computeDailyBudgetSummary`
/// contract. Callers that can distinguish "wallets still loading" from
/// "wallets genuinely empty" must gate on the loading state themselves
/// BEFORE calling this (see bug #8 — this helper cannot tell the two apart).
Set<int>? includedWalletIdsFrom(List<Wallet> wallets) {
  if (wallets.isEmpty) return null;
  return wallets.where((w) => w.includeInDailyBudget).map((w) => w.id).toSet();
}

/// Returns true if [walletId] is in-scope for the budget, given
/// [includedWalletIds] (`null` means "no scoping — everything included").
bool isWalletBudgetScoped(int? walletId, Set<int>? includedWalletIds) {
  if (includedWalletIds == null) return true;
  if (walletId == null) return false;
  return includedWalletIds.contains(walletId);
}

/// Computes [tx]'s budget effect per the rules documented on
/// [BudgetTransactionEffect].
BudgetTransactionEffect budgetEffectOf(
  db.Transaction tx, {
  required Set<int>? includedWalletIds,
}) {
  switch (tx.type) {
    case db.TransactionType.income:
      return isWalletBudgetScoped(tx.walletId, includedWalletIds)
          ? BudgetTransactionEffect(income: tx.amount)
          : BudgetTransactionEffect.zero;
    case db.TransactionType.expense:
      return isWalletBudgetScoped(tx.walletId, includedWalletIds)
          ? BudgetTransactionEffect(expense: tx.amount)
          : BudgetTransactionEffect.zero;
    case db.TransactionType.transfer:
      final fromIncluded = isWalletBudgetScoped(tx.walletId, includedWalletIds);
      final toIncluded = isWalletBudgetScoped(
        tx.transferPeerWalletId,
        includedWalletIds,
      );
      if (fromIncluded && !toIncluded) {
        return BudgetTransactionEffect(expense: tx.amount);
      } else if (!fromIncluded && toIncluded) {
        return BudgetTransactionEffect(income: tx.amount);
      }
      return BudgetTransactionEffect.zero; // net-neutral per D16
  }
}

/// Summed income/expense totals across a filtered transaction set.
class BudgetTransactionTotals {
  const BudgetTransactionTotals({required this.income, required this.expense});

  final int income;
  final int expense;

  static const zero = BudgetTransactionTotals(income: 0, expense: 0);
}

/// Sums budget-scoped income/expense across [transactions] matching
/// [predicate] (e.g. "same calendar day" or "within this pay cycle"),
/// applying BR-04 wallet scoping and D16 transfer-exclusion via
/// [budgetEffectOf]. This is the ONE place all 4 call sites listed in the
/// file header must route through — see D18/M16 bug #4 & #7.
BudgetTransactionTotals sumBudgetScopedTransactions({
  required List<db.Transaction> transactions,
  required Set<int>? includedWalletIds,
  required bool Function(db.Transaction tx) predicate,
}) {
  var income = 0;
  var expense = 0;
  for (final tx in transactions) {
    if (!predicate(tx)) continue;
    final effect = budgetEffectOf(tx, includedWalletIds: includedWalletIds);
    income += effect.income;
    expense += effect.expense;
  }
  return BudgetTransactionTotals(income: income, expense: expense);
}

/// Advances Mode B's `SaldoCarryOver` by exactly one elapsed calendar [day],
/// using that day's budget-scoped bekel/expense totals (BR-01 §7.1, BR-04).
/// Shared by both the automatic background catch-up job
/// (`core/accrual/daily_accrual_service.dart`) and the manual Pay Cycle
/// Transition screen's preview calculation
/// (`features/pay_cycle/application/pay_cycle_providers.dart`) so the two
/// never drift into two different implementations of the same math
/// (D18/M16 bug #4).
int advanceModeBCarryOverOneDay({
  required int startingCarryOver,
  required DateTime day,
  required List<db.Transaction> transactions,
  required Set<int>? includedWalletIds,
  required List<MandatoryExpenseItem> mandatoryExpensesForDay,
  required List<GoalAllocationInput> goals,
}) {
  final totals = sumBudgetScopedTransactions(
    transactions: transactions,
    includedWalletIds: includedWalletIds,
    predicate: (tx) => isSameCalendarDay(tx.date, day),
  );

  final pengeluaranWajib = mandatoryExpensesForDay.fold<int>(
    0,
    (sum, item) => sum + item.amount,
  );

  final dailySavingsReserve = calculateDailySavingsReserve(
    goals: goals,
    today: day,
  );

  final dayBudget = calculateModeBBudget(
    saldoCarryOver: startingCarryOver,
    bekelHariIni: totals.income,
    pengeluaranWajibHariIni: pengeluaranWajib,
    pengeluaranHariIni: totals.expense,
    dailySavingsReserve: dailySavingsReserve,
  );

  return calculateNextDayCarryOver(dayBudget.uangJajanAmanHariIni);
}

/// Advances Mode B's carry-over across every full day strictly between
/// [fromDateExclusive] and [toDateInclusive] (both normalized to calendar
/// days), catching up multiple skipped days in order instead of only the
/// single most-recent one (D18/M16 bug #4c). If no full days have elapsed,
/// returns [startingCarryOver] unchanged.
int advanceModeBCarryOverAcrossDays({
  required int startingCarryOver,
  required DateTime fromDateExclusive,
  required DateTime toDateInclusive,
  required List<db.Transaction> transactions,
  required Set<int>? includedWalletIds,
  required List<MandatoryExpenseItem> mandatoryExpensesForDay,
  required List<GoalAllocationInput> goals,
}) {
  var carryOver = startingCarryOver;
  var cursor = normalizeDate(fromDateExclusive).add(const Duration(days: 1));
  final end = normalizeDate(toDateInclusive);
  while (!cursor.isAfter(end)) {
    carryOver = advanceModeBCarryOverOneDay(
      startingCarryOver: carryOver,
      day: cursor,
      transactions: transactions,
      includedWalletIds: includedWalletIds,
      mandatoryExpensesForDay: mandatoryExpensesForDay,
      goals: goals,
    );
    cursor = cursor.add(const Duration(days: 1));
  }
  return carryOver;
}
