import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/transactions/viewmodels/pending_transaction_deletes.dart';

part 'wallets_summary_view_model.g.dart';

/// This calendar month's income/expense across all wallets, independent of
/// the dashboard's selected month.
class WalletsSummary {
  const WalletsSummary({required this.netThisMonth, required this.keptPercent});

  final int netThisMonth;

  /// [netThisMonth] as a percentage of this month's income ("Kept 40%"), or
  /// null when there's no income yet to compute a percentage from.
  final double? keptPercent;
}

@riverpod
Future<WalletsSummary> walletsSummaryViewModel(Ref ref) async {
  final transactionRepo = await ref.watch(transactionRepositoryProvider.future);
  final now = ref.watch(clockProvider)();
  // Summed in SQL, so it doesn't load every transaction ever saved.
  final totals = await transactionRepo.monthTotals(now);
  // Deletes inside their Undo window are already gone from the month.
  bool inThisMonth(Transaction t) {
    final date = DateTime.parse(t.date);
    return date.year == now.year && date.month == now.month;
  }

  final pending = ref
      .watch(pendingTransactionDeletesProvider)
      .values
      .where(inThisMonth);
  int pendingOf(TransactionType type) =>
      pending.where((t) => t.type == type).fold(0, (sum, t) => sum + t.amount);
  final income = totals.income - pendingOf(TransactionType.income);
  final expense = totals.expense - pendingOf(TransactionType.expense);

  final net = income - expense;
  return WalletsSummary(
    netThisMonth: net,
    keptPercent: income > 0 ? (net / income) * 100 : null,
  );
}
