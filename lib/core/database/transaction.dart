import 'package:isar_community/isar.dart';

part 'transaction.g.dart';

/// Whether a [Transaction] adds to or subtracts from available balance
/// (FR-02).
enum TransactionType { income, expense }

/// A single recorded income or expense (FR-02/FR-03). `sync_status` from
/// PRD v1 is deliberately absent — this app is offline-only, see
/// `docs/PRD.md` §8 and §10 changelog.
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @enumerated
  TransactionType type = TransactionType.expense;

  /// Whole-Rupiah int, always non-negative — [type] carries the sign, not
  /// this field. See decimal-representation note in
  /// `lib/core/database/isar_provider.dart`.
  int amount = 0;

  /// FK to [Category.id]. Plain `int`, not Isar's `Id` type — Isar only
  /// allows one `Id`-typed property per collection (the primary key), so
  /// foreign keys to other collections' ids are stored as `int`. 0 is not a
  /// valid category id (Isar auto-increment starts at 1); the default is a
  /// deliberately-invalid sentinel so a transaction can never be persisted
  /// without the caller setting a real category.
  int categoryId = 0;

  DateTime date = DateTime.now();

  String? notes;

  /// FK to [PayCycle.id] (plain `int`, see [categoryId] doc). Nullable:
  /// only Mode A (periodic income — see `IncomeFrequency` in
  /// `local_profile.dart`) groups transactions into pay cycles. Mode B
  /// (daily income) has no PayCycle concept, so its transactions leave this
  /// null.
  int? payCycleId;
}
