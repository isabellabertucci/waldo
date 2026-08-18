import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/utils/utils.dart';

import '../../../core/widgets/empty_state.dart';
import '../models/wallet.dart';
import '../viewmodels/wallet_list_view_model.dart';
import 'widgets/wallet_form_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final walletsAsync = ref.watch(walletListViewModelProvider());

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wallets)),
      body: switch (walletsAsync) {
        AsyncError() => Center(child: Text(l10n.walletsError)),
        AsyncData(:final value) => _WalletsBody(wallets: value),
        _ => const Center(child: CircularProgressIndicator()),
      },
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (_) => const WalletFormSheet(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _WalletsBody extends ConsumerWidget {
  const _WalletsBody({required this.wallets});

  final List<Wallet> wallets;

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Wallet wallet,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteWallet),
        content: Text(l10n.deleteWalletConfirm(wallet.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final viewModel = ref.read(walletListViewModelProvider().notifier);

    // Hide immediately from the UI, without deleting from the database yet.
    // If the list hasn't loaded there's nothing to hide, so abort the flow
    // instead of scheduling a delete with no way to undo it.
    if (!viewModel.hideWallet(wallet.id!)) return;

    var undone = false;

    messenger.showSnackBar(
      SnackBar(
        content: Text(l10n.walletDeleted),
        duration: const Duration(seconds: 5),
        persist: false,
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () {
            undone = true;
            viewModel.restoreWallet();
          },
        ),
      ),
    );

    await Future.delayed(const Duration(seconds: 5));

    if (undone) return;

    try {
      await viewModel.confirmDelete(wallet.id!);
    } catch (_) {
      // If the real delete fails, restore it. Show a generic message,
      // never the raw database error, to the user.
      viewModel.restoreWallet();
      messenger.showSnackBar(SnackBar(content: Text(l10n.deleteError)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (wallets.isEmpty) {
      return EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: l10n.noWalletsYet,
        subtitle: l10n.addFirstWallet,
      );
    }

    return ListView.builder(
      itemCount: wallets.length,
      itemBuilder: (context, index) {
        final wallet = wallets[index];
        return ListTile(
          title: Text(wallet.name),
          subtitle: Text(walletTypeLabel(l10n, wallet.type)),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(formatCents(wallet.currentBalance)),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => WalletFormSheet(wallet: wallet),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, ref, wallet),
              ),
            ],
          ),
        );
      },
    );
  }
}
