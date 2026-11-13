import 'package:flutter/material.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/core/widgets/hide_amounts_button.dart';
import 'package:waldo/core/widgets/ghost.dart';
import 'package:waldo/core/widgets/load_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/heading.dart';
import 'package:waldo/core/widgets/sheet_page.dart';
import 'package:waldo/core/widgets/whole_words_text.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/transactions/ui/widgets/transaction_form_sheet.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_form_sheet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../models/dashboard_data.dart';
import '../viewmodels/dashboard_view_model.dart';
import 'package:waldo/core/widgets/cash_flow_card.dart';
import 'widgets/home_top.dart';
import 'widgets/recent_transactions_list.dart';
import 'widgets/wallet_stack.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final dashboardAsync = ref.watch(dashboardViewModelProvider);

    return Scaffold(
      backgroundColor: context.appColors.sheet,
      // No SafeArea: the beige top runs up under the status bar and the
      // sheet on under the floating navbar (AppShell's `extendBody`); the
      // list pads for both itself.
      body: switch (dashboardAsync) {
        AsyncValue(:final value?) => _DashboardBody(data: value),
        AsyncValue(hasError: true) => LoadError(
          message: l10n.dashboardError,
          onRetry: () => ref.invalidate(dashboardViewModelProvider),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _DashboardBody extends ConsumerWidget {
  const _DashboardBody({required this.data});

  final DashboardData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final isBalanceHidden = ref.watch(balanceHiddenProvider);
    final wallets = switch (ref.watch(walletListViewModelProvider())) {
      AsyncValue(:final value?) => value,
      _ => const <Wallet>[],
    };
    final locale = Localizations.localeOf(context).toString();
    final now = ref.watch(clockProvider)();
    final isThisMonth =
        data.month.year == now.year && data.month.month == now.month;
    final hasMonthFigures = data.monthlyIncome != 0 || data.monthlyExpense != 0;
    const sectionGap = SizedBox(height: Spacing.lg);
    const margin = EdgeInsets.symmetric(horizontal: Spacing.pageMargin);

    void toggleHidden() => ref.read(balanceHiddenProvider.notifier).toggle();

    return SheetPage(
      // As on Wallets: the total and the eye stay in reach once the top
      // scrolls away.
      // Always, so nothing slides under the clock; the eye only once there
      // is something to hide.
      bar: SheetPageBar(
        title: l10n.totalBalance,
        amount: BalanceAmount(
          amount: formatSignedCents(
            data.totalBalance,
            locale: moneyLocale(context),
            currencyCode: currency.code,
          ),
          hidden: isBalanceHidden,
          style: context.label.copyWith(color: colors.inkMuted),
          alignment: AlignmentDirectional.center,
        ),
        trailing: wallets.isEmpty
            ? null
            : HideAmountsButton(
                hidden: isBalanceHidden,
                onPressed: toggleHidden,
              ),
      ),
      top: HomeTop(
        totalBalance: data.totalBalance,
        monthChange: hasMonthFigures
            ? data.monthlyIncome - data.monthlyExpense
            : null,
        monthLabel: isThisMonth
            ? null
            : DateFormat.MMMM(locale).format(data.month),
        currency: currency,
        isBalanceHidden: isBalanceHidden,
        onToggleBalanceHidden: toggleHidden,
        onNewWallet: () => showWalletFormSheet(context),
        onNewTransaction: () => showTransactionFormSheet(context),
        hasWallets: wallets.isNotEmpty,
      ),
      sheet: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: margin,
            child: _SectionHeader(
              title: l10n.yourWallets,
              trailing: CircleIconButton(
                flat: true,
                tint: colors.card,
                tooltip: l10n.wallets,
                onPressed: () => const WalletsRoute().go(context),
                child: const Icon(AppIcons.chevronRight, size: IconSize.lg),
              ),
            ),
          ),
          const SizedBox(height: Spacing.component),
          Padding(
            padding: margin,
            child: wallets.isEmpty
                ? GhostEmptyState(
                    ghost: const GhostWalletStack(),
                    title: l10n.noWalletsYet,
                    body: l10n.addFirstWallet,
                    actionLabel: l10n.createFirstWallet,
                    onAction: () => showWalletFormSheet(context),
                  )
                : WalletStack(
                    wallets: wallets,
                    currency: currency,
                    isBalanceHidden: isBalanceHidden,
                    onOpen: (wallet) =>
                        TransactionsRoute(wallet.id!).push(context),
                  ),
          ),
          sectionGap,
          Padding(
            padding: margin,
            // Before the first wallet, a placeholder says when it comes.
            child: data.walletCount > 0
                ? CashFlowCard(
                    month: data.month,
                    monthlyCashFlow: data.monthlyCashFlow,
                    currency: currency,
                    isBalanceHidden: isBalanceHidden,
                  )
                : PlaceholderCard(
                    title: l10n.monthSummary,
                    body: l10n.monthSummaryLater,
                  ),
          ),
          sectionGap,
          if (data.recentTransactions.isNotEmpty)
            RecentTransactionsList(
              transactions: data.recentTransactions,
              currency: currency,
              isBalanceHidden: isBalanceHidden,
            )
          else
            Padding(
              padding: margin,
              child: PlaceholderCard(
                title: l10n.recentTransactions,
                body: wallets.isEmpty
                    ? l10n.recentTransactionsLater
                    : l10n.addFirstTransaction,
              ),
            ),
        ],
      ),
    );
  }
}

/// A section's title on the sheet, with an action on its right.
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.trailing});

  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Heading(
            child: WholeWordsText(title, style: context.titleSection),
          ),
        ),
        const SizedBox(width: Spacing.xs),
        trailing,
      ],
    );
  }
}
