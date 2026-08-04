import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/empty_state.dart';
import '../models/wallet.dart';
import '../viewmodels/wallet_list_view_model.dart';
import 'wallet_form_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final walletsAsync = ref.watch(walletListViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.wallets)),
      body: switch (walletsAsync) {
        AsyncError(:final error) => Center(
          child: Text(l10n.walletsError(error.toString())),
        ),
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
    final l10n = AppLocalizations.of(context)!;

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

    final viewModel = ref.read(walletListViewModelProvider.notifier);

    // Hide immediately from the UI, without deleting from the database yet
    viewModel.hideWallet(wallet.id!);

    var undone = false;

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.walletDeleted),
        duration: const Duration(seconds: 5),
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
    } catch (e) {
      // If the real delete fails (e.g. foreign key constraint), restore it
      viewModel.restoreWallet();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

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
          subtitle: Text(wallet.type.name),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text((wallet.currentBalance / 100).toStringAsFixed(2)),
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
