import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/amount_input_formatter.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/l10n/app_localizations.dart';

import 'transaction_type_toggle.dart';

/// Expense/Income over the amount, typed with the system keyboard. The new
/// and edit sheets share it, so the amount works the same in both.
class TransactionAmountCard extends ConsumerWidget {
  const TransactionAmountCard({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.controller,
    required this.onChanged,
    this.fieldKey,
    this.autofocus = false,
  });

  final TransactionType type;
  final ValueChanged<TransactionType> onTypeChanged;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Key? fieldKey;

  /// The new sheet opens with the keyboard on the amount, the one thing
  /// every transaction needs.
  final bool autofocus;

  /// An empty, zero or unreadable amount's message, or null when it's fine.
  static String? validate(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) return l10n.amountRequired;
    final cents = parseToCents(value, allowNegative: false);
    if (cents == null || cents <= 0) return l10n.invalidNumber;
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currency = switch (ref.watch(preferencesViewModelProvider)) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };

    return Column(
      children: [
        TransactionTypeToggle(selected: type, onChanged: onTypeChanged),
        const SizedBox(height: Spacing.sm),
        // The same field as every other: the symbol at the end, and the
        // sign before what's typed.
        FormPillField(
          fieldKey: fieldKey,
          autofocus: autofocus,
          trailing: currency.symbol,
          prefix: type == TransactionType.income ? '+' : '-',
          controller: controller,
          label: l10n.amount,
          required: true,
          hint: zeroAmountHint(moneyLocale(context)),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: const [AmountInputFormatter()],
          validator: (value) => validate(l10n, value),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
