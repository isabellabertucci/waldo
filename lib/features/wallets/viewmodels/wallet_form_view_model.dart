import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/logging/log.dart';
import 'package:waldo/core/utils/utils.dart';
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

  Future<bool> save(Wallet? existingWallet) async {
    final isEditing = existingWallet != null;
    final allowsNegative = state.type == WalletType.credit;
    final balanceInCents = isEditing
        ? 0
        : (parseToCents(state.startingBalance, allowNegative: allowsNegative) ??
              0);

    try {
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
            createdAt: DateTime.now().toIso8601String(),
          ),
        );
      }
      vmLog.info('Wallet save succeeded: isEditing=$isEditing');
      ref.invalidate(walletListViewModelProvider());
      return true;
    } catch (error, stackTrace) {
      vmLog.severe(
        'Wallet save failed: isEditing=$isEditing',
        error,
        stackTrace,
      );
      rethrow;
    }
  }
}
