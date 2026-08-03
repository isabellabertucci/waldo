import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'wallet_form_state.dart';
import 'wallet_list_view_model.dart';

part 'wallet_form_view_model.g.dart';

@riverpod
class WalletFormViewModel extends _$WalletFormViewModel {
  @override
  WalletFormState build(Wallet? existingWallet) {
    return WalletFormState(
      name: existingWallet?.name ?? '',
      type: existingWallet?.type ?? WalletType.cash,
      startingBalance: existingWallet != null
          ? (existingWallet.startingBalance / 100).toString()
          : '',
    );
  }

  void updateName(String value) {
    state = state.copyWith(name: value, nameError: null);
  }

  void updateType(WalletType value) {
    state = state.copyWith(type: value);
  }

  void updateBalance(String value) {
    state = state.copyWith(startingBalance: value);
  }

  Future<bool> save(Wallet? existingWallet) async {
    if (state.name.trim().isEmpty) {
      state = state.copyWith(nameError: 'Name is required');
      return false;
    }

    final repo = ref.read(walletRepositoryProvider);
    final balanceInCents = ((double.tryParse(state.startingBalance) ?? 0) * 100)
        .round();

    if (existingWallet != null) {
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
          createdAt: DateTime.now().toIso8601String(),
        ),
      );
    }

    ref.invalidate(walletListViewModelProvider);
    return true;
  }
}
