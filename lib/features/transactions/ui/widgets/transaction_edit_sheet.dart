import 'package:flutter/material.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/features/categories/categories_x.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_state.dart';
import 'package:waldo/features/transactions/viewmodels/transaction_form_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../transactions_x.dart';
import '../../viewmodels/transaction_list_view_model.dart';
import 'transaction_field_row.dart';
import 'transaction_type_toggle.dart';

/// Opens a transaction as a bottom sheet - tapping a row anywhere in the
/// app (the wallet's own list, the dashboard's recent list, "all
/// transactions") lands here instead of a separate pushed page, with every
/// field editable in place rather than through a generic add/edit form.
///
/// It opens read-only unless [startInEditMode] is set - a plain tap shows
/// the transaction with no edit affordances at all, and only an explicit
/// "Edit" action (the wallet screen's row menu) opens it editable. New
/// transactions are added through [showTransactionFormSheet] instead.
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

/// Deletes [transaction] the same way every delete in the app works:
/// confirm, hide it from the wallet's list straight away, show a 5 s
/// snackbar with Undo, and only then delete it from the database.
///
/// Uses the app's [ProviderContainer] rather than a widget's `ref`, because
/// the edit sheet closes before the 5 s are up and a closed sheet's `ref`
/// can no longer be used. The `listen` keeps the wallet's list provider
/// alive (and loaded) for the whole flow, even when no screen is showing
/// it - e.g. a delete started from the dashboard.
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
    await container.read(provider.future);
    final viewModel = container.read(provider.notifier);
    if (!viewModel.hideTransaction(transaction.id!)) return;
    onConfirmed?.call();

    var undone = false;
    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.transactionDeleted),
        duration: const Duration(seconds: 5),
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            undone = true;
            viewModel.restoreTransaction();
          },
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 5));
    if (undone) return;

    try {
      await viewModel.confirmDelete(transaction.id!);
    } catch (_) {
      viewModel.restoreTransaction();
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.transactionDeleteError)),
      );
    }
  } finally {
    subscription.close();
  }
}

/// Which field (if any) is currently being edited in place. Editing never
/// opens a second bottom sheet stacked on top of this one - the sheet's own
/// content swaps to the field's editor, with a back chevron to return, like
/// a tab rather than a stack of modals. Date keeps the platform's native
/// date/time pickers, which are a different (and already modal) paradigm.
enum _EditField { amount, name, type, category, note }

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
  /// Starts wherever [widget.startInEditMode] says, but - unlike before -
  /// can now flip on in-sheet: the view screen's "Edit transaction" button
  /// switches into the edit screen without closing and reopening the sheet.
  late bool _editable = widget.startInEditMode;

  _EditField? _activeField;

  /// The form as it was when editing started - what Cancel goes back to.
  late TransactionFormState _beforeEdit;

  late final TextEditingController _amountController;
  late final TextEditingController _nameController;
  late final TextEditingController _noteController;
  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _noteFocusNode = FocusNode();

  TransactionFormState get _formState =>
      ref.read(transactionFormViewModelProvider(widget.transaction));

  TransactionFormViewModel _viewModel(WidgetRef ref) =>
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
    _nameFocusNode.dispose();
    _noteFocusNode.dispose();
    super.dispose();
  }

  void _openField(_EditField field) {
    final formState = _formState;
    switch (field) {
      case _EditField.amount:
        _amountController.text = _trimTrailingZeros(formState.amount);
      case _EditField.name:
        _nameController.text = formState.description;
      case _EditField.note:
        _noteController.text = formState.note;
      case _EditField.type:
      case _EditField.category:
        break;
    }
    setState(() => _activeField = field);
  }

  void _closeField() => setState(() => _activeField = null);

  bool _isFieldDirty(_EditField field) {
    final formState = _formState;
    return switch (field) {
      _EditField.amount => _amountController.text != formState.amount,
      _EditField.name => _nameController.text != formState.description,
      _EditField.note => _noteController.text != formState.note,
      _EditField.type || _EditField.category => false,
    };
  }

  /// Leaving a text-entry field editor (Amount/Name/Note) via the back
  /// chevron - rather than its own "Done" button - would otherwise silently
  /// drop whatever was typed. Type/Category commit the instant an option is
  /// tapped, so there is never anything unsaved to ask about for those.
  Future<void> _handleFieldBack(_EditField field) async {
    if (!_isFieldDirty(field)) {
      _closeField();
      return;
    }

    final l10n = AppLocalizations.of(context);
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.discardChangesTitle),
        content: Text(l10n.discardChangesMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.discard),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (!mounted) return;

    if (shouldSave ?? false) {
      switch (field) {
        case _EditField.amount:
          _confirmAmount();
        case _EditField.name:
          _confirmName();
        case _EditField.note:
          _confirmNote();
        case _EditField.type:
        case _EditField.category:
          break;
      }
    } else {
      _closeField();
    }
  }

  // Every field just stages its change on the form view-model - nothing
  // reaches the database until "Save changes" is pressed, matching the new
  // edit screen's own Cancel/Save pair instead of the old commit-per-field
  // behavior (which had no way to back out of an in-progress edit).
  void _confirmAmount() {
    _viewModel(ref).updateAmount(_amountController.text);
    _closeField();
  }

  void _confirmName() {
    _viewModel(ref).updateDescription(_nameController.text);
    _closeField();
  }

  void _confirmNote() {
    _viewModel(ref).updateNote(_noteController.text);
    _closeField();
  }

  void _selectType(TransactionType value) {
    _viewModel(ref).updateType(value);
    _closeField();
  }

  void _selectCategory(int? value) {
    _viewModel(ref).updateCategoryId(value);
    _closeField();
  }

  void _appendAmountDigit(String digit) {
    final value = _amountController.text;
    final decimalIndex = value.indexOf('.');
    if (decimalIndex != -1 && value.length - decimalIndex > 2) return;
    setState(() => _amountController.text = '$value$digit');
  }

  void _appendAmountDecimalPoint() {
    final value = _amountController.text;
    if (value.contains('.')) return;
    setState(() => _amountController.text = value.isEmpty ? '0.' : '$value.');
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
    final current = formState.date ?? DateTime.now();
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null || !mounted) return;

    final merged = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      current.hour,
      current.minute,
    );
    _viewModel(ref).updateDate(merged);
  }

  Future<void> _saveChanges() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = AppLocalizations.of(context);
    final formState = _formState;

    final amountInCents = parseToCents(formState.amount, allowNegative: false);
    if (amountInCents == null || amountInCents <= 0) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.amountRequired)));
      return;
    }
    if (formState.date == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.dateRequired)));
      return;
    }

    try {
      final success = await _viewModel(ref).save(widget.transaction);
      if (!success || !mounted) return;
      setState(() => _editable = false);
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.transactionSaveError)),
      );
    }
  }

  /// Discards every staged change by putting back the form (and the text
  /// fields) as they were when editing started, then leaves edit mode.
  void _cancelEdit() {
    _viewModel(ref).restore(_beforeEdit);
    _amountController.text = _beforeEdit.amount;
    _nameController.text = _beforeEdit.description;
    _noteController.text = _beforeEdit.note;
    setState(() => _editable = false);
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
      _EditField.name => l10n.name,
      _EditField.type => l10n.type,
      _EditField.category => l10n.category,
      _EditField.note => l10n.transactionNote,
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
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final wallet = switch (walletsAsync) {
      AsyncValue(:final value?) =>
        value.where((w) => w.id == formState.walletId).firstOrNull,
      _ => null,
    };

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
            ? _buildEditList(context, formState, categories, currency)
            : _buildViewList(context, formState, categories, currency, wallet),
      ),
    );
  }

  /// Read-only: a category badge + name/category/type header, the amount
  /// in its own card, a grouped card for Date/Wallet/Note, and Delete +
  /// "Edit transaction" actions at the bottom - tapping Edit switches this
  /// same sheet into [_buildEditList] rather than opening anything new.
  Widget _buildViewList(
    BuildContext context,
    TransactionFormState formState,
    List<Category> categories,
    Currency currency,
    Wallet? wallet,
  ) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();

    final isIncome = formState.type == TransactionType.income;
    final amountColor = isIncome ? colors.primaryStrong : colors.error;
    final amountCents = parseToCents(formState.amount, allowNegative: false);
    final amountText = amountCents == null
        ? '—'
        : '${isIncome ? '+' : '-'}${formatCents(amountCents, currencyCode: currency.code)}';
    final category = categories
        .where((c) => c.id == formState.categoryId)
        .firstOrNull;
    final categoryIcon = category == null
        ? AppIcons.categoryGeneric
        : category.type.icon;
    final categoryLabel = category == null
        ? l10n.none
        : (category.isDefault ? category.type.label(l10n) : category.name);
    final name = formState.description.trim().isEmpty
        ? l10n.transactionDefaultDescription
        : formState.description.trim();
    final dateLabel = formState.date == null
        ? '—'
        : DateFormat('EEE d MMM', locale).format(formState.date!);
    final walletLabel = wallet == null
        ? '—'
        : '${wallet.name} · ${wallet.type.label(l10n)}';
    final noteLabel = formState.note.trim().isEmpty
        ? '—'
        : formState.note.trim();

    return Padding(
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
              _DashedCircleBadge(icon: categoryIcon, color: amountColor),
              const SizedBox(width: Spacing.sm),
              Expanded(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.amount,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
                Text(
                  amountText,
                  style: context.headlineLgStrong.copyWith(color: amountColor),
                ),
              ],
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
                  icon: Icons.calendar_today_outlined,
                  label: l10n.date,
                  value: dateLabel,
                ),
                _ViewInfoRow(
                  icon: Icons.account_balance_wallet_outlined,
                  label: l10n.wallet,
                  value: walletLabel,
                ),
                _ViewInfoRow(
                  icon: Icons.notes_outlined,
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
              // A plain circle, same ~48px normal-button size as "Edit
              // transaction"'s height - not an elongated pill.
              Tooltip(
                message: l10n.delete,
                child: Material(
                  color: colors.error.withValues(alpha: 0.08),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: _delete,
                    child: Padding(
                      padding: const EdgeInsets.all(Spacing.component),
                      child: Icon(
                        AppIcons.delete,
                        size: IconSize.xl,
                        color: colors.error,
                      ),
                    ),
                  ),
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
                    vertical: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Editable: a Type toggle + Amount in one card, Name directly editable
  /// in place (the dashed accent border marks it as "already open for
  /// typing"), Category/Date drilling into their own pickers same as
  /// before, Note directly editable too, then Cancel/Save changes. Nothing
  /// here reaches the database until Save is pressed.
  Widget _buildEditList(
    BuildContext context,
    TransactionFormState formState,
    List<Category> categories,
    Currency currency,
  ) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();

    final isIncome = formState.type == TransactionType.income;
    final amountColor = isIncome ? colors.primaryStrong : colors.error;
    final amountCents = parseToCents(formState.amount, allowNegative: false);
    final amountText = amountCents == null
        ? '—'
        : '${isIncome ? '+' : '-'}${formatCents(amountCents, currencyCode: currency.code)}';
    final category = categories
        .where((c) => c.id == formState.categoryId)
        .firstOrNull;
    final categoryIcon = category == null
        ? AppIcons.categoryGeneric
        : category.type.icon;
    final categoryLabel = category == null
        ? l10n.none
        : (category.isDefault ? category.type.label(l10n) : category.name);
    final dateLabel = formState.date == null
        ? '—'
        : DateFormat('EEE d MMM', locale).format(formState.date!);

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
          // No grabber here - the back chevron already signals how to leave
          // this screen, so a second "drag me" affordance above it is just
          // visual noise.
          Row(
            children: [
              IconButton(
                tooltip: l10n.back,
                onPressed: _cancelEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(
                  l10n.editTransactionAction,
                  style: context.headlineLgStrong,
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
                  onChanged: (type) => _viewModel(ref).updateType(type),
                ),
                const SizedBox(height: Spacing.sm),
                InkWell(
                  key: const Key('txAmountField'),
                  borderRadius: BorderRadius.circular(Rounded.md),
                  onTap: () => _openField(_EditField.amount),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      amountText,
                      textAlign: TextAlign.center,
                      style: context.headlineLgStrong.copyWith(
                        color: amountColor,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Spacing.sm),
          ListenableBuilder(
            listenable: _nameFocusNode,
            builder: (context, child) => Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: Spacing.md,
                vertical: Spacing.sm,
              ),
              decoration: BoxDecoration(
                color: colors.surfaceContainer,
                borderRadius: BorderRadius.circular(Rounded.lg),
                border: _nameFocusNode.hasFocus
                    ? Border.all(color: colors.primary, width: 2)
                    : null,
              ),
              child: child,
            ),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _nameFocusNode.requestFocus(),
              child: Row(
                children: [
                  FieldBadge(
                    icon: AppIcons.name,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.name,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        TextField(
                          key: const Key('txNameField'),
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) =>
                              _viewModel(ref).updateDescription(value),
                          decoration: const InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              vertical: Spacing.xs,
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
            icon: Icons.calendar_today_outlined,
            label: l10n.date,
            value: dateLabel,
            onTap: () => _editDate(formState),
          ),
          const SizedBox(height: Spacing.sm),
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
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _noteFocusNode.requestFocus(),
              child: Row(
                children: [
                  FieldBadge(
                    icon: Icons.notes_outlined,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: Spacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          l10n.transactionNote,
                          style: context.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        TextField(
                          controller: _noteController,
                          focusNode: _noteFocusNode,
                          textCapitalization: TextCapitalization.sentences,
                          onChanged: (value) =>
                              _viewModel(ref).updateNote(value),
                          decoration: InputDecoration(
                            isCollapsed: true,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: Spacing.xs,
                            ),
                            hintText: l10n.transactionNote,
                          ),
                          style: context.bodyMdBold,
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
              // As close to equal width as "Save changes" (the longer
              // label) allows without wrapping - Cancel and Save carry the
              // same hierarchy, so neither should dominate the other.
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
                    horizontal: 4,
                    vertical: 14,
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
              IconButton(
                tooltip: l10n.back,
                onPressed: () => _handleFieldBack(field),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              const SizedBox(width: Spacing.xs),
              Text(_fieldTitle(field, l10n), style: context.headlineLgStrong),
            ],
          ),
          const SizedBox(height: Spacing.md),
          switch (field) {
            _EditField.amount => _buildAmountEditor(
              context,
              formState,
              currency.code,
            ),
            _EditField.name => _buildTextEditor(_nameController, _confirmName),
            _EditField.note => _buildTextEditor(_noteController, _confirmNote),
            _EditField.type => _buildTypeEditor(context, formState),
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
    final typeLabel = isIncome
        ? l10n.transactionTypeIncome
        : l10n.transactionTypeExpense;
    final cents = parseToCents(_amountController.text, allowNegative: false);
    final sign = isIncome ? '+' : '-';
    final displayValue = cents == null
        ? '$sign${_amountController.text}'
        : '$sign${formatCents(cents, currencyCode: currencyCode)}';

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
              Text(
                displayValue,
                style: context.amountDisplayBold.copyWith(color: color),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        _AmountNumpad(
          onDigit: _appendAmountDigit,
          onDecimalPoint: _appendAmountDecimalPoint,
          onBackspace: _amountBackspace,
        ),
        const SizedBox(height: Spacing.md),
        DashedStitchButton(label: l10n.done, onPressed: _confirmAmount),
      ],
    );
  }

  Widget _buildTextEditor(
    TextEditingController controller,
    VoidCallback onConfirm,
  ) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          textCapitalization: TextCapitalization.sentences,
          onSubmitted: (_) => onConfirm(),
        ),
        const SizedBox(height: Spacing.md),
        DashedStitchButton(label: l10n.done, onPressed: onConfirm),
      ],
    );
  }

  Widget _buildTypeEditor(
    BuildContext context,
    TransactionFormState formState,
  ) {
    final l10n = AppLocalizations.of(context);

    return RadioGroup<TransactionType>(
      groupValue: formState.type,
      onChanged: (value) {
        if (value != null) _selectType(value);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: TransactionType.values
            .map(
              (t) => RadioListTile<TransactionType>(
                title: Text(t.label(l10n)),
                value: t,
                contentPadding: EdgeInsets.zero,
              ),
            )
            .toList(),
      ),
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
              title: Text(c.isDefault ? c.type.label(l10n) : c.name),
              value: c.id,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }
}

/// The category-icon badge leading the view screen's header - a dashed
/// ring around a tinted circle, the same "physical token" language as the
/// app's other dashed-stitch accents, colored by income/expense like the
/// amount itself.
class _DashedCircleBadge extends StatelessWidget {
  const _DashedCircleBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 56,
      child: CustomPaint(
        painter: _DashedCirclePainter(color: color),
        child: Center(
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: IconSize.xl, color: color),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  const _DashedCirclePainter({required this.color});

  final Color color;

  static const _dashLength = 4.0;
  static const _gapLength = 3.0;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..addOval(Rect.fromLTWH(0, 0, size.width, size.height));
    final paint = Paint()
      ..color = color.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = (distance + _dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter oldDelegate) =>
      color != oldDelegate.color;
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
        Padding(
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
    required this.onDigit,
    required this.onDecimalPoint,
    required this.onBackspace,
  });

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
              child: _NumpadKey(label: '.', onTap: onDecimalPoint),
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
    return tooltip == null ? button : Tooltip(message: tooltip, child: button);
  }
}

/// "10.00" -> "10", "10.50" -> "10.5", "10.25" -> "10.25" - so the amount
/// keypad (max two decimals) has room to keep typing straight away. The
/// value is the same either way.
String _trimTrailingZeros(String amount) {
  if (!amount.contains('.')) return amount;
  final trimmed = amount.replaceFirst(RegExp(r'0+$'), '');
  return trimmed.endsWith('.')
      ? trimmed.substring(0, trimmed.length - 1)
      : trimmed;
}
