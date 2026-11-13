import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/undo_snack_bar.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../models/wallet.dart';
import '../../viewmodels/wallet_list_view_model.dart';

/// Asks, then deletes [wallet] with an Undo window, from the wallets list
/// or the wallet's own screen. [onConfirmed] runs once the user has said
/// yes and before the wallet disappears - the wallet's screen leaves there,
/// so it never shows a wallet that's gone.
Future<void> deleteWalletWithUndo(
  BuildContext context,
  Wallet wallet, {
  VoidCallback? onConfirmed,
}) async {
  final l10n = AppLocalizations.of(context);
  final messenger = ScaffoldMessenger.of(context);
  // Read through the container: the screen that asked may be gone by the
  // time the Undo window closes.
  final container = ProviderScope.containerOf(context, listen: false);

  final provider = walletListViewModelProvider();
  final subscription = container.listen(provider, (_, _) {});
  try {
    final viewModel = container.read(provider.notifier);
    // Its transactions go with it, so the question says how many. If they
    // can't be counted, it still asks, just without the number.
    int? count;
    try {
      count = await viewModel.transactionCount(wallet.id!);
    } catch (_) {
      count = null;
    }
    if (!context.mounted) return;
    final confirmed = await ConfirmationDialog.show(
      context,
      title: l10n.deleteWallet,
      content: count == null || count == 0
          ? l10n.deleteWalletConfirm(wallet.name)
          : l10n.deleteWalletWithTransactions(wallet.name, count),
      confirmLabel: l10n.delete,
    );
    if (!confirmed) return;

    onConfirmed?.call();
    if (!viewModel.hideWallet(wallet.id!)) return;

    final undone = await showUndoSnackBar(
      messenger,
      title: l10n.walletDeleted,
      subtitle: wallet.name,
      restoredLabel: l10n.walletRestored,
    );
    if (undone) {
      viewModel.restoreWallet(wallet.id!);
      return;
    }

    try {
      await viewModel.confirmDelete(wallet.id!);
    } catch (e) {
      viewModel.restoreWallet(wallet.id!);
      final message = failureMessage(l10n, e, unknown: l10n.deleteError);
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  } finally {
    subscription.close();
  }
}
