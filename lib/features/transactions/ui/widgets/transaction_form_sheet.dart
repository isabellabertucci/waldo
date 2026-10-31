import 'package:flutter/material.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/option_sheet.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

import 'category_picker.dart';
import 'transaction_amount_card.dart';
import 'transaction_date_picker.dart';
import 'transaction_field_row.dart';

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
  late final TextEditingController _noteController;

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
    _noteController = TextEditingController(text: initial.note);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<DateTime?> _pickDate(DateTime? current) {
    final now = ref.read(clockProvider)();
    return showTransactionDatePicker(
      context,
      initialDate: current ?? now,
      now: now,
    );
  }

  /// Shown above the button: a SnackBar would land behind the sheet.
  String? _saveError;

  Future<void> _save(TransactionFormViewModel viewModel) async {
    if (!_formKey.currentState!.validate()) {
      _log.fine('Transaction form validation failed');
      return;
    }
    setState(() => _saveError = null);
    try {
      final success = await viewModel.save();
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final message = failureMessage(
          l10n,
          e,
          unknown: l10n.transactionSaveError,
        );
        setState(() => _saveError = message);
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
    final dateFormatPattern = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.dateFormat,
      _ => 'yyyy-MM-dd',
    };
    final dateFormat = DateFormat(dateFormatPattern);

    final walletName = switch (walletsAsync) {
      AsyncValue(:final value?) =>
        value.where((w) => w.id == formState.walletId).firstOrNull?.name,
      _ => null,
    };

    final categories = categoriesAsync.value ?? const <Category>[];
    final category = categories
        .where((c) => c.id == formState.categoryId)
        .firstOrNull;

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
              const SheetGrabber(),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: Heading(
                      child: Text(
                        l10n.newTransaction,
                        style: context.headlineLgExtraBold,
                      ),
                    ),
                  ),
                  const SheetCloseButton(),
                ],
              ),
              const SizedBox(height: Spacing.md),
              TransactionAmountCard(
                fieldKey: const Key('transactionAmountField'),
                type: formState.type,
                onTypeChanged: viewModel.updateType,
                controller: _amountController,
                onChanged: viewModel.updateAmount,
              ),
              const SizedBox(height: Spacing.sm),
              // Right under the amount, as in the edit sheet and the detail.
              FormPillField(
                fieldKey: const Key('transactionDescriptionField'),
                leading: const Icon(AppIcons.name),
                controller: _descriptionController,
                label: l10n.transactionTitle,
                hint: l10n.descriptionHint,
                // Stops typing at the limit instead of failing on save.
                maxLength: maxTransactionDescriptionLength,
                textCapitalization: TextCapitalization.sentences,
                onChanged: viewModel.updateDescription,
              ),
              const SizedBox(height: Spacing.sm),
              // The same row and picker as the edit sheet.
              EditFieldRow(
                key: const Key('transactionCategoryField'),
                icon: category?.icon ?? AppIcons.categoryNone,
                label: l10n.category,
                value: category?.displayName(l10n) ?? l10n.none,
                onTap: () => showCategoryPicker(
                  context,
                  categories: categories,
                  selected: formState.categoryId,
                  onPicked: viewModel.updateCategoryId,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              // Date and Wallet share one card divided by a hairline.
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
                            required: true,
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
                      const Divider(indent: Spacing.md, endIndent: Spacing.md),
                      switch (walletsAsync) {
                        AsyncValue(:final value?) => FormField<int>(
                          initialValue: formState.walletId,
                          validator: (walletId) =>
                              walletId == null ? l10n.walletRequired : null,
                          builder: (field) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              EditFieldRow(
                                key: const Key('transactionWalletField'),
                                grouped: true,
                                icon: AppIcons.wallets,
                                label: l10n.wallet,
                                required: true,
                                value: walletName ?? l10n.none,
                                hasError: field.hasError,
                                onTap: () => showOptionSheet<int?>(
                                  context,
                                  title: l10n.wallet,
                                  initialValue: field.value,
                                  pickOnTap: true,
                                  options: [
                                    for (final wallet in value)
                                      SheetOption(
                                        value: wallet.id,
                                        label: wallet.name,
                                        icon: AppIcons.wallets,
                                      ),
                                  ],
                                  onConfirm: (walletId) {
                                    viewModel.updateWalletId(walletId!);
                                    field.didChange(walletId);
                                  },
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
                  ],
                ),
              ),
              const SizedBox(height: Spacing.sm),
              // Last, as in the edit sheet: optional, so it never sits
              // between the fields a save needs.
              FormPillField(
                fieldKey: const Key('transactionNoteField'),
                leading: const Icon(AppIcons.note),
                controller: _noteController,
                label: l10n.transactionNote,
                hint: l10n.noteHint,
                maxLength: maxTransactionNoteLength,
                textCapitalization: TextCapitalization.sentences,
                onChanged: viewModel.updateNote,
              ),
              const SizedBox(height: Spacing.md),
              if (_saveError case final error?) ...[
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: context.bodyMdStrong.copyWith(color: colors.error),
                ),
                const SizedBox(height: Spacing.sm),
              ],
              SizedBox(
                width: double.infinity,
                child: DashedStitchButton(
                  icon: const Icon(AppIcons.check, size: IconSize.md),
                  label: formState.type == TransactionType.income
                      ? l10n.addIncome
                      : l10n.addExpense,
                  onPressed: () => _save(viewModel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
