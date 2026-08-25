import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_providers.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'widgets/transaction_form_sheet.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({
    super.key,
    required this.walletId,
    required this.id,
  });

  final int walletId;
  final int id;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Transaction transaction,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteTransaction),
        content: Text(l10n.deleteTransactionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final viewModel = ref.read(
      transactionListViewModelProvider(walletId: walletId).notifier,
    );

    try {
      await viewModel.confirmDelete(transaction.id!);
      if (context.mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.transactionDeleted)),
        );
        TransactionsRoute(walletId).go(context);
      }
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.transactionDeleteError)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final transactionAsync = ref.watch(transactionByIdProvider(id));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.transactions)),
      body: switch (transactionAsync) {
        AsyncError() => Center(child: Text(l10n.transactionsError)),
        AsyncData(:final value) when value != null => _TransactionDetailBody(
          transaction: value,
          onDelete: (t) => _confirmDelete(context, ref, t),
        ),
        AsyncData() => Center(child: Text(l10n.transactionsError)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _TransactionDetailBody extends ConsumerWidget {
  const _TransactionDetailBody({
    required this.transaction,
    required this.onDelete,
  });

  final Transaction transaction;
  final void Function(Transaction transaction) onDelete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final walletAsync = ref.watch(walletByIdProvider(transaction.walletId));

    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;
    final sign = isIncome ? '+' : '-';
    final description = transaction.description?.trim();
    final dateFormat = DateFormat.yMMMd();
    final walletName = switch (walletAsync) {
      AsyncData(:final value) => value?.name ?? '',
      _ => '',
    };

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            description == null || description.isEmpty
                ? l10n.transactionDefaultDescription
                : description,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          Text(
            '$sign${formatCents(transaction.amount)}',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            '${l10n.date}: ${dateFormat.format(DateTime.parse(transaction.date))}',
          ),
          const SizedBox(height: 8),
          Text('${l10n.wallet}: $walletName'),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) =>
                          TransactionFormSheet(transaction: transaction),
                    );
                  },
                  child: Text(l10n.editTransaction),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () => onDelete(transaction),
                  child: Text(l10n.delete),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
