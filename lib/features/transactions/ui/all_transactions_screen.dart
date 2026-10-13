import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/widgets/empty_state.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../models/transaction.dart';
import '../viewmodels/transaction_list_view_model.dart';
import 'widgets/day_grouped_transaction_list.dart';

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
    final categoriesById = switch (ref.watch(categoryListViewModelProvider)) {
      AsyncValue(:final value?) => {
        for (final c in value)
          if (c.id != null) c.id!: c,
      },
      _ => const <int, Category>{},
    };
    final isBalanceHidden = ref.watch(balanceHiddenProvider);

    if (transactions.isEmpty) {
      return EmptyState(
        icon: AppIcons.receipt,
        title: l10n.noTransactionsYet,
        subtitle: l10n.addFirstTransaction,
      );
    }

    return DayGroupedTransactionList(
      transactions: transactions,
      categoriesById: categoriesById,
      currency: currency,
      now: ref.watch(clockProvider)(),
      isAmountHidden: isBalanceHidden,
    );
  }
}
