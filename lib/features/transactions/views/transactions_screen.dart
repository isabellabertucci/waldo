import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/app_scaffold.dart';

import '../../../core/widgets/empty_state.dart';
import '../models/transaction.dart';
import '../viewmodels/transaction_list_view_model.dart';
import 'widgets/transaction_form_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key, required this.walletId});

  final int walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionsAsync = ref.watch(
      transactionListViewModelProvider(walletId: walletId),
    );

    return AppScaffold(
      appBar: AppBar(title: Text(l10n.transactions)),
      body: switch (transactionsAsync) {
        AsyncError() => Center(child: Text(l10n.transactionsError)),
        AsyncData(:final value) => _TransactionsBody(
          transactions: value,
          walletId: walletId,
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => TransactionFormSheet(initialWalletId: walletId),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TransactionsBody extends ConsumerWidget {
  const _TransactionsBody({required this.transactions, required this.walletId});

  final List<Transaction> transactions;
  final int walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (transactions.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.noTransactionsYet,
        subtitle: l10n.addFirstTransaction,
      );
    }

    final dateFormat = DateFormat.yMMMd();

    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final isIncome = transaction.type == TransactionType.income;
        final color = isIncome ? Colors.green : Colors.red;
        final sign = isIncome ? '+' : '-';
        final description = transaction.description?.trim();

        return ListTile(
          title: Text(
            description == null || description.isEmpty
                ? l10n.transactionDefaultDescription
                : description,
          ),
          subtitle: Text(dateFormat.format(DateTime.parse(transaction.date))),
          trailing: Text(
            '$sign${formatCents(transaction.amount)}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
          onTap: () {
            TransactionDetailRoute(walletId, transaction.id!).push(context);
          },
        );
      },
    );
  }
}
