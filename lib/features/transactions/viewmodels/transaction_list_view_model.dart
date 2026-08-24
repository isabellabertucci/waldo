import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_providers.dart';

part 'transaction_list_view_model.g.dart';

@riverpod
class TransactionListViewModel extends _$TransactionListViewModel {
  @override
  Future<List<Transaction>> build({
    required int walletId,
    SortOrder sortOrder = SortOrder.desc,
  }) async {
    final repo = await ref.watch(transactionRepositoryProvider.future);
    return repo.getByWallet(walletId, sortOrder: sortOrder);
  }

  bool hideTransaction(int id) {
    final current = state.value;
    if (current == null) return false;
    state = AsyncData(current.where((t) => t.id != id).toList());
    return true;
  }

  Future<void> confirmDelete(int id, int walletId) async {
    final repo = await ref.read(transactionRepositoryProvider.future);
    await repo.delete(id);
    ref.invalidateSelf();
    ref.invalidate(walletListViewModelProvider());
    ref.invalidate(walletByIdProvider(walletId));
  }

  void restoreTransaction() {
    ref.invalidateSelf();
  }
}

@riverpod
Future<Transaction?> transactionById(Ref ref, int id) async {
  final repo = await ref.watch(transactionRepositoryProvider.future);
  return repo.getById(id);
}
