import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/utils.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    int? id,
    required String name,
    @Default(false) bool isDefault,
    // Custom categories are named by the user; their type only matters for
    // built-ins, so it defaults to the catch-all.
    @Default(CategoryType.others) CategoryType type,
    required String createdAt,
  }) = _Category;

  Map<String, Object?> toMap() {
    return {
      CategoriesTable.id: id,
      CategoriesTable.name: name,
      CategoriesTable.nameKey: nameKey(name),
      CategoriesTable.isDefault: isDefault ? 1 : 0,
      CategoriesTable.type: type.name,
      CategoriesTable.createdAt: createdAt,
    };
  }

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      isDefault: (map['is_default'] as int?) == 1,
      type: CategoryType.values.byName(map['type'] as String),
      createdAt: map['created_at'] as String,
    );
  }
}
