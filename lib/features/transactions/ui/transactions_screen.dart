import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';

import '../../../core/widgets/empty_state.dart';
import '../models/transaction.dart';
import '../viewmodels/transaction_list_view_model.dart';
import 'widgets/transaction_form_sheet.dart';
import 'widgets/transaction_list_tile.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_providers.dart';
import 'package:waldo/l10n/app_localizations.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key, required this.walletId});

  final int walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final walletAsync = ref.watch(walletByIdProvider(walletId));
    final transactionsAsync = ref.watch(
      transactionListViewModelProvider(walletId: walletId),
    );
    final walletName = switch (walletAsync) {
      AsyncData(:final value) => value?.name ?? l10n.transactions,
      _ => l10n.transactions,
    };

    return Scaffold(
      appBar: AppBar(title: Text(walletName)),
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
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currency = switch (preferencesAsync) {
      AsyncData(:final value) => value.currency,
      _ => Currency.usd,
    };
    final dateFormatPattern = switch (preferencesAsync) {
      AsyncData(:final value) => value.dateFormat,
      _ => 'yyyy-MM-dd',
    };

    if (transactions.isEmpty) {
      return EmptyState(
        icon: Icons.receipt_long_outlined,
        title: l10n.noTransactionsYet,
        subtitle: l10n.addFirstTransaction,
      );
    }

    final income = transactions
        .where((t) => t.type == TransactionType.income)
        .fold<int>(0, (sum, t) => sum + t.amount);
    final expense = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold<int>(0, (sum, t) => sum + t.amount);

    final dateFormat = DateFormat(dateFormatPattern);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.md,
            Spacing.md,
            Spacing.md,
            0,
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Transactions',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        _SummaryHeader(income: income, expense: expense, currency: currency),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.md,
            ),
            separatorBuilder: (context, index) =>
                const SizedBox(height: Spacing.md),
            itemCount: transactions.length,
            itemBuilder: (context, index) {
              final transaction = transactions[index];
              return TransactionListTile(
                transaction: transaction,
                currency: currency,
                dateFormat: dateFormat,
                onTap: () {
                  TransactionDetailRoute(
                    walletId,
                    transaction.id!,
                  ).push(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SummaryHeader extends StatelessWidget {
  const _SummaryHeader({
    required this.income,
    required this.expense,
    required this.currency,
  });

  final int income;
  final int expense;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(Spacing.lg, Spacing.lg, Spacing.lg, 0),
      child: Row(
        children: [
          Expanded(
            child: _SummaryStat(
              label: 'Income',
              value:
                  '+${formatCents(income, currencyCode: currency.name.toUpperCase())}',
              color: colors.primaryStrong,
            ),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: _SummaryStat(
              label: 'Expense',
              value:
                  '-${formatCents(expense, currencyCode: currency.name.toUpperCase())}',
              color: colors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.md,
        vertical: Spacing.lg,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: context.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: context.textTheme.titleMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
