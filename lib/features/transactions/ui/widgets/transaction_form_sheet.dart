import 'package:flutter/material.dart';
import 'package:waldo/core/theme/badge_size.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/amount_input_formatter.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/core/widgets/secondary_button.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/near_limit_counter.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

import 'transaction_field_row.dart';
import 'transaction_type_toggle.dart';

final _log = Logger('waldo.ui.transaction_form');

/// Opens the form for a new transaction.
Future<void> showTransactionFormSheet(
  BuildContext context, {
  int? initialWalletId,
}) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => TransactionFormSheet(initialWalletId: initialWalletId),
  );
}

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({super.key, this.initialWalletId});

  final int? initialWalletId;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  final _amountFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    final initial = ref.read(
      transactionFormViewModelProvider(
        null,
        initialWalletId: widget.initialWalletId,
      ),
    );
    _amountController = TextEditingController(text: initial.amount);
    _descriptionController = TextEditingController(text: initial.description);
    // Redraw so the amount card's stitch follows focus.
    _amountFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  String? _validateAmount(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.amountRequired;
    }
    final parsedCents = parseToCents(value, allowNegative: false);
    if (parsedCents == null || parsedCents <= 0) {
      return l10n.invalidNumber;
    }
    return null;
  }

  Future<DateTime?> _pickDate(DateTime? current) {
    return showDatePicker(
      context: context,
      initialDate: current ?? ref.read(clockProvider)(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
  }

  Future<void> _save(TransactionFormViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      _log.fine('Transaction form validation failed');
      return;
    }
    try {
      final success = await viewModel.save(null);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.transactionSaveError)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final formState = ref.watch(
      transactionFormViewModelProvider(
        null,
        initialWalletId: widget.initialWalletId,
      ),
    );
    final viewModel = ref.read(
      transactionFormViewModelProvider(
        null,
        initialWalletId: widget.initialWalletId,
      ).notifier,
    );
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final categoriesAsync = ref.watch(categoryListViewModelProvider);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currencySymbol = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency.symbol,
      _ => Currency.usd.symbol,
    };
    final dateFormatPattern = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.dateFormat,
      _ => 'yyyy-MM-dd',
    };
    final dateFormat = DateFormat(dateFormatPattern);

    final isIncome = formState.type == TransactionType.income;
    final amountColor = isIncome ? colors.primaryStrong : colors.error;
    final walletName = switch (walletsAsync) {
      AsyncValue(:final value?) =>
        value.where((w) => w.id == formState.walletId).firstOrNull?.name,
      _ => null,
    };

    return Padding(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            Spacing.md,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.onSurface.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Rounded.pill),
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.newTransaction,
                      style: context.headlineLgStrong,
                    ),
                  ),
                  const SheetCloseButton(),
                ],
              ),
              const SizedBox(height: Spacing.md),
              DashedBorder(
                radius: Rounded.lg,
                color: _amountFocus.hasFocus
                    ? colors.primary
                    : colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surfaceContainer,
                    borderRadius: BorderRadius.circular(Rounded.lg),
                  ),
                  child: Column(
                    children: [
                      TransactionTypeToggle(
                        selected: formState.type,
                        onChanged: viewModel.updateType,
                      ),
                      const SizedBox(height: Spacing.xs),
                      // The error goes under the whole row; inside the hugging field it'd be cut off.
                      FormField<String>(
                        validator: (_) =>
                            _validateAmount(l10n, _amountController.text),
                        builder: (field) => Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // The trailing space makes "+$ 0.00" read as one string.
                                Text(
                                  '${isIncome ? '+' : '-'}$currencySymbol ',
                                  style: context.amountDisplayBold.copyWith(
                                    color: amountColor,
                                  ),
                                ),
                                // As wide as its text, so the gap stays one space.
                                Flexible(
                                  child: IntrinsicWidth(
                                    child: TextField(
                                      key: const Key('transactionAmountField'),
                                      controller: _amountController,
                                      focusNode: _amountFocus,
                                      onChanged: (value) {
                                        viewModel.updateAmount(value);
                                        field.didChange(value);
                                      },
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      inputFormatters: const [
                                        AmountInputFormatter(),
                                      ],
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
                                        hintText: '0.00',
                                        hintStyle: context.amountDisplayBold
                                            .copyWith(
                                              color: colors.onSurfaceVariant,
                                            ),
                                      ),
                                      style: context.amountDisplayBold.copyWith(
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
                    ],
                  ),
                ),
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  // Says up front that skipping a category is fine; one text,
                  // so it ellipsizes before pushing the button off a narrow row.
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: l10n.category.toUpperCase(),
                            style: context.bodySmBold.copyWith(
                              color: colors.onSurfaceVariant,
                              letterSpacing: 0.4,
                            ),
                          ),
                          const TextSpan(text: '  '),
                          TextSpan(
                            text: l10n.optional,
                            style: context.textTheme.bodySmall?.copyWith(
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SecondaryButton(
                    label: l10n.manageCategories,
                    onPressed: () => const CategoriesRoute().push(context),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              switch (categoriesAsync) {
                // One row that scrolls sideways, so more categories never make
                // the sheet taller.
                AsyncValue(:final value?) => SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final category in value) ...[
                        _CategoryChip(
                          icon: category.icon,
                          label: category.displayName(l10n),
                          selected: formState.categoryId == category.id,
                          onTap: () => viewModel.updateCategoryId(category.id),
                        ),
                        const SizedBox(width: Spacing.xs),
                      ],
                    ],
                  ),
                ),
                _ => const SizedBox.shrink(),
              },
              const SizedBox(height: Spacing.sm),
              // Date, Wallet and Description share one card divided by
              // hairlines - same as the edit sheet's Date/Wallet/Note card.
              Material(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(Rounded.lg),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  children: [
                    FormField<DateTime>(
                      initialValue: formState.date,
                      validator: (value) =>
                          value == null ? l10n.dateRequired : null,
                      builder: (field) => Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          EditFieldRow(
                            key: const Key('transactionDateField'),
                            grouped: true,
                            icon: AppIcons.calendar,
                            label: l10n.date,
                            value: formState.date == null
                                ? '—'
                                : dateFormat.format(formState.date!),
                            hasError: field.hasError,
                            onTap: () async {
                              final picked = await _pickDate(formState.date);
                              if (picked == null) return;
                              viewModel.updateDate(picked);
                              field.didChange(picked);
                            },
                          ),
                          if (field.hasError)
                            Padding(
                              padding: const EdgeInsets.only(
                                left: Spacing.md,
                                bottom: Spacing.sm,
                              ),
                              child: Text(
                                field.errorText!,
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: colors.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (widget.initialWalletId == null) ...[
                      const _GroupDivider(),
                      switch (walletsAsync) {
                        AsyncValue(:final value?) => FormField<int>(
                          initialValue: formState.walletId,
                          validator: (walletId) =>
                              walletId == null ? l10n.walletRequired : null,
                          builder: (field) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EditFieldRow(
                                grouped: true,
                                icon: AppIcons.wallets,
                                label: l10n.wallet,
                                value: walletName ?? l10n.none,
                                hasError: field.hasError,
                                onTap: () => _showWalletPicker(
                                  context,
                                  value,
                                  viewModel,
                                  field,
                                ),
                              ),
                              if (field.hasError)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    left: Spacing.md,
                                    bottom: Spacing.sm,
                                  ),
                                  child: Text(
                                    field.errorText!,
                                    style: context.textTheme.bodySmall
                                        ?.copyWith(color: colors.error),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        _ => const SizedBox.shrink(),
                      },
                    ],
                    const _GroupDivider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: Spacing.md,
                        vertical: Spacing.sm,
                      ),
                      child: Row(
                        children: [
                          FieldBadge(
                            icon: AppIcons.note,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(width: Spacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  l10n.transactionDescription,
                                  style: context.textTheme.bodySmall?.copyWith(
                                    color: colors.onSurfaceVariant,
                                  ),
                                ),
                                TextFormField(
                                  key: const Key('transactionDescriptionField'),
                                  controller: _descriptionController,
                                  onChanged: viewModel.updateDescription,
                                  // Stops typing at the limit instead of failing on save.
                                  maxLength: maxTransactionDescriptionLength,
                                  buildCounter: nearLimitCounter,
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  decoration: InputDecoration(
                                    isCollapsed: true,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    errorBorder: InputBorder.none,
                                    focusedErrorBorder: InputBorder.none,
                                    filled: false,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: Spacing.xs,
                                    ),
                                    hintText: l10n.descriptionHint,
                                    hintStyle: context.bodyMdBold.copyWith(
                                      color: colors.onSurfaceVariant.withValues(
                                        alpha: 0.6,
                                      ),
                                    ),
                                  ),
                                  style: context.bodyMdBold,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: DashedStitchButton(
                  icon: const Icon(AppIcons.check, size: IconSize.md),
                  label: isIncome ? l10n.addIncome : l10n.addExpense,
                  onPressed: () => _save(viewModel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showWalletPicker(
    BuildContext context,
    List<Wallet> wallets,
    TransactionFormViewModel viewModel,
    FormFieldState<int> field,
  ) {
    final colors = context.appColors;
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          // Same side margin as every other sheet.
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.sm,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final wallet in wallets)
                ListTile(
                  leading: Icon(
                    AppIcons.wallets,
                    color: colors.onSurfaceVariant,
                  ),
                  title: Text(wallet.name, style: context.bodyMdBold),
                  onTap: () {
                    viewModel.updateWalletId(wallet.id!);
                    field.didChange(wallet.id);
                    Navigator.of(sheetContext).pop();
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// One selectable category pill - a filled icon disc plus label, with a
/// dashed accent border and bold label when selected.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(Rounded.pill),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rounded.pill),
        onTap: onTap,
        child: DashedBorder(
          radius: Rounded.pill,
          color: selected ? colors.primary : colors.transparent,
          child: Padding(
            padding: const EdgeInsets.only(
              left: Spacing.xs,
              right: Spacing.sm,
              top: Spacing.xs,
              bottom: Spacing.xs,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: BadgeSize.sm,
                  height: BadgeSize.sm,
                  decoration: BoxDecoration(
                    color: colors.surface,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: IconSize.sm,
                    color: colors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: Spacing.xs),
                Text(
                  label,
                  style: selected ? context.bodyMdBold : context.bodyMdStrong,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// The hairline between rows of the Date/Wallet/Description card.
class _GroupDivider extends StatelessWidget {
  const _GroupDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: Spacing.md),
      color: context.appColors.onSurfaceVariant.withValues(alpha: 0.1),
    );
  }
}
