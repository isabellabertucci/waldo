import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/enums.dart';

part 'wallet_form_state.freezed.dart';

@freezed
abstract class WalletFormState with _$WalletFormState {
  const factory WalletFormState({
    @Default('') String name,
    @Default(WalletType.cash) WalletType type,
    @Default('') String startingBalance,
    String? nameError,
    String? balanceError,
  }) = _WalletFormState;
}
