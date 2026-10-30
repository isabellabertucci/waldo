import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/amount_input_formatter.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/field_label.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/l10n/app_localizations.dart';

import 'transaction_type_toggle.dart';

/// Expense/Income over the amount, typed with the system keyboard. The new
/// and edit sheets share it, so the amount works the same in both.
class TransactionAmountCard extends ConsumerStatefulWidget {
  const TransactionAmountCard({
    super.key,
    required this.type,
    required this.onTypeChanged,
    required this.controller,
    required this.onChanged,
    this.fieldKey,
  });

  final TransactionType type;
  final ValueChanged<TransactionType> onTypeChanged;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Key? fieldKey;

  /// An empty, zero or unreadable amount's message, or null when it's fine.
  static String? validate(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) return l10n.amountRequired;
    final cents = parseToCents(value, allowNegative: false);
    if (cents == null || cents <= 0) return l10n.invalidNumber;
    return null;
  }

  @override
  ConsumerState<TransactionAmountCard> createState() =>
      _TransactionAmountCardState();
}

class _TransactionAmountCardState extends ConsumerState<TransactionAmountCard> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    // Redraw so the card's stitch follows focus.
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final currencySymbol = switch (ref.watch(preferencesViewModelProvider)) {
      AsyncValue(:final value?) => value.currency.symbol,
      _ => Currency.usd.symbol,
    };
    final isIncome = widget.type == TransactionType.income;
    final amountColor = isIncome ? colors.primaryStrong : colors.error;

    return DashedBorder(
      radius: Rounded.lg,
      color: _focus.hasFocus ? colors.primary : colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.sm),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(Rounded.lg),
        ),
        child: Column(
          children: [
            TransactionTypeToggle(
              selected: widget.type,
              onChanged: widget.onTypeChanged,
            ),
            const SizedBox(height: Spacing.xs),
            // The error goes under the whole row; inside the hugging field it'd be cut off.
            FormField<String>(
              validator: (_) =>
                  TransactionAmountCard.validate(l10n, widget.controller.text),
              // One node named "Amount", with its sign, value and error.
              builder: (field) => MergeSemantics(
                child: Semantics(
                  label: FieldLabel.requiredSemantics(context, l10n.amount),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // The trailing space makes "+$ 0.00" read as one string.
                          Text(
                            '${isIncome ? '+' : '-'}$currencySymbol ',
                            style: context.amountDisplayExtraBold.copyWith(
                              color: amountColor,
                            ),
                          ),
                          // As wide as its text, so the gap stays one space.
                          Flexible(
                            child: IntrinsicWidth(
                              child: TextField(
                                key: widget.fieldKey,
                                controller: widget.controller,
                                focusNode: _focus,
                                onChanged: (value) {
                                  widget.onChanged(value);
                                  field.didChange(value);
                                },
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                inputFormatters: const [AmountInputFormatter()],
                                decoration: InputDecoration(
                                  isCollapsed: true,
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  filled: false,
                                  // The theme's padding would widen the one-space gap.
                                  contentPadding: EdgeInsets.zero,
                                  hintText: zeroAmountHint(
                                    moneyLocale(context),
                                  ),
                                  hintStyle: context.amountDisplayExtraBold
                                      .copyWith(color: colors.onSurfaceVariant),
                                ),
                                style: context.amountDisplayExtraBold.copyWith(
                                  color: colors.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (field.hasError)
                        Text(
                          field.errorText!,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.error,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
