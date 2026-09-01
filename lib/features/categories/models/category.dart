import 'package:freezed_annotation/freezed_annotation.dart';

part 'category.freezed.dart';

@freezed
abstract class Category with _$Category {
  const Category._();

  const factory Category({
    int? id,
    required String name,
    required String createdAt,
  }) = _Category;

  Map<String, Object?> toMap() {
    return {'id': id, 'name': name, 'created_at': createdAt};
  }

  factory Category.fromMap(Map<String, Object?> map) {
    return Category(
      id: map['id'] as int?,
      name: map['name'] as String,
      createdAt: map['created_at'] as String,
    );
  }
}
