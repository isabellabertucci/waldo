import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallets_summary_view_model.dart';

part 'transaction_list_view_model.g.dart';

@riverpod
class TransactionListViewModel extends _$TransactionListViewModel {
  @override
  Future<List<Transaction>> build({
    int? walletId,
    SortOrder sortOrder = SortOrder.desc,
  }) async {
    final repo = await ref.watch(transactionRepositoryProvider.future);
    return walletId == null
        ? repo.getAll(sortOrder: sortOrder)
        : repo.getByWallet(walletId, sortOrder: sortOrder);
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
    // The whole family, so the "all transactions" list (no walletId) drops
    // it too, not just this wallet's list.
    ref.invalidate(transactionListViewModelProvider);

    ref.invalidate(walletListViewModelProvider);
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(walletsSummaryViewModelProvider);
  }

  void restoreTransaction() {
    ref.invalidateSelf();
  }
}
