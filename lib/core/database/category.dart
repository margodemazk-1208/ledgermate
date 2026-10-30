import 'package:isar_community/isar.dart';

part 'category.g.dart';

/// A transaction category, built-in or user-created (PRD §8).
@collection
class Category {
  Id id = Isar.autoIncrement;

  String name = '';

  /// true for default/built-in categories, false for custom ones the user
  /// created in Settings (FR-09).
  bool isDefault = false;

  /// true for categories the app itself creates to attribute system-
  /// generated bookkeeping transactions (goal withdrawals, Mode B bekel
  /// rollover entries — M16, D18 bug #2/#3) or implicit system categories
  /// such as Income/Pemasukan (M23), never shown in the user-facing
  /// "pick a category" list. Distinct from [isDefault], which is about
  /// user-visible seed categories.
  bool isSystemGenerated = false;
}
