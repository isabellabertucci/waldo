import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

part 'wallet_list_view_model.g.dart';

@riverpod
class WalletListViewModel extends _$WalletListViewModel {
  @override
  Future<List<Wallet>> build() async {
    final repo = await ref.watch(walletRepositoryProvider.future);
    return repo.getAll();
  }

  void hideWallet(int id) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.where((w) => w.id != id).toList());
  }

  Future<void> confirmDelete(int id) async {
    final repo = await ref.read(walletRepositoryProvider.future);
    await repo.delete(id);
  }

  void restoreWallet() {
    ref.invalidateSelf();
  }
}
