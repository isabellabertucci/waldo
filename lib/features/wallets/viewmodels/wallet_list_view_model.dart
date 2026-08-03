import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

part 'wallet_list_view_model.g.dart';

@riverpod
class WalletListViewModel extends _$WalletListViewModel {
  @override
  Future<List<Wallet>> build() async {
    final repo = ref.watch(walletRepositoryProvider);
    return repo.getAll();
  }

  Future<void> deleteWallet(int id) async {
    final repo = ref.read(walletRepositoryProvider);
    await repo.delete(id);
    ref.invalidateSelf();
  }
}
