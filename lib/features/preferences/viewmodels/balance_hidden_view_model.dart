import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'balance_hidden_view_model.g.dart';

/// Whether balance figures are masked app-wide. The eye toggle on the
/// dashboard, wallets and per-wallet transactions screens all read and
/// flip this same value, so hiding the balance on one screen hides it
/// on all of them.
@riverpod
class BalanceHidden extends _$BalanceHidden {
  @override
  bool build() => false;

  void toggle() => state = !state;
}
