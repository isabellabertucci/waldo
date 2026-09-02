import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_list_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_providers.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'widgets/transaction_form_sheet.dart';

enum _TransactionAction { edit, delete }

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
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: context.appColors.surfaceContainer,
              foregroundColor: context.appColors.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Rounded.lg),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: context.appColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Rounded.lg),
              ),
            ),
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
      appBar: AppBar(
        title: Text(l10n.transactions),
        actions: [
          switch (transactionAsync) {
            AsyncData(:final value) when value != null =>
              PopupMenuButton<_TransactionAction>(
                key: const Key('transaction_menu_button'),
                icon: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: context.appColors.surfaceContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    AppIcons.more,
                    size: 20,
                    color: context.appColors.onSurface,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(Rounded.md),
                ),
                onSelected: (action) => switch (action) {
                  _TransactionAction.edit => showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => TransactionFormSheet(transaction: value),
                  ),
                  _TransactionAction.delete => _confirmDelete(
                    context,
                    ref,
                    value,
                  ),
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: _TransactionAction.edit,
                    child: Row(
                      children: [
                        const Icon(AppIcons.edit, size: 18),
                        const SizedBox(width: Spacing.sm),
                        Text(l10n.editTransaction),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: _TransactionAction.delete,
                    child: Row(
                      children: [
                        Icon(
                          AppIcons.delete,
                          size: 18,
                          color: context.appColors.error,
                        ),
                        const SizedBox(width: Spacing.sm),
                        Text(
                          l10n.delete,
                          style: TextStyle(color: context.appColors.error),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            _ => const SizedBox.shrink(),
          },
          const SizedBox(width: Spacing.sm),
        ],
      ),
      body: switch (transactionAsync) {
        AsyncError() => Center(child: Text(l10n.transactionsError)),
        AsyncData(:final value) when value != null => _TransactionDetailBody(
          transaction: value,
        ),
        AsyncData() => Center(child: Text(l10n.transactionsError)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _TransactionDetailBody extends ConsumerWidget {
  const _TransactionDetailBody({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final walletAsync = ref.watch(walletByIdProvider(transaction.walletId));
    final colors = context.appColors;

    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome ? colors.primaryStrong : colors.error;
    final sign = isIncome ? '+' : '-';
    final description = transaction.description?.trim();
    final dateFormat = DateFormat.yMMMd();
    final walletName = switch (walletAsync) {
      AsyncData(:final value) => value?.name ?? '',
      _ => '',
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(Spacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(Spacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isIncome
                              ? Icons.arrow_downward_rounded
                              : Icons.arrow_upward_rounded,
                          color: color,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: Spacing.md),
                      Expanded(
                        child: Text(
                          description == null || description.isEmpty
                              ? l10n.transactionDefaultDescription
                              : description,
                          style: context.textTheme.titleMedium,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: Spacing.lg),
                  Text(
                    '$sign${formatCents(transaction.amount)}',
                    style: context.textTheme.headlineLarge?.copyWith(
                      color: color,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.lg),

          Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.lg,
                vertical: Spacing.sm,
              ),
              child: Column(
                children: [
                  _DetailRow(
                    icon: Icons.calendar_today_outlined,
                    label: l10n.date,
                    value: dateFormat.format(DateTime.parse(transaction.date)),
                  ),
                  Divider(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.12),
                  ),
                  _DetailRow(
                    icon: Icons.account_balance_wallet_outlined,
                    label: l10n.wallet,
                    value: walletName,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.onSurfaceVariant),
          const SizedBox(width: Spacing.sm),
          Text(
            label,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
