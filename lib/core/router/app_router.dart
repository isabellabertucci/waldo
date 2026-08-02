import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../../features/dashboard/ui/dashboard_screen.dart';
import '../../features/wallets/ui/wallets_screen.dart';
import '../../features/settings/ui/settings_screen.dart';
import '../../features/transactions/ui/transaction_detail_screen.dart';
import '../../features/transactions/ui/transaction_new_screen.dart';
import '../../features/transactions/ui/transactions_screen.dart';

part 'app_router.g.dart';

// SHELL ROUTES -----------------------------------------------------------------

@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<DashboardBranch>(
      routes: [TypedGoRoute<DashboardRoute>(path: '/dashboard')],
    ),
    TypedStatefulShellBranch<ReportsBranch>(
      routes: [TypedGoRoute<ReportsRoute>(path: '/wallets')],
    ),
    TypedStatefulShellBranch<TransactionsBranch>(
      routes: [
        TypedGoRoute<TransactionsRoute>(
          path: '/transactions',
          routes: [
            TypedGoRoute<TransactionNewRoute>(path: 'new'),
            TypedGoRoute<TransactionDetailRoute>(path: ':id'),
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

class TransactionsBranch extends StatefulShellBranchData {
  const TransactionsBranch();
}

class ReportsBranch extends StatefulShellBranchData {
  const ReportsBranch();
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

class TransactionsRoute extends GoRouteData with $TransactionsRoute {
  const TransactionsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TransactionsScreen();
  }
}

class TransactionNewRoute extends GoRouteData with $TransactionNewRoute {
  const TransactionNewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TransactionNewScreen();
  }
}

class TransactionDetailRoute extends GoRouteData with $TransactionDetailRoute {
  const TransactionDetailRoute(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TransactionDetailScreen(id: id);
  }
}

class ReportsRoute extends GoRouteData with $ReportsRoute {
  const ReportsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const WalletsScreen();
  }
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsScreen();
  }
}
