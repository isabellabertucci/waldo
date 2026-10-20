import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'wallet_form_state.dart';
import 'wallet_list_view_model.dart';

part 'wallet_form_view_model.g.dart';

final _log = Logger('waldo.vm.wallet');

@riverpod
class WalletFormViewModel extends _$WalletFormViewModel {
  @override
  WalletFormState build(Wallet? existingWallet) {
    return WalletFormState(
      name: existingWallet?.name ?? '',
      type: existingWallet?.type ?? WalletType.cash,
      startingBalance: existingWallet != null
          ? formatCentsForInput(existingWallet.startingBalance)
          : '',
    );
  }

  void updateName(String value) {
    state = state.copyWith(name: value);
  }

  void updateType(WalletType value) {
    state = state.copyWith(type: value);
  }

  void updateBalance(String value) {
    state = state.copyWith(startingBalance: value);
  }

  /// True while a save is writing, so a double tap can't save twice.
  bool _saving = false;

  Future<bool> save() async {
    if (_saving) return false;
    _saving = true;
    try {
      return await _save();
    } finally {
      _saving = false;
    }
  }

  Future<bool> _save() async {
    // The wallet this form was built for, so save can't target another.
    final existingWallet = this.existingWallet;
    final isEditing = existingWallet != null;
    final allowsNegative = state.type == WalletType.credit;
    final balanceInCents = isEditing
        ? 0
        : (parseToCents(state.startingBalance, allowNegative: allowsNegative) ??
              0);

    final repo = await ref.read(walletRepositoryProvider.future);
    if (isEditing) {
      await repo.update(
        existingWallet.copyWith(name: state.name.trim(), type: state.type),
      );
    } else {
      await repo.insert(
        Wallet(
          name: state.name.trim(),
          type: state.type,
          startingBalance: balanceInCents,
          currentBalance: balanceInCents,
          createdAt: ref.read(clockProvider)().toIso8601String(),
        ),
      );
    }
    _log.info('Wallet save succeeded: isEditing=$isEditing');
    ref.invalidate(walletListViewModelProvider());
    ref.invalidate(dashboardViewModelProvider);
    return true;
  }
}
