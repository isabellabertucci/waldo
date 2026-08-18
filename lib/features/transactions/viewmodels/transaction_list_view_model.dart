import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';

part 'transaction_list_view_model.g.dart';

@riverpod
class TransactionListViewModel extends _$TransactionListViewModel {
  @override
  Future<List<Transaction>> build({
    int? walletId,
    SortOrder sortOrder = SortOrder.desc,
  }) async {
    final repo = await ref.watch(transactionRepositoryProvider.future);
    if (walletId != null) {
      return repo.getByWallet(walletId, sortOrder: sortOrder);
    }
    return repo.getAll(sortOrder: sortOrder);
  }

  bool hideTransaction(int id) {
    final current = state.value;
    if (current == null) return false;
    state = AsyncData(current.where((t) => t.id != id).toList());
    return true;
  }

  Future<void> confirmDelete(int id) async {
    final repo = await ref.read(transactionRepositoryProvider.future);
    await repo.delete(id);
  }

  void restoreTransaction() {
    ref.invalidateSelf();
  }
}
