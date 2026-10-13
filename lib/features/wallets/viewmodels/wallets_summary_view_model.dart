import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';

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
  final (:income, :expense) = await transactionRepo.monthTotals(now);

  final net = income - expense;
  return WalletsSummary(
    netThisMonth: net,
    keptPercent: income > 0 ? (net / income) * 100 : null,
  );
}
