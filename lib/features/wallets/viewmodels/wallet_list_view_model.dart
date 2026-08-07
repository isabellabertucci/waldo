import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

part 'wallet_list_view_model.g.dart';

@riverpod
class WalletListViewModel extends _$WalletListViewModel {
  @override
  Future<List<Wallet>> build({SortOrder sortOrder = SortOrder.desc}) async {
    final repo = await ref.watch(walletRepositoryProvider.future);
    return repo.getAll(sortOrder: sortOrder);
  }

  bool hideWallet(int id) {
    final current = state.value;
    if (current == null) return false;
    state = AsyncData(current.where((w) => w.id != id).toList());
    return true;
  }

  Future<void> confirmDelete(int id) async {
    final repo = await ref.read(walletRepositoryProvider.future);
    await repo.delete(id);
  }

  void restoreWallet() {
    ref.invalidateSelf();
  }
}
