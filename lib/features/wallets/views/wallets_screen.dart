import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:waldo/core/widgets/empty_state.dart';

import '../models/wallet.dart';
import '../viewmodels/wallet_list_view_model.dart';
import 'wallet_form_sheet.dart';

class WalletsScreen extends ConsumerWidget {
  const WalletsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final walletsAsync = ref.watch(walletListViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
      body: switch (walletsAsync) {
        AsyncError(:final error) => Center(child: Text('Error: $error')),
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (wallets.isEmpty) {
      return const EmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No wallets yet',
        subtitle: 'Tap + to add your first wallet',
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
              Text('${wallet.currentBalance / 100}'),
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
                onPressed: () async {
                  await ref
                      .read(walletListViewModelProvider.notifier)
                      .deleteWallet(wallet.id!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
