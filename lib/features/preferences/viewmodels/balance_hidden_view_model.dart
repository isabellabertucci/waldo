import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'balance_hidden_view_model.g.dart';

/// Whether amounts are masked app-wide (the eye toggle).
@riverpod
class BalanceHidden extends _$BalanceHidden {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
