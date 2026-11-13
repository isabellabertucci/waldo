import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/pending_transaction_deletes.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import 'pending_wallet_deletes.dart';
import 'wallets_summary_view_model.dart';

part 'wallet_list_view_model.g.dart';

@riverpod
class WalletListViewModel extends _$WalletListViewModel {
  @override
  Future<List<Wallet>> build({SortOrder sortOrder = SortOrder.desc}) async {
    final repo = await ref.watch(walletRepositoryProvider.future);
    final pending = ref.watch(pendingTransactionDeletesProvider);
    final pendingWallets = ref.watch(pendingWalletDeletesProvider);
    final wallets = await repo.getAll(sortOrder: sortOrder);
    // A delete inside its Undo window is already gone from the balance.
    return [
      for (final w in wallets)
        if (!pendingWallets.contains(w.id))
          w.copyWith(
            currentBalance:
                w.currentBalance -
                pendingBalanceChange(pending, walletId: w.id),
          ),
    ];
  }

  bool hideWallet(int id) {
    final current = state.value;
    if (current == null || !current.any((w) => w.id == id)) return false;
    // Hidden here at once, and everywhere else through the pending set.
    state = AsyncData(current.where((w) => w.id != id).toList());
    ref.read(pendingWalletDeletesProvider.notifier).add(id);
    return true;
  }

  Future<void> confirmDelete(int id) async {
    final repo = await ref.read(walletRepositoryProvider.future);
    await repo.delete(id);
    ref.read(pendingWalletDeletesProvider.notifier).remove(id);
    ref.invalidate(dashboardViewModelProvider);
    ref.invalidate(walletsSummaryViewModelProvider);
    ref.invalidate(transactionListViewModelProvider);
  }

  /// How many transactions go with [id] if it's deleted, for the
  /// confirmation to say so.
  Future<int> transactionCount(int id) async {
    final repo = await ref.read(transactionRepositoryProvider.future);
    return repo.countByWallet(id);
  }

  void restoreWallet(int id) {
    ref.read(pendingWalletDeletesProvider.notifier).remove(id);
  }
}
