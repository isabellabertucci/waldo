import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/choice_chips.dart';
import 'package:waldo/core/widgets/form_sheet_body.dart';
import 'package:waldo/core/widgets/app_sheet.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/amount_input_formatter.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/core/widgets/pill_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/core/widgets/leather_wallet.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_face.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_type_filter.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

final _log = Logger('waldo.ui.wallet_form');

/// Opens the wallet form; pass [wallet] to edit it.
Future<void> showWalletFormSheet(BuildContext context, {Wallet? wallet}) {
  return showAppSheet(
    context,
    // A new wallet's card lands in the stack once this has slid away.
    sheetAnimationStyle: AnimationStyle(
      reverseDuration: context.motion(Motion.sheetExit),
    ),
    builder: (_) => WalletFormSheet(wallet: wallet),
  );
}

class WalletFormSheet extends ConsumerStatefulWidget {
  const WalletFormSheet({super.key, this.wallet});

  final Wallet? wallet;

  @override
  ConsumerState<WalletFormSheet> createState() => _WalletFormSheetState();
}

class _WalletFormSheetState extends ConsumerState<WalletFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _balanceController;

  bool get _isEditing => widget.wallet != null;

  @override
  void initState() {
    super.initState();
    final initial = ref.read(walletFormViewModelProvider(widget.wallet));
    _nameController = TextEditingController(text: initial.name);
    _balanceController = TextEditingController(text: initial.startingBalance);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // The locked balance reads like every other amount: "500,00" on a
    // Portuguese phone. Only now is the phone's region readable.
    if (_isEditing) {
      _balanceController.text = _balanceController.text.replaceFirst(
        '.',
        decimalSeparator(moneyLocale(context)),
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  String? _validateName(
    AppLocalizations l10n,
    String? value,
    List<Wallet> wallets,
  ) {
    if (value == null || value.trim().isEmpty) {
      return l10n.nameRequired;
    }
    if (value.trim().length > maxWalletNameLength) {
      return l10n.nameTooLong;
    }
    // When editing, the wallet's own name doesn't count as taken.
    final key = nameKey(value);
    final taken = wallets.any(
      (w) => w.id != widget.wallet?.id && nameKey(w.name) == key,
    );
    return taken ? l10n.walletNameTaken : null;
  }

  String? _validateBalance(AppLocalizations l10n, String? value) {
    if (_isEditing) return null;
    if (value == null || value.trim().isEmpty) return null;

    final currentType = ref
        .read(walletFormViewModelProvider(widget.wallet))
        .type;
    final allowsNegative = currentType == WalletType.credit;
    final parsedCents = parseToCents(value, allowNegative: allowsNegative);

    if (parsedCents == null || parsedCents.abs() > maxBalanceCents) {
      return l10n.invalidNumber;
    }
    return null;
  }

  /// Shown above the button: a SnackBar would land behind the sheet.
  String? _saveError;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _log.fine('Wallet form validation failed');
      return;
    }

    final viewModel = ref.read(
      walletFormViewModelProvider(widget.wallet).notifier,
    );
    setState(() => _saveError = null);
    try {
      final success = await viewModel.save();
      if (success && mounted) Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      final message = e is DuplicateWalletNameException
          // The list on screen was stale; the database still caught it.
          ? l10n.walletNameTaken
          : failureMessage(l10n, e, unknown: l10n.saveError);
      setState(() => _saveError = message);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final formState = ref.watch(walletFormViewModelProvider(widget.wallet));
    // Names already in use, for the duplicate check as the user types.
    final wallets = ref.watch(walletListViewModelProvider()).value ?? const [];
    final viewModel = ref.read(
      walletFormViewModelProvider(widget.wallet).notifier,
    );
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    Widget sectionTitle(String text) => Heading(
      child: Text(
        text,
        style: context.bodyStrong.copyWith(color: colors.inkMuted),
      ),
    );
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final existing = widget.wallet;
    // The wallet as it will be, so each choice shows on the leather.
    final preview = Wallet(
      name: formState.name.trim().isEmpty
          ? (existing?.name ?? l10n.newWallet)
          : formState.name.trim(),
      type: formState.type,
      finish: formState.finish,
      currentBalance:
          existing?.currentBalance ??
          parseToCents(formState.startingBalance, allowNegative: true) ??
          0,
      createdAt: '',
    );

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
                      _isEditing ? l10n.editWallet : l10n.newWallet,
                      style: context.titleSection,
                    ),
                  ),
                ),
                const SheetCloseButton(),
              ],
            ),
            const SizedBox(height: Spacing.md),
            Center(
              child: ExcludeSemantics(
                child: _WalletPreview(wallet: preview, currency: currency),
              ),
            ),
            const SizedBox(height: Spacing.md),
            FormPillField(
              fieldKey: const Key('walletNameField'),
              textCapitalization: TextCapitalization.sentences,
              maxLength: maxWalletNameLength,
              controller: _nameController,
              label: l10n.name,
              required: true,
              hint: l10n.walletNameHint,
              onChanged: viewModel.updateName,
              validator: (value) => _validateName(l10n, value, wallets),
            ),
            const SizedBox(height: Spacing.md),
            sectionTitle(l10n.type),
            const SizedBox(height: Spacing.xs),
            ChoiceChips(
              chips: [
                for (final type in walletTypeOrder)
                  (value: type, icon: type.icon, label: type.label(l10n)),
              ],
              selected: formState.type,
              onTap: viewModel.updateType,
            ),
            const SizedBox(height: Spacing.md),
            sectionTitle(l10n.leatherColour),
            const SizedBox(height: Spacing.xs),
            _LeatherSwatches(
              selected: formState.finish,
              onChanged: viewModel.updateFinish,
            ),
            const SizedBox(height: Spacing.md),
            FormPillField(
              fieldKey: const Key('walletBalanceField'),
              trailing: currency.symbol,
              controller: _balanceController,
              // Locked once the wallet exists; the line below says why.
              enabled: !_isEditing,
              label: l10n.startingBalance,
              hint: zeroAmountHint(moneyLocale(context)),
              onChanged: viewModel.updateBalance,
              validator: (value) => _validateBalance(l10n, value),
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              // "-" for credit cards; the validator rejects it for other types.
              inputFormatters: const [
                AmountInputFormatter(allowNegative: true),
              ],
            ),
            if (_isEditing) ...[
              const SizedBox(height: Spacing.xxs),
              Text(
                l10n.balanceLocked,
                style: context.caption.copyWith(color: colors.inkMuted),
              ),
            ],
            const SizedBox(height: Spacing.md),
            if (_saveError case final error?) ...[
              SizedBox(
                width: double.infinity,
                child: Text(
                  error,
                  textAlign: TextAlign.center,
                  style: context.bodyStrong.copyWith(color: colors.negative),
                ),
              ),
              const SizedBox(height: Spacing.sm),
            ],
            SizedBox(
              width: double.infinity,
              child: PillButton(
                label: _isEditing ? l10n.saveChanges : l10n.createWallet,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The wallet as the form has it, on a smaller leather.
class _WalletPreview extends StatelessWidget {
  const _WalletPreview({required this.wallet, required this.currency});

  final Wallet wallet;
  final Currency currency;

  @override
  Widget build(BuildContext context) {
    const size = ComponentSize.walletPreview;

    // The wallet's own screen's leather, scaled down, so it's the same
    // wallet the form makes.
    return SizedBox.fromSize(
      size: size,
      child: FittedBox(
        child: SizedBox(
          width: ComponentSize.walletAloneWidth,
          height: ComponentSize.wallet,
          child: LeatherWallet(
            finish: wallet.finish,
            child: WalletFace(
              wallet: wallet,
              finish: wallet.finish,
              currency: currency,
              isBalanceHidden: false,
            ),
          ),
        ),
      ),
    );
  }
}

/// The four leathers as round swatches; the chosen one ringed in ink.
class _LeatherSwatches extends StatelessWidget {
  const _LeatherSwatches({required this.selected, required this.onChanged});

  final LeatherFinish selected;
  final ValueChanged<LeatherFinish> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Wrap(
      spacing: Spacing.component,
      runSpacing: Spacing.component,
      children: [
        for (final finish in LeatherFinish.values)
          Semantics(
            button: true,
            selected: finish == selected,
            label: finish.label(l10n),
            excludeSemantics: true,
            onTap: () => onChanged(finish),
            child: GestureDetector(
              onTap: () => onChanged(finish),
              child: Container(
                padding: const EdgeInsets.all(ComponentSize.swatchRingGap),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: finish == selected ? colors.ink : colors.transparent,
                    width: ComponentSize.swatchRing,
                  ),
                ),
                child: Container(
                  width: ComponentSize.swatch,
                  height: ComponentSize.swatch,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [finish.colors.$1, finish.colors.$2],
                    ),
                    // The white leather would vanish on the white sheet.
                    border: Border.all(color: colors.line),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
