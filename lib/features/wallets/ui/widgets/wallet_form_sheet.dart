import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:waldo/core/constants/app_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/form_name_field.dart';
import 'package:waldo/core/widgets/option_tile.dart';
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';
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

  String? _validateName(AppLocalizations l10n, String? value) {
    if (value == null || value.trim().isEmpty) {
      return l10n.nameRequired;
    }
    if (value.trim().length > maxWalletNameLength) {
      return l10n.nameTooLong;
    }
    return null;
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
      final success = await viewModel.save(widget.wallet);
      if (success && mounted) Navigator.of(context).pop();
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
    final viewModel = ref.read(
      walletFormViewModelProvider(widget.wallet).notifier,
    );
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currencySymbol = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency.symbol,
      _ => Currency.usd.symbol,
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
                      _isEditing ? l10n.editWallet : l10n.newWallet,
                      style: context.headlineLgStrong,
                    ),
                  ),
                  const SheetCloseButton(),
                ],
              ),
              const SizedBox(height: Spacing.md),
              FormNameField(
                fieldKey: const Key('walletNameField'),
                controller: _nameController,
                label: l10n.name,
                hint: l10n.walletNameHint,
                onChanged: viewModel.updateName,
                validator: (value) => _validateName(l10n, value),
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
              const SizedBox(height: Spacing.sm),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(Spacing.md),
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(Rounded.lg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.startingBalance,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: Spacing.xs),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          currencySymbol,
                          style: context.amountDisplayBold.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            key: const Key('walletBalanceField'),
                            controller: _balanceController,
                            enabled: !_isEditing,
                            onChanged: viewModel.updateBalance,
                            validator: (value) => _validateBalance(l10n, value),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,\-]'),
                              ),
                            ],
                            decoration: const InputDecoration(
                              isCollapsed: true,
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              errorBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              filled: false,
                              hintText: '0.00',
                            ),
                            style: context.amountDisplayBold.copyWith(
                              color: colors.onSurface,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    Text(
                      _isEditing
                          ? l10n.balanceLocked
                          : l10n.startingBalanceHint,
                      style: context.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
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
                  label: _isEditing ? l10n.saveChanges : l10n.createWallet,
                  onPressed: _save,
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.md,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
