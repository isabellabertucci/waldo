import 'package:freezed_annotation/freezed_annotation.dart';
part 'category_form_state.freezed.dart';

@freezed
abstract class CategoryFormState with _$CategoryFormState {
  const factory CategoryFormState({@Default('') String name}) =
      _CategoryFormState;
}
