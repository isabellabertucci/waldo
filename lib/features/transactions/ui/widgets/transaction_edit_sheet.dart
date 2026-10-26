import 'package:flutter/material.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/dashed_circle_badge.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/undo_snack_bar.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/models/preferences.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_state.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

import '../../transactions_x.dart';
import '../../viewmodels/transaction_list_view_model.dart';
import 'transaction_date_picker.dart';
import 'transaction_field_row.dart';
import 'transaction_type_toggle.dart';

/// Opens a transaction in a bottom sheet, read-only unless [startInEditMode].
/// New transactions use [showTransactionFormSheet].
Future<void> showTransactionEditSheet(
  BuildContext context, {
  required Transaction transaction,
  bool startInEditMode = false,
}) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (_) => TransactionEditSheet(
      transaction: transaction,
      startInEditMode: startInEditMode,
    ),
  );
}

/// Confirm, hide the transaction, show a 5 s Undo snackbar, then delete.
/// Uses the [ProviderContainer] because the sheet closes before the 5 s are up.
Future<void> deleteTransactionWithUndo(
  BuildContext context,
  Transaction transaction, {
  VoidCallback? onConfirmed,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final container = ProviderScope.containerOf(context, listen: false);

  final confirmed = await ConfirmationDialog.show(
    context,
    title: l10n.deleteTransaction,
    content: l10n.deleteTransactionConfirm,
    confirmLabel: l10n.delete,
  );
  if (!confirmed) return;

  final provider = transactionListViewModelProvider(
    walletId: transaction.walletId,
  );
  final subscription = container.listen(provider, (_, _) {});
  try {
    // The list must load to hide the row; if it can't, say so, not nothing.
    try {
      await container.read(provider.future);
    } catch (e) {
      final message = failureMessage(
        l10n,
        e,
        unknown: l10n.transactionDeleteError,
      );
      messenger.showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    final viewModel = container.read(provider.notifier);
    if (!viewModel.hideTransaction(transaction.id!)) return;
    onConfirmed?.call();

    final undone = await showUndoSnackBar(
      messenger,
      title: l10n.transactionDeleted,
      subtitle: transaction.description,
      restoredLabel: l10n.transactionRestored,
    );
    if (undone) {
      viewModel.restoreTransaction(transaction.id!);
      return;
    }

    try {
      await viewModel.confirmDelete(transaction.id!);
    } catch (e) {
      viewModel.restoreTransaction(transaction.id!);
      final message = failureMessage(
        l10n,
        e,
        unknown: l10n.transactionDeleteError,
      );
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  } finally {
    subscription.close();
  }
}

/// The field being edited in place - the sheet's content swaps to its editor.
enum _EditField { amount, category }

/// The amount, category and date as the view and the edit list show them.
typedef _Summary = ({
  String amountText,
  Color amountColor,
  IconData categoryIcon,
  String categoryLabel,
  String dateLabel,
});

class TransactionEditSheet extends ConsumerStatefulWidget {
  const TransactionEditSheet({
    super.key,
    required this.transaction,
    this.startInEditMode = false,
  });

  final Transaction transaction;
  final bool startInEditMode;

  @override
  ConsumerState<TransactionEditSheet> createState() =>
      _TransactionEditSheetState();
}

class _TransactionEditSheetState extends ConsumerState<TransactionEditSheet> {
  /// Starts as [widget.startInEditMode] says; "Edit transaction" flips it on.
  late bool _editable = widget.startInEditMode;

  _EditField? _activeField;

  /// The form as it was when editing started - what Cancel goes back to.
  late TransactionFormState _beforeEdit;

  late final TextEditingController _amountController;
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;

  TransactionFormState get _formState =>
      ref.read(transactionFormViewModelProvider(widget.transaction));

  TransactionFormViewModel get _viewModel =>
      ref.read(transactionFormViewModelProvider(widget.transaction).notifier);

  @override
  void initState() {
    super.initState();
    final formState = _formState;
    _beforeEdit = formState;
    _amountController = TextEditingController(text: formState.amount);
    _nameController = TextEditingController(text: formState.description);
    _noteController = TextEditingController(text: formState.note);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _openField(_EditField field) {
    final formState = _formState;
    switch (field) {
      case _EditField.amount:
        _amountController.text = _trimTrailingZeros(
          formState.amount,
        ).replaceFirst(_decimalSeparators, _decimalSeparator);
      case _EditField.category:
        break;
    }
    setState(() => _activeField = field);
  }

  void _closeField() => setState(() => _activeField = null);

  bool _isFieldDirty(_EditField field) {
    final formState = _formState;
    return switch (field) {
      // By value: the keypad shows "10.5" for a stored "10.50".
      _EditField.amount =>
        parseToCents(_amountController.text, allowNegative: false) !=
            parseToCents(formState.amount, allowNegative: false),
      _EditField.category => false,
    };
  }

  /// Asks before the back chevron drops an unsaved amount. Cancel, or a tap
  /// outside, keeps the editor open; ✓ is how the amount is kept.
  Future<void> _handleFieldBack(_EditField field) async {
    if (!_isFieldDirty(field)) {
      _closeField();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final discard = await ConfirmationDialog.show(
      context,
      icon: AppIcons.undo,
      title: l10n.discardChangesTitle,
      content: l10n.discardChangesMessage,
      confirmLabel: l10n.discard,
    );
    if (discard && mounted) _closeField();
  }

  // Fields only stage changes on the view model; "Save changes" writes them.
  void _confirmAmount() {
    _viewModel.updateAmount(_amountController.text);
    _closeField();
  }

  void _selectCategory(int? value) {
    _viewModel.updateCategoryId(value);
    _closeField();
  }

  /// The phone's decimal separator, so the keypad matches the system keyboard.
  String get _decimalSeparator => decimalSeparator(moneyLocale(context));

  void _appendAmountDigit(String digit) {
    final value = _amountController.text;
    final decimalIndex = value.indexOf(_decimalSeparators);
    if (decimalIndex != -1 && value.length - decimalIndex > 2) return;
    // Same cap as the typed amount fields: no digit past 999 999 999.
    if (decimalIndex == -1 && value.length >= maxAmountWholeDigits) return;
    setState(() => _amountController.text = '$value$digit');
  }

  void _appendAmountDecimalPoint() {
    final value = _amountController.text;
    if (value.contains(_decimalSeparators)) return;
    final separator = _decimalSeparator;
    setState(
      () => _amountController.text = value.isEmpty
          ? '0$separator'
          : '$value$separator',
    );
  }

  void _amountBackspace() {
    final value = _amountController.text;
    if (value.isEmpty) return;
    setState(
      () => _amountController.text = value.substring(0, value.length - 1),
    );
  }

  /// Date only - the app doesn't track a time of day. Whatever time the
  /// transaction already had is kept as-is, just never shown.
  Future<void> _editDate(TransactionFormState formState) async {
    final now = ref.read(clockProvider)();
    final current = formState.date ?? now;
    final pickedDate = await showTransactionDatePicker(
      context,
      initialDate: current,
      now: now,
    );
    if (pickedDate == null || !mounted) return;

    final merged = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      current.hour,
      current.minute,
    );
    _viewModel.updateDate(merged);
  }

  /// Shown above the buttons: a SnackBar would land behind the sheet.
  String? _saveError;

  Future<void> _saveChanges() async {
    final l10n = AppLocalizations.of(context);
    final formState = _formState;

    final amountInCents = parseToCents(formState.amount, allowNegative: false);
    if (amountInCents == null || amountInCents <= 0) {
      setState(() => _saveError = l10n.amountRequired);
      return;
    }
    if (formState.date == null) {
      setState(() => _saveError = l10n.dateRequired);
      return;
    }

    setState(() => _saveError = null);
    try {
      final success = await _viewModel.save();
      if (!success || !mounted) return;
      setState(() => _editable = false);
    } catch (e) {
      if (!mounted) return;
      final message = failureMessage(
        l10n,
        e,
        unknown: l10n.transactionSaveError,
      );
      setState(() => _saveError = message);
    }
  }

  /// Discards every staged change by putting back the form (and the text
  /// fields) as they were when editing started, then leaves edit mode.
  void _cancelEdit() {
    _viewModel.restore(_beforeEdit);
    _amountController.text = _beforeEdit.amount;
    _nameController.text = _beforeEdit.description;
    _noteController.text = _beforeEdit.note;
    setState(() {
      _editable = false;
      _saveError = null;
    });
  }

  void _enterEditMode() {
    _beforeEdit = _formState;
    setState(() => _editable = true);
  }

  Future<void> _delete() async {
    final navigator = Navigator.of(context);
    await deleteTransactionWithUndo(
      context,
      widget.transaction,
      onConfirmed: navigator.pop,
    );
  }

  String _fieldTitle(_EditField field, AppLocalizations l10n) {
    return switch (field) {
      _EditField.amount => l10n.amount,
      _EditField.category => l10n.category,
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    final formState = ref.watch(
      transactionFormViewModelProvider(widget.transaction),
    );
    final categoriesAsync = ref.watch(categoryListViewModelProvider);
    final categories = switch (categoriesAsync) {
      AsyncValue(:final value?) => value,
      _ => const <Category>[],
    };
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final preferences = switch (preferencesAsync) {
      AsyncValue(:final value?) => value,
      _ => const Preferences(),
    };
    final currency = preferences.currency;
    // The format picked in Settings, as the add form uses.
    final dateFormat = DateFormat(preferences.dateFormat);
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final wallet = switch (walletsAsync) {
      AsyncValue(:final value?) =>
        value.where((w) => w.id == formState.walletId).firstOrNull,
      _ => null,
    };

    final summary = _summarize(
      formState,
      categories,
      currency,
      dateFormat,
      isAmountHidden: ref.watch(balanceHiddenProvider),
    );
    final activeField = _activeField;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Rounded.lg),
          ),
        ),
        child: activeField != null
            ? _buildFieldEditor(
                context,
                activeField,
                formState,
                categories,
                currency,
              )
            : _editable
            ? _buildEditList(context, formState, summary)
            : _buildViewList(context, formState, summary, wallet),
      ),
    );
  }

  /// What the view and the edit list both show.
  _Summary _summarize(
    TransactionFormState formState,
    List<Category> categories,
    Currency currency,
    DateFormat dateFormat, {
    required bool isAmountHidden,
  }) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final isIncome = formState.type == TransactionType.income;
    final amountCents = parseToCents(formState.amount, allowNegative: false);
    final category = categories
        .where((c) => c.id == formState.categoryId)
        .firstOrNull;
    return (
      // Masked like the lists; the keypad editor still shows what you type.
      amountText: isAmountHidden
          ? hiddenAmount
          : amountCents == null
          ? '—'
          : '${isIncome ? '+' : '-'}${formatCents(amountCents, locale: moneyLocale(context), currencyCode: currency.code)}',
      amountColor: isIncome ? colors.primaryStrong : colors.error,
      categoryIcon: category?.icon ?? AppIcons.categoryGeneric,
      categoryLabel: category?.displayName(l10n) ?? l10n.none,
      dateLabel: formState.date == null
          ? '—'
          : dateFormat.format(formState.date!),
    );
  }

  /// Read-only view, with Delete and "Edit transaction" at the bottom.
  Widget _buildViewList(
    BuildContext context,
    TransactionFormState formState,
    _Summary summary,
    Wallet? wallet,
  ) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final (
      :amountText,
      :amountColor,
      :categoryIcon,
      :categoryLabel,
      :dateLabel,
    ) = summary;
    final name = formState.description.trim().isEmpty
        ? l10n.transactionDefaultDescription
        : formState.description.trim();
    final walletLabel = wallet == null
        ? '—'
        : '${wallet.name} · ${wallet.type.label(l10n)}';
    final noteLabel = formState.note.trim().isEmpty
        ? '—'
        : formState.note.trim();

    // Scrolls, like the edit list, so large text never pushes it off-screen.
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        Spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No grabber here either - the close button already says how to
          // leave this screen.
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DashedCircleBadge(icon: categoryIcon, color: amountColor),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: MergeSemantics(
                  child: Semantics(
                    // The sheet's title, read with its category and type.
                    header: true,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.headlineLgStrong,
                        ),
                        Text(
                          '$categoryLabel · ${formState.type.label(l10n)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              const SheetCloseButton(),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.md,
              vertical: Spacing.sm,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(Rounded.lg),
            ),
            // Side by side when they fit; with large text the amount wraps
            // under its label rather than being cut.
            child: MergeSemantics(
              child: Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.amount,
                    style: context.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    amountText,
                    style: context.headlineLgStrong.copyWith(
                      color: amountColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(Rounded.lg),
            ),
            child: Column(
              children: [
                _ViewInfoRow(
                  icon: AppIcons.calendar,
                  label: l10n.date,
                  value: dateLabel,
                ),
                _ViewInfoRow(
                  icon: AppIcons.wallets,
                  label: l10n.wallet,
                  value: walletLabel,
                ),
                _ViewInfoRow(
                  icon: AppIcons.note,
                  label: l10n.transactionNote,
                  value: noteLabel,
                  showDivider: false,
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.md),
          Row(
            children: [
              // A plain circle beside "Edit transaction", not a long pill.
              CircleIconButton(
                flat: true,
                tint: colors.error.withValues(alpha: 0.08),
                tooltip: l10n.delete,
                onPressed: _delete,
                child: Icon(
                  AppIcons.delete,
                  size: IconSize.xl,
                  color: colors.error,
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: DashedStitchButton(
                  icon: const Icon(AppIcons.edit, size: IconSize.md),
                  label: l10n.editTransactionAction,
                  onPressed: _enterEditMode,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xs,
                    vertical: Spacing.sm,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Edit view; nothing is saved until "Save changes".
  Widget _buildEditList(
    BuildContext context,
    TransactionFormState formState,
    _Summary summary,
  ) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final (
      :amountText,
      :amountColor,
      :categoryIcon,
      :categoryLabel,
      :dateLabel,
    ) = summary;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.sm,
        Spacing.md,
        MediaQuery.of(context).viewInsets.bottom + Spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // No grabber - the back chevron already says how to leave.
          Row(
            children: [
              // A 48dp disc, so the back target is big enough to hit.
              CircleIconButton(
                tooltip: l10n.back,
                onPressed: _cancelEdit,
                child: const Icon(AppIcons.back),
              ),
              const SizedBox(width: Spacing.component),
              Expanded(
                child: Heading(
                  child: Text(
                    l10n.editTransactionAction,
                    style: context.headlineLgStrong,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: Spacing.sm,
              vertical: Spacing.xs,
            ),
            decoration: BoxDecoration(
              color: colors.surfaceContainer,
              borderRadius: BorderRadius.circular(Rounded.lg),
            ),
            child: Column(
              children: [
                TransactionTypeToggle(
                  selected: formState.type,
                  onChanged: (type) => _viewModel.updateType(type),
                ),
                const SizedBox(height: Spacing.sm),
                // "Amount, +12.50, button": opens the keypad.
                Semantics(
                  button: true,
                  label: l10n.amount,
                  child: InkWell(
                    key: const Key('txAmountField'),
                    borderRadius: BorderRadius.circular(Rounded.md),
                    onTap: () => _openField(_EditField.amount),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: Spacing.xxs,
                      ),
                      child: Text(
                        amountText,
                        textAlign: TextAlign.center,
                        style: context.headlineLgStrong.copyWith(
                          color: amountColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          FormPillField(
            fieldKey: const Key('txNameField'),
            leading: const Icon(AppIcons.name),
            controller: _nameController,
            label: l10n.transactionTitle,
            hint: l10n.descriptionHint,
            maxLength: maxTransactionDescriptionLength,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) => _viewModel.updateDescription(value),
          ),
          const SizedBox(height: Spacing.sm),
          EditFieldRow(
            icon: categoryIcon,
            label: l10n.category,
            value: categoryLabel,
            onTap: () => _openField(_EditField.category),
          ),
          const SizedBox(height: Spacing.sm),
          EditFieldRow(
            icon: AppIcons.calendar,
            label: l10n.date,
            required: true,
            value: dateLabel,
            onTap: () => _editDate(formState),
          ),
          const SizedBox(height: Spacing.sm),
          FormPillField(
            fieldKey: const Key('txNoteField'),
            leading: const Icon(AppIcons.note),
            controller: _noteController,
            label: l10n.transactionNote,
            hint: l10n.noteHint,
            maxLength: maxTransactionNoteLength,
            textCapitalization: TextCapitalization.sentences,
            onChanged: (value) => _viewModel.updateNote(value),
          ),
          const SizedBox(height: Spacing.md),
          if (_saveError case final error?) ...[
            SizedBox(
              width: double.infinity,
              child: Text(
                error,
                textAlign: TextAlign.center,
                style: context.bodyMdStrong.copyWith(color: colors.error),
              ),
            ),
            const SizedBox(height: Spacing.sm),
          ],
          Row(
            children: [
              // Cancel and Save get (nearly) equal widths.
              Expanded(
                flex: 5,
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: colors.surfaceContainer,
                    foregroundColor: colors.onSurface,
                    padding: const EdgeInsets.symmetric(
                      vertical: Spacing.component,
                      horizontal: Spacing.xs,
                    ),
                    textStyle: context.bodySmBold,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(Rounded.pill),
                    ),
                  ),
                  onPressed: _cancelEdit,
                  child: Text(l10n.cancel),
                ),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                flex: 6,
                child: DashedStitchButton(
                  icon: const Icon(AppIcons.check, size: IconSize.sm),
                  label: l10n.saveChanges,
                  onPressed: _saveChanges,
                  compact: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.xxs,
                    vertical: Spacing.sm,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFieldEditor(
    BuildContext context,
    _EditField field,
    TransactionFormState formState,
    List<Category> categories,
    Currency currency,
  ) {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        Spacing.md,
        Spacing.md,
        Spacing.md,
        MediaQuery.of(context).viewInsets.bottom + Spacing.md,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              // A 48dp disc, so the back target is big enough to hit.
              CircleIconButton(
                tooltip: l10n.back,
                onPressed: () => _handleFieldBack(field),
                child: const Icon(AppIcons.back),
              ),
              const SizedBox(width: Spacing.component),
              Heading(
                child: Text(
                  _fieldTitle(field, l10n),
                  style: context.headlineLgStrong,
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          switch (field) {
            _EditField.amount => _buildAmountEditor(
              context,
              formState,
              currency.code,
            ),
            _EditField.category => _buildCategoryEditor(
              context,
              formState,
              categories,
            ),
          },
        ],
      ),
    );
  }

  Widget _buildAmountEditor(
    BuildContext context,
    TransactionFormState formState,
    String currencyCode,
  ) {
    final l10n = AppLocalizations.of(context);
    final isIncome = formState.type == TransactionType.income;
    final color = isIncome
        ? context.appColors.onSurface
        : context.appColors.error;
    final typeLabel = formState.type.label(l10n);
    final cents = parseToCents(_amountController.text, allowNegative: false);
    final sign = isIncome ? '+' : '-';
    final displayValue = cents == null
        ? '$sign${_amountController.text}'
        : '$sign${formatCents(cents, locale: moneyLocale(context), currencyCode: currencyCode)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: Spacing.md,
            vertical: Spacing.md,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(Rounded.lg),
            border: Border.all(color: color.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              Text(
                l10n.editingAmountLabel(typeLabel).toUpperCase(),
                style: context.labelSmBold.copyWith(
                  color: color,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              // Announced as it changes, so each key press is followed by
              // the amount it makes (a status message, WCAG 4.1.3).
              Semantics(
                container: true,
                liveRegion: true,
                child: Text(
                  displayValue,
                  style: context.amountDisplayBold.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        _AmountNumpad(
          decimalSeparator: _decimalSeparator,
          onDigit: _appendAmountDigit,
          onDecimalPoint: _appendAmountDecimalPoint,
          onBackspace: _amountBackspace,
        ),
        const SizedBox(height: Spacing.md),
        DashedStitchButton(label: l10n.done, onPressed: _confirmAmount),
      ],
    );
  }

  Widget _buildCategoryEditor(
    BuildContext context,
    TransactionFormState formState,
    List<Category> categories,
  ) {
    final l10n = AppLocalizations.of(context);

    return RadioGroup<int?>(
      groupValue: formState.categoryId,
      onChanged: _selectCategory,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RadioListTile<int?>(
            title: Text(l10n.none),
            value: null,
            contentPadding: EdgeInsets.zero,
          ),
          ...categories.map(
            (c) => RadioListTile<int?>(
              title: Text(c.displayName(l10n)),
              value: c.id,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// One icon-badge row inside the view screen's grouped Date/Wallet/Note
/// card - label caption above a bold value, divided from the next row.
class _ViewInfoRow extends StatelessWidget {
  const _ViewInfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Column(
      children: [
        // One stop for screen readers: "Date, Thu 8 Oct".
        MergeSemantics(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
            child: Row(
              children: [
                FieldBadge(icon: icon, color: colors.onSurfaceVariant),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        style: context.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.bodyMdBold,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(
            height: 1,
            color: colors.onSurfaceVariant.withValues(alpha: 0.1),
          ),
      ],
    );
  }
}

class _AmountNumpad extends StatelessWidget {
  const _AmountNumpad({
    required this.decimalSeparator,
    required this.onDigit,
    required this.onDecimalPoint,
    required this.onBackspace,
  });

  final String decimalSeparator;
  final ValueChanged<String> onDigit;
  final VoidCallback onDecimalPoint;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
    ];

    return Column(
      spacing: Spacing.sm,
      children: [
        for (final row in rows)
          Row(
            spacing: Spacing.sm,
            children: [
              for (final digit in row)
                Expanded(
                  child: _NumpadKey(label: digit, onTap: () => onDigit(digit)),
                ),
            ],
          ),
        Row(
          spacing: Spacing.sm,
          children: [
            Expanded(
              child: _NumpadKey(label: decimalSeparator, onTap: onDecimalPoint),
            ),
            Expanded(
              child: _NumpadKey(label: '0', onTap: () => onDigit('0')),
            ),
            Expanded(
              child: _NumpadKey(
                icon: AppIcons.backspace,
                tooltip: AppLocalizations.of(context).deleteDigit,
                onTap: onBackspace,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _NumpadKey extends StatelessWidget {
  const _NumpadKey({this.label, this.icon, this.tooltip, required this.onTap});

  final String? label;
  final IconData? icon;
  final String? tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    final button = AspectRatio(
      aspectRatio: 1.5,
      child: Material(
        color: colors.fieldFill,
        borderRadius: BorderRadius.circular(Rounded.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(Rounded.md),
          child: Center(
            child: icon != null
                ? Icon(icon, size: IconSize.xl, color: colors.onSurface)
                : Text(label!, style: context.headlineLgStrong),
          ),
        ),
      ),
    );
    final tooltip = this.tooltip;
    // Outside the tooltip, as Flutter's IconButton does.
    return Semantics(
      button: true,
      child: tooltip == null
          ? button
          : Tooltip(message: tooltip, child: button),
    );
  }
}

/// Either decimal separator: a stored amount uses ".", a typed one may use ",".
final _decimalSeparators = RegExp('[.,]');

/// "10.00" -> "10", "10,50" -> "10,5", so the keypad can keep typing.
String _trimTrailingZeros(String amount) {
  if (!amount.contains(_decimalSeparators)) return amount;
  final trimmed = amount.replaceFirst(RegExp(r'0+$'), '');
  return trimmed.endsWith('.') || trimmed.endsWith(',')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}
