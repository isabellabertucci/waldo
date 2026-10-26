import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'balance_hidden_view_model.g.dart';

/// Whether amounts are masked app-wide (the eye toggle). Kept alive, so it
/// can't reset while no screen happens to be watching it.
@Riverpod(keepAlive: true)
class BalanceHidden extends _$BalanceHidden {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
