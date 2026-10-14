import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/l10n/app_localizations.dart';

extension TransactionTypeLabel on TransactionType {
  String label(AppLocalizations l10n) {
    return switch (this) {
      TransactionType.income => l10n.transactionTypeIncome,
      TransactionType.expense => l10n.transactionTypeExpense,
    };
  }
}
