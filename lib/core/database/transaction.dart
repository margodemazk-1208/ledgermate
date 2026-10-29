import 'package:isar_community/isar.dart';

part 'transaction.g.dart';

/// Whether a [Transaction] adds to, subtracts from, or transfers between
/// wallets (FR-02, FR-13, D16).
enum TransactionType { income, expense, transfer }

/// A single recorded income, expense, or inter-wallet transfer (FR-02/FR-03/FR-13).
/// `sync_status` from PRD v1 is deliberately absent — this app is offline-only, see
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
  /// without the caller setting a real category (except for transfers where
  /// category is optional/0).
  int categoryId = 0;

  DateTime date = DateTime.now();

  String? notes;

  /// FK to [PayCycle.id] (plain `int`, see [categoryId] doc). Nullable:
  /// only Mode A (periodic income — see `IncomeFrequency` in
  /// `local_profile.dart`) groups transactions into pay cycles. Mode B
  /// (daily income) has no PayCycle concept, so its transactions leave this
  /// null.
  int? payCycleId;

  /// FK to [Wallet.id] (v1.1, FR-12, D16). Required foreign key.
  /// Pre-v1.1 legacy transactions are backfilled during migration to point to
  /// the default "Dompet Utama" wallet.
  int walletId = 0;

  /// FK to destination [Wallet.id] (v1.1, FR-13, D16). Nullable:
  /// only set when [type] == [TransactionType.transfer].
  int? transferPeerWalletId;

  /// Identifier grouping the transfer action or paired rows (v1.1, D16).
  String? transferGroupId;
}
