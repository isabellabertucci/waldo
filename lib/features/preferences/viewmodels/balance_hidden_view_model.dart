import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'preferences_viewmodel.dart';

part 'balance_hidden_view_model.g.dart';

final _log = Logger('waldo.vm.balance_hidden');

/// Whether amounts are masked app-wide (the eye toggle), as saved in the
/// preferences; rebuilt from them whenever a screen asks again.
@riverpod
class BalanceHidden extends _$BalanceHidden {
  @override
  bool build() =>
      ref.watch(preferencesViewModelProvider).value?.isBalanceHidden ?? false;

  /// Flips at once, then saves; a failed save flips it back.
  Future<void> toggle() async {
    final isHidden = !state;
    state = isHidden;
    try {
      await ref
          .read(preferencesViewModelProvider.notifier)
          .setBalanceHidden(isHidden);
    } catch (e) {
      _log.severe('toggle failed: isHidden=$isHidden', e);
      state = !isHidden;
    }
  }
}
