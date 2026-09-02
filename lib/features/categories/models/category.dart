import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    int? id,
    required String name,
    @Default(false) bool isDefault,
    required String createdAt,
  }) = _Category;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'is_default': isDefault ? 1 : 0,
      'created_at': createdAt,
    };
  }

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      isDefault: (map['is_default'] as int?) == 1,
      createdAt: map['created_at'] as String,
    );
  }
}
