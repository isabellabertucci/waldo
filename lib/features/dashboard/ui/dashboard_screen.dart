import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/features/dashboard/models/dashboard_data.dart';
import 'package:waldo/features/dashboard/ui/widgets/balance_overview_card.dart';
import 'package:waldo/features/dashboard/ui/widgets/cash_flow_card.dart';
import 'package:waldo/features/dashboard/ui/widgets/category_spending_list.dart';
import 'package:waldo/features/dashboard/ui/widgets/recent_transactions_list.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/l10n/app_localizations.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboardAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      body: SafeArea(
        child: switch (dashboardAsync) {
          AsyncError() => Center(child: Text(l10n.dashboardError)),
          AsyncData(:final value) => _DashboardBody(data: value),
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
      AsyncData(:final value) => value.currency,
      _ => Currency.usd,
    };
    final dateFormatPattern = switch (preferencesAsync) {
      AsyncData(:final value) => value.dateFormat,
      _ => 'yyyy-MM-dd',
    };

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: Spacing.lg),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: BalanceOverviewCard(
            totalBalance: data.totalBalance,
            monthlyIncome: data.monthlyIncome,
            monthlyExpense: data.monthlyExpense,
            currency: currency,
          ),
        ),
        const SizedBox(height: Spacing.xl),
        CategorySpendingList(
          spendingByCategory: data.spendingByCategory,
          currency: currency,
        ),
        const SizedBox(height: Spacing.xl),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.lg),
          child: CashFlowCard(
            monthlyCashFlow: data.monthlyCashFlow,
            currency: currency,
          ),
        ),
        const SizedBox(height: Spacing.xl),
        RecentTransactionsList(
          transactions: data.recentTransactions,
          currency: currency,
          dateFormat: DateFormat(dateFormatPattern),
        ),
      ],
    );
  }
}
