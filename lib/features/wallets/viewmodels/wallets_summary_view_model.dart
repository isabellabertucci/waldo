import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';

part 'wallets_summary_view_model.g.dart';

/// This calendar month's income/expense across all wallets, independent of
/// the dashboard's selected month.
class WalletsSummary {
  const WalletsSummary({
    required this.savedThisMonth,
    required this.savedPercent,
  });

  final int savedThisMonth;

  /// Saved amount as a percentage of this month's income, or null when
  /// there's no income yet this month to compute a percentage from.
  final double? savedPercent;
}

@riverpod
Future<WalletsSummary> walletsSummaryViewModel(Ref ref) async {
  final transactionRepo = await ref.watch(transactionRepositoryProvider.future);
  final transactions = await transactionRepo.getAll();
  final now = ref.watch(clockProvider)();

  var income = 0;
  var expense = 0;
  for (final t in transactions) {
    final date = DateTime.parse(t.date);
    if (date.year != now.year || date.month != now.month) continue;
    if (t.type == TransactionType.income) {
      income += t.amount;
    } else {
      expense += t.amount;
    }
  }

  final saved = income - expense;
  return WalletsSummary(
    savedThisMonth: saved,
    savedPercent: income > 0 ? (saved / income) * 100 : null,
  );
}
