import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/enums.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    int? id,
    required String name,
    required CategoryType type,
    required String createdAt,
  }) = _Category;

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'type': type.name, 'created_at': createdAt};
  }

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: CategoryType.values.byName(map['type'] as String),
      createdAt: map['created_at'] as String,
    );
  }
}
