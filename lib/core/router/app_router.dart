import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/wallets/views/wallets_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/transactions/views/transaction_detail_screen.dart';
import '../../features/transactions/views/transaction_new_screen.dart';
import '../../features/transactions/views/transactions_screen.dart';

part 'app_router.g.dart';

// SHELL ROUTES -----------------------------------------------------------------

@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<DashboardBranch>(
      routes: [TypedGoRoute<DashboardRoute>(path: '/dashboard')],
    ),
    TypedStatefulShellBranch<WalletsBranch>(
      routes: [
        TypedGoRoute<WalletsRoute>(
          path: '/wallets',
          routes: [
            TypedGoRoute<TransactionsRoute>(
              path: ':walletId/transactions',
              routes: [
                TypedGoRoute<TransactionNewRoute>(path: 'new'),
                TypedGoRoute<TransactionDetailRoute>(path: ':id'),
              ],
            ),
          ],
        ),
      ],
    ),
    TypedStatefulShellBranch<SettingsBranch>(
      routes: [TypedGoRoute<SettingsRoute>(path: '/settings')],
    ),
  ],
)
class AppShellRoute extends StatefulShellRouteData {
  const AppShellRoute();

  @override
  Widget builder(
    BuildContext context,
    GoRouterState state,
    StatefulNavigationShell navigationShell,
  ) {
    return AppShell(navigationShell: navigationShell);
  }
}

// SHELL BRANCH TYPES ------------------------------------------------------------

class DashboardBranch extends StatefulShellBranchData {
  const DashboardBranch();
}

class WalletsBranch extends StatefulShellBranchData {
  const WalletsBranch();
}

class SettingsBranch extends StatefulShellBranchData {
  const SettingsBranch();
}

// SHELL ROUTES (screens) ---------------------------------------------------------

class DashboardRoute extends GoRouteData with $DashboardRoute {
  const DashboardRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const DashboardScreen();
  }
}

class WalletsRoute extends GoRouteData with $WalletsRoute {
  const WalletsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WalletsScreen();
  }
}

class TransactionsRoute extends GoRouteData with $TransactionsRoute {
  const TransactionsRoute(this.walletId);

  final int walletId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TransactionsScreen(walletId: walletId);
  }
}

class TransactionNewRoute extends GoRouteData with $TransactionNewRoute {
  const TransactionNewRoute(this.walletId);

  final int walletId;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TransactionNewScreen(walletId: walletId);
  }
}

class TransactionDetailRoute extends GoRouteData with $TransactionDetailRoute {
  const TransactionDetailRoute(this.walletId, this.id);

  final int walletId;
  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TransactionDetailScreen(walletId: walletId, id: id);
  }
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}
