import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/enums.dart';

part 'transaction_form_state.freezed.dart';

@freezed
abstract class TransactionFormState with _$TransactionFormState {
  const factory TransactionFormState({
    @Default('') String amount,
    @Default(TransactionType.expense) TransactionType type,
    DateTime? date,
    int? walletId,
    int? categoryId,
    @Default('') String description,
  }) = _TransactionFormState;
}
