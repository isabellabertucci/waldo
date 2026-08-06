import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:waldo/l10n/app_localizations.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (index) {
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard),
            label: l10n.dashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.bar_chart),
            label: l10n.transactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet),
            label: l10n.wallets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
