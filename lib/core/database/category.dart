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
}
