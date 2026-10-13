import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/constants/enums.dart';
import 'widgets/date_grouped_transaction_list.dart';
import 'package:waldo/core/widgets/empty_state.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_edit_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../models/transaction.dart';
import '../viewmodels/transaction_list_view_model.dart';

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(transactionListViewModelProvider());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactions)),
      body: switch (transactionsAsync) {
        AsyncValue(:final value?) => _AllTransactionsBody(transactions: value),
        AsyncValue(hasError: true) => Center(
          child: Text(l10n.transactionsError),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _AllTransactionsBody extends ConsumerWidget {
  const _AllTransactionsBody({required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final dateFormatPattern = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.dateFormat,
      _ => 'yyyy-MM-dd',
    };
    final dateFormat = DateFormat(dateFormatPattern);
    final isBalanceHidden = ref.watch(balanceHiddenProvider);

    if (transactions.isEmpty) {
      return EmptyState(
        icon: AppIcons.receipt,
        title: l10n.noTransactionsYet,
        subtitle: l10n.addFirstTransaction,
      );
    }

    return DateGroupedTransactionList(
      transactions: transactions,
      currency: currency,
      dateFormat: dateFormat,
      isAmountHidden: isBalanceHidden,
      onTapTransaction: (transaction) {
        showTransactionEditSheet(context, transaction: transaction);
      },
    );
  }
}
