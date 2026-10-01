import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/empty_state.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../models/transaction.dart';
import '../viewmodels/transaction_list_view_model.dart';
import 'package:waldo/core/widgets/transaction_list_tile.dart';

class AllTransactionsScreen extends ConsumerWidget {
  const AllTransactionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(transactionListViewModelProvider());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactions)),
      body: switch (transactionsAsync) {
        AsyncError() => Center(child: Text(l10n.transactionsError)),
        AsyncData(:final value) => _AllTransactionsBody(transactions: value),
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
      AsyncData(:final value) => value.currency,
      _ => Currency.usd,
    };
    final dateFormatPattern = switch (preferencesAsync) {
      AsyncData(:final value) => value.dateFormat,
      _ => 'yyyy-MM-dd',
    };
    final dateFormat = DateFormat(dateFormatPattern);

    if (transactions.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.noTransactionsYet,
        subtitle: l10n.addFirstTransaction,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.md,
      ),
      separatorBuilder: (context, index) => const SizedBox(height: Spacing.md),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TransactionListTile(
          transaction: transaction,
          currency: currency,
          dateFormat: dateFormat,
          onTap: () {
            TransactionDetailRoute(
              transaction.walletId,
              transaction.id!,
            ).go(context);
          },
        );
      },
    );
  }
}
