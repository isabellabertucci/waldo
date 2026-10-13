import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallets_summary_view_model.dart';

import 'pending_transaction_deletes.dart';

part 'transaction_list_view_model.g.dart';

@riverpod
class TransactionListViewModel extends _$TransactionListViewModel {
  @override
  Future<List<Transaction>> build({
    int? walletId,
    SortOrder sortOrder = SortOrder.desc,
  }) async {
    final repo = await ref.watch(transactionRepositoryProvider.future);
    final pending = ref.watch(pendingTransactionDeletesProvider);
    final transactions = walletId == null
        ? await repo.getAll(sortOrder: sortOrder)
        : await repo.getByWallet(walletId, sortOrder: sortOrder);
    return transactions.where((t) => !pending.contains(t.id)).toList();
  }

  bool hideTransaction(int id) {
    final current = state.value;
    if (current == null) return false;
    // Hidden here at once, and in every other list through the pending set.
    state = AsyncData(current.where((t) => t.id != id).toList());
    ref.read(pendingTransactionDeletesProvider.notifier).add(id);
    return true;
  }

  Future<void> confirmDelete(int id) async {
    final repo = await ref.read(transactionRepositoryProvider.future);
    await repo.delete(id);
    ref.read(pendingTransactionDeletesProvider.notifier).remove(id);
    // The whole family, so the "all transactions" list (no walletId) drops
    // it too, not just this wallet's list.
    ref.invalidate(transactionListViewModelProvider);

    ref.invalidate(walletListViewModelProvider);
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(walletsSummaryViewModelProvider);
  }

  void restoreTransaction(int id) {
    ref.read(pendingTransactionDeletesProvider.notifier).remove(id);
  }
}
