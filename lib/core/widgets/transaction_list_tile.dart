import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/features/transactions/models/transaction.dart';

class TransactionListTile extends StatelessWidget {
  const TransactionListTile({
    super.key,
    required this.transaction,
    required this.currency,
    required this.dateFormat,
    this.onTap,
  });

  final Transaction transaction;
  final Currency currency;
  final DateFormat dateFormat;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isIncome = transaction.type == TransactionType.income;
    final color = isIncome
        ? context.appColors.primaryStrong
        : context.appColors.error;
    final sign = isIncome ? '+' : '-';
    final description = transaction.description?.trim();

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isIncome ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        description == null || description.isEmpty
            ? l10n.transactionDefaultDescription
            : description,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: context.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        dateFormat.format(DateTime.parse(transaction.date)),
        style: context.textTheme.bodySmall?.copyWith(
          color: context.appColors.onSurfaceVariant,
        ),
      ),
      trailing: Text(
        '$sign${formatCents(transaction.amount, currencyCode: currency.code)}',
        style: context.textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
