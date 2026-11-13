import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/hide_amounts_button.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/core/widgets/ghost.dart';
import 'package:waldo/core/widgets/load_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/heading.dart';
import 'package:waldo/core/widgets/option_sheet.dart';
import 'package:waldo/core/widgets/sheet_page.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../models/wallet.dart';
import '../viewmodels/wallet_list_view_model.dart';
import '../wallets_x.dart';
import 'widgets/delete_wallet.dart';
import 'widgets/wallet_form_sheet.dart';
import 'widgets/wallet_list_row.dart';
import 'widgets/wallet_type_filter.dart';
import 'widgets/wallets_top.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: context.appColors.sheet,
      // No SafeArea: SheetPage pads for the status bar and navbar itself.
      body: switch (ref.watch(walletListViewModelProvider())) {
        AsyncValue(:final value?) => _WalletsBody(wallets: value),
        AsyncValue(hasError: true) => LoadError(
          message: l10n.walletsError,
          onRetry: () => ref.invalidate(walletListViewModelProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _WalletsBody extends ConsumerStatefulWidget {
  const _WalletsBody({required this.wallets});

  final List<Wallet> wallets;

  @override
  ConsumerState<_WalletsBody> createState() => _WalletsBodyState();
}

class _WalletsBodyState extends ConsumerState<_WalletsBody> {
  final _search = TextEditingController();
  var _isFilterOpen = false;

  /// The type the list shows, or null for all.
  WalletType? _type;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _showWalletActions(Wallet wallet) {
    final l10n = AppLocalizations.of(context);
    showActionSheet(
      context,
      title: wallet.name,
      actions: [
        (
          icon: AppIcons.edit,
          label: l10n.edit,
          onTap: () => showWalletFormSheet(context, wallet: wallet),
        ),
        (
          icon: AppIcons.delete,
          label: l10n.delete,
          onTap: () => deleteWalletWithUndo(context, wallet),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final currency = switch (ref.watch(preferencesViewModelProvider)) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final isBalanceHidden = ref.watch(balanceHiddenProvider);
    final wallets = widget.wallets;
    final positiveTotal = wallets
        .where((w) => w.currentBalance > 0)
        .fold(0, (sum, w) => sum + w.currentBalance);
    final query = _search.text.trim().toLowerCase();
    final shown = [
      for (final w in wallets)
        if ((_type == null || w.type == _type) &&
            w.name.toLowerCase().contains(query))
          w,
    ];
    const margin = EdgeInsets.symmetric(horizontal: Spacing.pageMargin);

    void toggleHidden() => ref.read(balanceHiddenProvider.notifier).toggle();

    return SheetPage(
      // Pinned once the top scrolls away, so the eye is in reach down a
      // long list. Nothing to hide before the first wallet.
      // Always, so nothing slides under the clock; the eye only once there
      // is something to hide.
      bar: SheetPageBar(
        title: l10n.wallets,
        amount: BalanceAmount(
          amount: formatSignedCents(
            wallets.fold(0, (sum, w) => sum + w.currentBalance),
            locale: moneyLocale(context),
            currencyCode: currency.code,
          ),
          hidden: isBalanceHidden,
          style: context.label.copyWith(color: colors.inkMuted),
          alignment: AlignmentDirectional.center,
        ),
        trailing: wallets.isEmpty
            ? null
            : HideAmountsButton(
                hidden: isBalanceHidden,
                onPressed: toggleHidden,
              ),
      ),
      top: WalletsTop(
        wallets: wallets,
        currency: currency,
        isBalanceHidden: isBalanceHidden,
        isFilterOpen: _isFilterOpen,
        filterValue: _type?.label(l10n),
        onToggleBalanceHidden: toggleHidden,
        onToggleFilter: () => setState(() => _isFilterOpen = !_isFilterOpen),
        onNewWallet: () => showWalletFormSheet(context),
      ),
      sheet: Padding(
        padding: margin,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.end,
              spacing: Spacing.xs,
              children: [
                Heading(
                  child: WholeWordsText(
                    l10n.yourWallets,
                    style: context.titleSection,
                  ),
                ),
                Text(
                  wallets.isEmpty
                      ? l10n.walletsNone
                      : l10n.walletsShownOf(shown.length, wallets.length),
                  style: context.label.copyWith(color: colors.inkMuted),
                ),
              ],
            ),
            if (wallets.isEmpty) ...[
              const SizedBox(height: Spacing.sm),
              GhostEmptyState(
                ghost: GhostRows(leading: GhostRows.wallet(context)),
                title: l10n.noWalletsYet,
                body: l10n.addFirstWallet,
              ),
            ] else ...[
              const SizedBox(height: Spacing.sm),
              _SearchField(
                controller: _search,
                onChanged: (_) => setState(() {}),
              ),
              AnimatedSize(
                duration: context.motion(Motion.segmentSwap),
                curve: Motion.segmentSwapCurve,
                alignment: Alignment.topCenter,
                child: !_isFilterOpen
                    ? const SizedBox(width: double.infinity)
                    : Padding(
                        padding: const EdgeInsets.only(top: Spacing.sm),
                        child: WalletTypeFilter(
                          wallets: wallets,
                          selected: _type,
                          onChanged: (type) => setState(() => _type = type),
                        ),
                      ),
              ),
              if (shown.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
                  child: Text(
                    l10n.noWalletsMatch,
                    textAlign: TextAlign.center,
                    style: context.body.copyWith(color: colors.inkMuted),
                  ),
                )
              else ...[
                for (final type in walletTypeOrder)
                  // Richest first, so the best wallets lead each group.
                  if (shown.where((w) => w.type == type).toList()..sort(
                        (a, b) => b.currentBalance.compareTo(a.currentBalance),
                      )
                      case final group when group.isNotEmpty) ...[
                    const SizedBox(height: Spacing.md),
                    // "CASH · 4", and what the group holds together.
                    Row(
                      children: [
                        Expanded(
                          child: Heading(
                            child: WholeWordsText(
                              '${type.label(l10n).toUpperCase()} · '
                              '${group.length}',
                              style: context.overline.copyWith(
                                color: colors.inkMuted,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: Spacing.xs),
                        BalanceAmount(
                          amount: formatCents(
                            group.fold(0, (sum, w) => sum + w.currentBalance),
                            locale: moneyLocale(context),
                            currencyCode: currency.code,
                          ),
                          hidden: isBalanceHidden,
                          style: context.bodyStrong.copyWith(
                            color: colors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: Spacing.xs),
                    // Each on its own card, a small gap apart.
                    for (final (i, wallet) in group.indexed) ...[
                      if (i > 0) const SizedBox(height: Spacing.xs),
                      WalletListRow(
                        wallet: wallet,
                        finish: wallet.finish,
                        positiveTotal: positiveTotal,
                        currency: currency,
                        isBalanceHidden: isBalanceHidden,
                        onTap: () =>
                            TransactionsRoute(wallet.id!).push(context),
                        onLongPress: () => _showWalletActions(wallet),
                      ),
                    ],
                  ],
                const SizedBox(height: Spacing.sm),
                Text(
                  l10n.walletRowHint,
                  textAlign: TextAlign.center,
                  style: context.label.copyWith(color: colors.inkMuted),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

/// "Search wallets", in a filled pill.
class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final pill = OutlineInputBorder(
      borderRadius: BorderRadius.circular(Rounded.pill),
      borderSide: BorderSide.none,
    );

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      style: context.body,
      decoration: InputDecoration(
        hintText: l10n.searchWallets,
        hintStyle: context.body.copyWith(color: colors.inkMuted),
        prefixIcon: Icon(
          AppIcons.search,
          size: IconSize.lg,
          color: colors.inkMuted,
        ),
        filled: true,
        fillColor: colors.card,
        border: pill,
        enabledBorder: pill,
        focusedBorder: pill.copyWith(borderSide: BorderSide(color: colors.ink)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: Spacing.sm,
          vertical: Spacing.sm,
        ),
      ),
    );
  }
}
