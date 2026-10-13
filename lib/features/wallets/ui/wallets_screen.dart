import 'package:flutter/material.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/widgets/undo_snack_bar.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';

import '../../../core/widgets/confirmation_dialog.dart';
import '../../../core/widgets/empty_state.dart';
import 'package:waldo/core/widgets/eye_icon.dart';
import '../models/wallet.dart';
import '../viewmodels/wallet_list_view_model.dart';
import '../viewmodels/wallets_summary_view_model.dart';
import 'widgets/wallet_form_sheet.dart';
import 'widgets/wallets_card_stack.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/router/app_router.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await ConfirmationDialog.show(
      context,
      title: l10n.deleteWallet,
      content: l10n.deleteWalletConfirm(wallet.name),
      confirmLabel: l10n.delete,
    );

    if (!confirmed) return;

    final viewModel = ref.read(walletListViewModelProvider().notifier);

    if (!viewModel.hideWallet(wallet.id!)) return;

    final undone = await showUndoSnackBar(
      messenger,
      title: l10n.walletDeleted,
      subtitle: wallet.name,
      restoredLabel: l10n.walletRestored,
    );
    if (undone) {
      viewModel.restoreWallet();
      return;
    }

    try {
      await viewModel.confirmDelete(wallet.id!);
    } catch (_) {
      viewModel.restoreWallet();
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteError)));
    }
  }

  void _editWallet(BuildContext context, Wallet wallet) {
    showWalletFormSheet(context, wallet: wallet);
  }

  void _openWallet(BuildContext context, Wallet wallet) {
    TransactionsRoute(wallet.id!).push(context);
  }

  void _addWallet(BuildContext context) {
    showWalletFormSheet(context);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final isBalanceHidden = ref.watch(balanceHiddenProvider);
    final colors = context.appColors;
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final summaryAsync = ref.watch(walletsSummaryViewModelProvider);
    final keptPercent = switch (summaryAsync) {
      AsyncValue(:final value?) => value.keptPercent,
      _ => null,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.pageMargin,
                Spacing.xs,
                Spacing.pageMargin,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.wallets,
                    style: context.headlineSmBold.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      DashedStitchButton(
                        icon: const Icon(AppIcons.add),
                        tooltip: l10n.newWallet,
                        onPressed: () => _addWallet(context),
                      ),
                      const SizedBox(width: Spacing.xs),
                      CircleIconButton(
                        tooltip: isBalanceHidden
                            ? l10n.showBalance
                            : l10n.hideBalance,
                        onPressed: () =>
                            ref.read(balanceHiddenProvider.notifier).toggle(),
                        child: EyeIcon(
                          color: colors.onSurface,
                          hidden: isBalanceHidden,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: Spacing.md),
            Expanded(
              child: switch (walletsAsync) {
                AsyncValue(:final value?) when value.isEmpty => EmptyState(
                  icon: AppIcons.wallets,
                  title: l10n.noWalletsYet,
                  subtitle: l10n.addFirstWallet,
                ),
                AsyncValue(:final value?) => WalletsCardStack(
                  wallets: value,
                  currency: currency,
                  isBalanceHidden: isBalanceHidden,
                  keptPercent: keptPercent,
                  onTapWallet: (wallet) => _openWallet(context, wallet),
                  onEditWallet: (wallet) => _editWallet(context, wallet),
                  onDeleteWallet: (wallet) =>
                      _confirmDelete(context, ref, wallet),
                ),
                AsyncValue(hasError: true) => Center(
                  child: Text(l10n.walletsError),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
      ),
    );
  }
}
