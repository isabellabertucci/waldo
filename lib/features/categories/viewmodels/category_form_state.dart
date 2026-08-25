import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/enums.dart';

part 'category_form_state.freezed.dart';

@freezed
abstract class CategoryFormState with _$CategoryFormState {
  const factory CategoryFormState({
    @Default('') String name,
    @Default(CategoryType.groceries) CategoryType type,
  }) = _CategoryFormState;
}
