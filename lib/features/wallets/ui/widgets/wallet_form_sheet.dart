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
import 'package:waldo/core/widgets/sheet_close_button.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

final _log = Logger('waldo.ui.wallet_form');

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
  final _nameFocusNode = FocusNode();

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
    _nameFocusNode.dispose();
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
        MediaQuery.of(context).viewInsets.bottom + Spacing.md,
      ),
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
              child: Row(
                children: [
                  _FieldBadge(icon: AppIcons.name, color: colors.primary),
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
                        TextFormField(
                          key: const Key('walletNameField'),
                          controller: _nameController,
                          focusNode: _nameFocusNode,
                          onChanged: viewModel.updateName,
                          validator: (value) => _validateName(l10n, value),
                          textCapitalization: TextCapitalization.sentences,
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
                            hintText: l10n.walletNameHint,
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
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: Spacing.sm,
              crossAxisSpacing: Spacing.sm,
              childAspectRatio: 1.05,
              children: [
                for (final type in WalletType.values)
                  _TypeOption(
                    type: type,
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
                    _isEditing ? l10n.balanceLocked : l10n.startingBalanceHint,
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
    );
  }
}

class _FieldBadge extends StatelessWidget {
  const _FieldBadge({required this.icon, required this.color});

  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    // Always called with `colors.primary` - `onPrimary` is its ink/cream pair.
    final onColor = context.appColors.onPrimary;

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Icon(icon, size: IconSize.md, color: onColor),
    );
  }
}

/// One tile in the wallet-type grid - a dashed accent border plus a filled
/// icon disc when selected, a plain card otherwise. Mirrors the Name
/// field's own dashed-border language so the whole form reads as one
/// consistent "fill me in" surface.
class _TypeOption extends StatelessWidget {
  const _TypeOption({
    required this.type,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final WalletType type;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return Material(
      color: colors.surfaceContainer,
      borderRadius: BorderRadius.circular(Rounded.md),
      child: InkWell(
        borderRadius: BorderRadius.circular(Rounded.md),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(Rounded.md),
            border: selected
                ? Border.all(color: colors.primary, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary
                      : colors.onSurfaceVariant.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  type.icon,
                  size: IconSize.md,
                  color: selected ? colors.onPrimary : colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.bodySmBold.copyWith(color: colors.onSurface),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
