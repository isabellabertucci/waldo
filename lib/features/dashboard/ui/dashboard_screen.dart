import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/widgets/sheet_grabber.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_form_sheet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../models/dashboard_data.dart';
import '../viewmodels/dashboard_view_model.dart';
import 'widgets/balance_overview_card.dart';
import 'widgets/cash_flow_card.dart';
import 'widgets/dashboard_receipt.dart';
import 'package:waldo/core/widgets/month_selector.dart';
import 'widgets/recent_transactions_list.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboardAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (dashboardAsync) {
          AsyncValue(:final value?) => _DashboardBody(data: value),
          AsyncValue(hasError: true) => Center(
            child: Text(l10n.dashboardError),
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final selectedMonth = ref.watch(selectedDashboardMonthProvider);
    final isBalanceHidden = ref.watch(balanceHiddenProvider);
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final peekWalletName = switch (walletsAsync) {
      AsyncValue(:final value?) when value.isNotEmpty => value.first.name,
      _ => null,
    };
    final locale = Localizations.localeOf(context).toString();
    final now = ref.watch(clockProvider)();
    // 12 months, matching the cash flow chart's trailing window.
    final months = selectorMonths(now);
    final hasCashFlowData = data.monthlyCashFlow.any(
      (m) => m.income != 0 || m.expense != 0,
    );

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
      children: [
        // No month row until there's a wallet.
        if (data.walletCount > 0) ...[
          MonthSelector(
            months: months,
            selectedMonth: selectedMonth,
            currentMonth: DateTime(now.year, now.month),
            locale: locale,
            onSelect: (month) =>
                ref.read(selectedDashboardMonthProvider.notifier).select(month),
          ),
          const SizedBox(height: Spacing.lg),
        ],
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
          child: BalanceOverviewCard(
            totalBalance: data.totalBalance,
            currency: currency,
            isBalanceHidden: isBalanceHidden,
            cardMonthLabel: DateFormat(
              'MMM yyyy',
              locale,
            ).format(selectedMonth),
            peekWalletName: peekWalletName,
            walletCount: data.walletCount,
            onCreateWallet: () => showWalletFormSheet(context),
            onAddPressed: () => _showQuickAddSheet(context),
            onToggleBalanceHidden: () =>
                ref.read(balanceHiddenProvider.notifier).toggle(),
          ),
        ),
        DashboardReceipt(
          monthLabel: DateFormat.MMMM(locale).format(selectedMonth),
          year: selectedMonth.year,
          monthlyIncome: data.monthlyIncome,
          monthlyExpense: data.monthlyExpense,
          spendingByCategory: data.spendingByCategory,
          uncategorizedSpending: data.uncategorizedSpending,
          isBalanceHidden: isBalanceHidden,
          currency: currency,
          hasWallets: data.walletCount > 0,
          onTap: () => const AllTransactionsRoute().push(context),
          onAddTransaction: () => showTransactionFormSheet(context),
        ),
        if (hasCashFlowData) ...[
          const SizedBox(height: Spacing.xl),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
            child: CashFlowCard(
              monthlyCashFlow: data.monthlyCashFlow,
              currency: currency,
              isBalanceHidden: isBalanceHidden,
            ),
          ),
        ],
        // Hidden until the first transaction; the receipt already says so.
        if (data.recentTransactions.isNotEmpty) ...[
          const SizedBox(height: Spacing.xl),
          RecentTransactionsList(
            transactions: data.recentTransactions,
            currency: currency,
            isBalanceHidden: isBalanceHidden,
          ),
        ],
      ],
    );
  }
}

void _showQuickAddSheet(BuildContext context) {
  final l10n = AppLocalizations.of(context);

  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        // Same side margin as every other sheet.
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.md,
          vertical: Spacing.sm,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Like every other sheet: says it can be dragged away.
            const SheetGrabber(),
            const SizedBox(height: Spacing.sm),
            ListTile(
              leading: const Icon(AppIcons.receipt),
              title: Text(l10n.newTransaction),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showTransactionFormSheet(context);
              },
            ),
            ListTile(
              leading: const Icon(AppIcons.wallets),
              title: Text(l10n.newWallet),
              onTap: () {
                Navigator.of(sheetContext).pop();
                showWalletFormSheet(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
