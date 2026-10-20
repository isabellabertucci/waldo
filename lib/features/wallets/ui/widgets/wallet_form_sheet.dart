import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/amount_input_formatter.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/form_pill_field.dart';
import 'package:waldo/core/widgets/option_tile.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

final _log = Logger('waldo.ui.wallet_form');

/// Opens the wallet form; pass [wallet] to edit it.
Future<void> showWalletFormSheet(BuildContext context, {Wallet? wallet}) {
  return showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    useSafeArea: true,
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
    final lower = value.trim().toLowerCase();
    final taken = wallets.any(
      (w) => w.id != widget.wallet?.id && w.name.toLowerCase() == lower,
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      _log.fine('Wallet form validation failed');
      return;
    }

    final viewModel = ref.read(
      walletFormViewModelProvider(widget.wallet).notifier,
    );
    try {
      final success = await viewModel.save();
      if (success && mounted) Navigator.of(context).pop();
    } on DuplicateWalletNameException {
      // The list on screen was stale; the database still caught it.
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.walletNameTaken)));
      }
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.saveError)));
      }
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
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
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
              const SheetGrabber(),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isEditing ? l10n.editWallet : l10n.newWallet,
                      style: context.headlineLgStrong,
                    ),
                  ),
                  const SheetCloseButton(),
                ],
              ),
              const SizedBox(height: Spacing.md),
              FormPillField(
                fieldKey: const Key('walletNameField'),
                leading: const Icon(AppIcons.name),
                textCapitalization: TextCapitalization.sentences,
                maxLength: maxWalletNameLength,
                controller: _nameController,
                label: l10n.name,
                hint: l10n.walletNameHint,
                onChanged: viewModel.updateName,
                validator: (value) => _validateName(l10n, value, wallets),
              ),
              const SizedBox(height: Spacing.md),
              Text(
                l10n.type.toUpperCase(),
                style: context.bodySmBold.copyWith(
                  color: colors.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: Spacing.sm),
              GridView.count(
                // Scroll views add the screen's safe-area inset by default; this grid sits mid-sheet.
                padding: EdgeInsets.zero,
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: Spacing.sm,
                crossAxisSpacing: Spacing.sm,
                childAspectRatio: 1.05,
                children: [
                  for (final type in WalletType.values)
                    OptionTile(
                      icon: type.icon,
                      label: type.label(l10n),
                      selected: type == formState.type,
                      onTap: () => viewModel.updateType(type),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.md),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.startingBalance.toUpperCase(),
                      style: context.bodySmBold.copyWith(
                        color: colors.onSurfaceVariant,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  if (!_isEditing)
                    Text(
                      l10n.optional,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: Spacing.sm),
              FormPillField(
                fieldKey: const Key('walletBalanceField'),
                leading: Text(currency.symbol),
                trailing: currency.code,
                controller: _balanceController,
                // Locked once the wallet exists; the label says why.
                enabled: !_isEditing,
                label: _isEditing
                    ? l10n.balanceLocked
                    : l10n.startingBalancePrompt,
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
              const SizedBox(height: Spacing.md),
              SizedBox(
                width: double.infinity,
                child: DashedStitchButton(
                  icon: const Icon(AppIcons.check, size: IconSize.md),
                  label: _isEditing ? l10n.saveChanges : l10n.createWallet,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
