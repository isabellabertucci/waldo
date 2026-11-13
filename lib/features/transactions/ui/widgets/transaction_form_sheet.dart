import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/choice_chips.dart';
import 'package:waldo/features/transactions/viewmodels/recent_categories_view_model.dart';
import 'package:waldo/core/widgets/field_label.dart';
import 'package:waldo/core/widgets/form_sheet_body.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/widgets/app_sheet.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/core/widgets/pill_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

import 'category_picker.dart';
import 'transaction_amount_card.dart';
import 'transaction_date_picker.dart';
import 'transaction_field_row.dart';
import 'wallet_picker.dart';

final _log = Logger('waldo.ui.transaction_form');

/// Opens the form for a new transaction.
Future<void> showTransactionFormSheet(
  BuildContext context, {
  int? initialWalletId,
  TransactionType? initialType,
}) {
  return showAppSheet(
    context,
    builder: (_) => TransactionFormSheet(
      initialWalletId: initialWalletId,
      initialType: initialType,
    ),
  );
}

class TransactionFormSheet extends ConsumerStatefulWidget {
  const TransactionFormSheet({
    super.key,
    this.initialWalletId,
    this.initialType,
  });

  final int? initialWalletId;

  /// Expense or Income already picked (the app icon's shortcuts).
  final TransactionType? initialType;

  @override
  ConsumerState<TransactionFormSheet> createState() =>
      _TransactionFormSheetState();
}

class _TransactionFormSheetState extends ConsumerState<TransactionFormSheet> {
  /// This sheet's form: new, maybe for a wallet, maybe as an income.
  TransactionFormViewModelProvider get _provider =>
      transactionFormViewModelProvider(
        null,
        initialWalletId: widget.initialWalletId,
        initialType: widget.initialType,
      );

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(_provider);
    _amountController = TextEditingController(text: initial.amount);
    _descriptionController = TextEditingController(text: initial.description);
    _noteController = TextEditingController(text: initial.note);
    final viewModel = ref.read(_provider.notifier);
    // Opened from a wallet, the wallet is already known.
    if (widget.initialWalletId == null) viewModel.preselectWallet();
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
    final formState = ref.watch(_provider);
    final viewModel = ref.read(_provider.notifier);
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final categoriesAsync = ref.watch(categoryListViewModelProvider);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final dateFormatPattern = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.dateFormat,
      _ => 'yyyy-MM-dd',
    };
    final dateFormat = DateFormat(dateFormatPattern);

    final wallet = switch (walletsAsync) {
      AsyncValue(:final value?) =>
        value.where((w) => w.id == formState.walletId).firstOrNull,
      _ => null,
    };

    final categories = categoriesAsync.value ?? const <Category>[];
    final recentCategories =
        ref.watch(recentCategoriesProvider(formState.type)).value ??
        const <Category>[];
    final category = categories
        .where((c) => c.id == formState.categoryId)
        .firstOrNull;

    return FormSheetBody(
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
                      style: context.titleSection,
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
              autofocus: true,
            ),
            // The categories used last, one tap each, above the keyboard.
            // Tapping the picked one again unpicks it.
            if (recentCategories.isNotEmpty) ...[
              const SizedBox(height: Spacing.md),
              FieldLabel(
                l10n.recentCategories,
                style: context.bodyStrong.copyWith(color: colors.inkMuted),
              ),
              const SizedBox(height: Spacing.xs),
              ChoiceChips(
                key: const Key('recentCategoryChips'),
                chips: [
                  for (final c in recentCategories)
                    (value: c.id, icon: c.icon, label: c.displayName(l10n)),
                ],
                selected: formState.categoryId,
                onTap: (id) => viewModel.updateCategoryId(
                  id == formState.categoryId ? null : id,
                ),
              ),
            ],
            const SizedBox(height: Spacing.md),
            // Wallet, Category and Date in one card, right under the amount,
            // so the prefilled wallet shows above the keyboard before
            // saving. One field checks the
            // required ones, so their messages sit under the card, like
            // every other field's, not between the rows.
            FormField<void>(
              // Reads the form as it is now: a pick lands in the view
              // model before this widget rebuilds.
              validator: (_) {
                final current = ref.read(_provider);
                final missing = [
                  if (widget.initialWalletId == null &&
                      current.walletId == null)
                    l10n.walletRequired,
                  if (current.date == null) l10n.dateRequired,
                ];
                return missing.isEmpty ? null : missing.join('\n');
              },
              builder: (field) {
                // Once a save has failed, each pick checks again, so a
                // message goes as soon as its field is filled.
                void recheck() {
                  if (field.hasError) field.validate();
                }

                final wallets = walletsAsync.value;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    EditFieldRow.group(context, [
                      // Opened from a wallet, the wallet is already known.
                      if (widget.initialWalletId == null && wallets != null)
                        EditFieldRow(
                          key: const Key('transactionWalletField'),
                          icon: wallet?.type.icon ?? AppIcons.wallets,
                          label: l10n.wallet,
                          required: true,
                          value: wallet?.name ?? l10n.none,
                          hasError:
                              field.hasError && formState.walletId == null,
                          // The same picker as the edit sheet.
                          onTap: () => showWalletPicker(
                            context,
                            wallets: wallets,
                            selected: formState.walletId,
                            onPicked: (walletId) {
                              viewModel.updateWalletId(walletId);
                              recheck();
                            },
                          ),
                        ),
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
                      EditFieldRow(
                        key: const Key('transactionDateField'),
                        icon: AppIcons.calendar,
                        label: l10n.date,
                        required: true,
                        value: formState.date == null
                            ? '—'
                            : dateFormat.format(formState.date!),
                        hasError: field.hasError && formState.date == null,
                        onTap: () async {
                          final picked = await _pickDate(formState.date);
                          if (picked == null) return;
                          viewModel.updateDate(picked);
                          recheck();
                        },
                      ),
                    ]),
                    if (field.errorText case final error?) FieldError(error),
                  ],
                );
              },
            ),
            const SizedBox(height: Spacing.md),
            FormPillField(
              fieldKey: const Key('transactionDescriptionField'),
              controller: _descriptionController,
              label: l10n.transactionTitle,
              hint: l10n.descriptionHint,
              // Stops typing at the limit instead of failing on save.
              maxLength: maxTransactionDescriptionLength,
              textCapitalization: TextCapitalization.sentences,
              onChanged: viewModel.updateDescription,
            ),
            const SizedBox(height: Spacing.md),
            FormPillField(
              fieldKey: const Key('transactionNoteField'),
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
                style: context.bodyStrong.copyWith(color: colors.negative),
              ),
              const SizedBox(height: Spacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: formState.type == TransactionType.income
                    ? l10n.addIncome
                    : l10n.addExpense,
                onPressed: () => _save(viewModel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
