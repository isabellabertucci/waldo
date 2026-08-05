import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/enums.dart';

part 'wallet_form_state.freezed.dart';

enum WalletFormError { nameRequired, invalidNumber }

@freezed
abstract class WalletFormState with _$WalletFormState {
  const factory WalletFormState({
    @Default('') String name,
    @Default(WalletType.cash) WalletType type,
    @Default('') String startingBalance,
    WalletFormError? nameError,
    WalletFormError? balanceError,
  }) = _WalletFormState;
}
