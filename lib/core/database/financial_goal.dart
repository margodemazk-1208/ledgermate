import 'package:isar_community/isar.dart';

part 'financial_goal.g.dart';

/// A savings goal (FR-06/FR-06b/FR-06c, BR-03). `currentAmount` auto-accrues
/// daily from `DailySavingsReserve` per BR-03 — that accrual logic itself
/// belongs to the M4 formula engine / M6 goals feature, not this schema.
@collection
class FinancialGoal {
  Id id = Isar.autoIncrement;

  String goalName = '';

  /// Whole-Rupiah int. See decimal-representation note in
  /// `lib/core/database/isar_provider.dart`.
  int targetAmount = 0;

  int currentAmount = 0;

  DateTime targetDate = DateTime.now();

  /// Manual override for the auto-computed
  /// `(targetAmount - currentAmount) / daysRemaining` daily allocation
  /// (BR-03, `docs/PRD.md` §7.3). Null means "use the automatic
  /// calculation"; a value means "use this fixed amount instead until the
  /// user changes or clears it".
  int? manualDailyAllocation;
}
