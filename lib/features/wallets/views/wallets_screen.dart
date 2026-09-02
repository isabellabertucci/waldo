import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/utils.dart';

import '../../../core/widgets/empty_state.dart';
import '../models/wallet.dart';
import '../viewmodels/wallet_list_view_model.dart';
import '../wallets_x.dart';
import 'widgets/wallet_form_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/router/app_router.dart';

enum _WalletAction { edit, delete }

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
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: context.appColors.surfaceContainer,
              foregroundColor: context.appColors.onSurface,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Rounded.lg),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          const SizedBox(width: 8),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: context.appColors.error,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Rounded.lg),
              ),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final viewModel = ref.read(walletListViewModelProvider().notifier);

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

    return Padding(
      padding: const EdgeInsets.all(Spacing.lg),
      child: ListView.separated(
        separatorBuilder: (context, index) =>
            const SizedBox(height: Spacing.md),
        itemCount: wallets.length,
        itemBuilder: (context, index) {
          final wallet = wallets[index];
          final colors = context.appColors;
          final badgeStyle = wallet.type.style;

          return ListTile(
            onTap: () {
              TransactionsRoute(wallet.id!).push(context);
            },
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: badgeStyle.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                wallet.type.icon,
                color: badgeStyle.foreground,
                size: 20,
              ),
            ),
            title: Text(
              wallet.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              wallet.type.label(l10n),
              style: context.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  formatCents(wallet.currentBalance),
                  style: context.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                PopupMenuButton<_WalletAction>(
                  icon: Icon(
                    Icons.more_vert,
                    color: colors.onSurfaceVariant,
                    size: 20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(Rounded.md),
                  ),
                  onSelected: (action) => switch (action) {
                    _WalletAction.edit => showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      builder: (_) => WalletFormSheet(wallet: wallet),
                    ),
                    _WalletAction.delete => _confirmDelete(
                      context,
                      ref,
                      wallet,
                    ),
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _WalletAction.edit,
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18),
                          SizedBox(width: Spacing.sm),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: _WalletAction.delete,
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: colors.error,
                          ),
                          const SizedBox(width: Spacing.sm),
                          Text(
                            l10n.delete,
                            style: TextStyle(color: colors.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
