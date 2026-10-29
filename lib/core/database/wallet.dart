import 'package:isar_community/isar.dart';

part 'wallet.g.dart';

/// A user-defined wallet or financial account (v1.1, FR-12, D16).
///
/// Fully custom by the user (not restricted to Tunai/E-Wallet/Bank enums).
/// Current balance is computed on-the-fly:
/// `startingBalance + sum(transactions referencing this wallet)`
/// and is deliberately NOT stored as a static field.
@collection
class Wallet {
  Id id = Isar.autoIncrement;

  /// User-defined display name (e.g. "Dompet Utama", "BCA", "GoPay").
  String name = '';

  /// Icon key identifier from the app's predefined icon set.
  String icon = 'account_balance_wallet';

  /// Initial starting balance in whole Rupiah when wallet was created.
  int startingBalance = 0;

  /// Whether transactions in this wallet are scoped into the Smart Daily Budget Engine
  /// (BR-04, D16). Defaults to true.
  bool includeInDailyBudget = true;

  DateTime createdAt = DateTime.now();
}
