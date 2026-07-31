import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'app_shell.dart';
import '../../features/accounts/presentation/accounts_page.dart';
import '../../features/dashboard/presentation/dashboard_page.dart';
import '../../features/reports/presentation/reports_page.dart';
import '../../features/settings/presentation/settings_page.dart';
import '../../features/transactions/presentation/transaction_detail_page.dart';
import '../../features/transactions/presentation/transaction_new_page.dart';
import '../../features/transactions/presentation/transactions_page.dart';

part 'app_router.g.dart';

// SHELL ROUTES -----------------------------------------------------------------

@TypedStatefulShellRoute<AppShellRoute>(
  branches: [
    TypedStatefulShellBranch<DashboardBranch>(
      routes: [TypedGoRoute<DashboardRoute>(path: '/dashboard')],
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
    TypedStatefulShellBranch<ReportsBranch>(
      routes: [TypedGoRoute<ReportsRoute>(path: '/reports')],
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
    return const DashboardPage();
  }
}

class TransactionsRoute extends GoRouteData with $TransactionsRoute {
  const TransactionsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TransactionsPage();
  }
}

class TransactionNewRoute extends GoRouteData with $TransactionNewRoute {
  const TransactionNewRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const TransactionNewPage();
  }
}

class TransactionDetailRoute extends GoRouteData with $TransactionDetailRoute {
  const TransactionDetailRoute(this.id);

  final String id;

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return TransactionDetailPage(id: id);
  }
}

class ReportsRoute extends GoRouteData with $ReportsRoute {
  const ReportsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const ReportsPage();
  }
}

class SettingsRoute extends GoRouteData with $SettingsRoute {
  const SettingsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SettingsPage();
  }
}

// STANDALONE ROUTES (no bottom nav) -----------------------------------------------

@TypedGoRoute<AccountsRoute>(path: '/accounts')
class AccountsRoute extends GoRouteData with $AccountsRoute {
  const AccountsRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const AccountsPage();
  }
}
