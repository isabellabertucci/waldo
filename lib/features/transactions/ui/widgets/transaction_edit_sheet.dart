import 'package:flutter/material.dart';
import 'package:waldo/core/theme/dynamic_type_scaler.dart';
import 'package:waldo/core/widgets/badge_row.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/core/theme/alpha.dart';
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
import 'category_picker.dart';
import 'transaction_amount_card.dart';
import 'transaction_date_picker.dart';
import 'transaction_field_row.dart';

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

/// Cancel and Save: room for "Save changes" beside Cancel, at a 48px height.
const _actionPadding = EdgeInsets.symmetric(
  horizontal: Spacing.xxs,
  vertical: Spacing.sm,
);

/// The amount, category and date as the view shows them; the edit list
/// shows the category and date the same way.
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The amount reads as this phone types it, as the wallet sheet's does.
    // Only now is the phone's region readable.
    _amountController.text = _localAmount(_amountController.text);
  }

  /// A stored "10.50" as this phone types it ("10,50" in Portugal).
  String _localAmount(String amount) =>
      amount.replaceFirst('.', decimalSeparator(moneyLocale(context)));

  @override
  void dispose() {
    _amountController.dispose();
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
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

    final amountError = TransactionAmountCard.validate(l10n, formState.amount);
    if (amountError != null) {
      setState(() => _saveError = amountError);
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
    _amountController.text = _localAmount(_beforeEdit.amount);
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

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Rounded.lg),
          ),
        ),
        child: _editable
            ? _buildEditList(context, formState, summary, categories)
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
          // leave this screen. At accessibility sizes the badge sits above
          // the title and the close button stays at the top.
          BadgeRow(
            crossAxisAlignment: DynamicTypeScaler.isAccessibilitySize(context)
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.center,
            badge: DashedCircleBadge(icon: categoryIcon, color: amountColor),
            trailing: const Padding(
              padding: EdgeInsets.only(left: Spacing.sm),
              child: SheetCloseButton(),
            ),
            child: MergeSemantics(
              child: Semantics(
                // The sheet's title, read with its category and type.
                header: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    WholeWordsText.singleLine(
                      name,
                      style: context.headlineLgExtraBold,
                    ),
                    WholeWordsText.singleLine(
                      '$categoryLabel · ${formState.type.label(l10n)}',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
                    style: context.headlineLgExtraBold.copyWith(
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
                tint: colors.error.withValues(alpha: Alpha.tint),
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
    List<Category> categories,
  ) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final cancel = DashedStitchButton(
      variant: StitchVariant.secondary,
      label: l10n.cancel,
      onPressed: _cancelEdit,
      compact: true,
      padding: _actionPadding,
    );
    final save = DashedStitchButton(
      icon: const Icon(AppIcons.check, size: IconSize.sm),
      label: l10n.saveChanges,
      onPressed: _saveChanges,
      compact: true,
      padding: _actionPadding,
    );

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
                    style: context.headlineLgExtraBold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: Spacing.md),
          // The same card as the new-transaction sheet, typed with the
          // system keyboard.
          TransactionAmountCard(
            fieldKey: const Key('txAmountField'),
            type: formState.type,
            onTypeChanged: _viewModel.updateType,
            controller: _amountController,
            onChanged: _viewModel.updateAmount,
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
            icon: summary.categoryIcon,
            label: l10n.category,
            value: summary.categoryLabel,
            // The same row and picker as the new-transaction sheet.
            onTap: () => showCategoryPicker(
              context,
              categories: categories,
              selected: formState.categoryId,
              onPicked: _viewModel.updateCategoryId,
            ),
          ),
          const SizedBox(height: Spacing.sm),
          EditFieldRow(
            icon: AppIcons.calendar,
            label: l10n.date,
            required: true,
            value: summary.dateLabel,
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
          // One button in two variants, so they match in size. At
          // accessibility sizes they stack, save first, as the dialog's do.
          if (DynamicTypeScaler.isAccessibilitySize(context))
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: Spacing.xs,
              children: [save, cancel],
            )
          else
            Row(
              children: [
                Expanded(child: cancel),
                const SizedBox(width: Spacing.xs),
                Expanded(child: save),
              ],
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
            child: BadgeRow(
              badge: FieldBadge(icon: icon, color: colors.onSurfaceVariant),
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
                  WholeWordsText.singleLine(value, style: context.bodyMdBold),
                ],
              ),
            ),
          ),
        ),
        if (showDivider) const Divider(),
      ],
    );
  }
}
