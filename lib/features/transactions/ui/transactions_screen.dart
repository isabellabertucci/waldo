import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/ghost.dart';
import 'package:waldo/core/widgets/hide_amounts_button.dart';
import 'package:waldo/core/widgets/balance_amount.dart';
import 'package:waldo/core/widgets/load_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/action_circle.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/edit_delete_menu.dart';
import 'package:waldo/core/widgets/empty_state.dart';
import 'package:waldo/core/widgets/eye_icon.dart';
import 'package:waldo/core/widgets/filter_tiles.dart';
import 'package:waldo/core/widgets/leather_wallet.dart';
import 'package:waldo/core/widgets/month_selector.dart';
import 'package:waldo/core/widgets/month_stepper.dart';
import 'package:waldo/core/widgets/segmented.dart';
import 'package:waldo/core/widgets/sheet_page.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/core/widgets/cash_flow_card.dart';
import 'widgets/category_spending_card.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/ui/widgets/delete_wallet.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_face.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_form_sheet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../transactions_x.dart';
import '../viewmodels/transaction_list_view_model.dart';
import 'widgets/day_grouped_transaction_list.dart';
import 'widgets/transaction_form_sheet.dart';

class TransactionsScreen extends ConsumerWidget {
  const TransactionsScreen({super.key, required this.walletId});

  final int walletId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // Uses the already-loaded wallets list (not a per-id fetch), so the header
    // exists on the first frame and the Hero flight runs.
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final transactionsAsync = ref.watch(
      transactionListViewModelProvider(walletId: walletId),
    );
    final wallet = switch (walletsAsync) {
      AsyncValue(:final value?) =>
        value.where((w) => w.id == walletId).firstOrNull,
      _ => null,
    };

    void retry() {
      ref.invalidate(walletListViewModelProvider);
      ref.invalidate(transactionListViewModelProvider(walletId: walletId));
    }

    final Widget body;
    if (walletsAsync.hasError) {
      body = LoadError(message: l10n.walletsError, onRetry: retry);
    } else if (transactionsAsync.hasError) {
      body = LoadError(message: l10n.transactionsError, onRetry: retry);
    } else if (wallet != null) {
      body = _TransactionsBody(
        wallet: wallet,
        walletId: walletId,
        transactions: switch (transactionsAsync) {
          AsyncValue(:final value?) => value,
          _ => null,
        },
      );
    } else if (walletsAsync.hasValue) {
      body = LoadError(message: l10n.walletsError, onRetry: retry);
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    // No SafeArea: SheetPage pads for the status bar and navbar itself.
    return Scaffold(backgroundColor: context.appColors.sheet, body: body);
  }
}

class _TransactionsBody extends ConsumerStatefulWidget {
  const _TransactionsBody({
    required this.wallet,
    required this.walletId,
    required this.transactions,
  });

  final Wallet wallet;
  final int walletId;
  // Null while the transactions list is still loading - the wallet above
  // doesn't wait on it, only the sheet does.
  final List<Transaction>? transactions;

  @override
  ConsumerState<_TransactionsBody> createState() => _TransactionsBodyState();
}

/// The wallet's sheet: its transactions, or what they add up to.
enum _WalletTab { transactions, analysis }

class _TransactionsBodyState extends ConsumerState<_TransactionsBody> {
  late TransactionFilter _filter;
  var _tab = _WalletTab.transactions;
  var _isFilterOpen = false;

  void _toggleFilter() => setState(() => _isFilterOpen = !_isFilterOpen);

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    _filter = TransactionFilter(month: DateTime(now.year, now.month));
  }

  List<Transaction> _applyFilter(TransactionFilter filter) {
    final transactions = widget.transactions;
    if (transactions == null) return const [];
    return transactions.where(filter.matches).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final now = ref.watch(clockProvider)();
    final currency = switch (ref.watch(preferencesViewModelProvider)) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final categoriesById = ref.watch(categoriesByIdProvider);
    final isBalanceHidden = ref.watch(balanceHiddenProvider);
    final wallet = widget.wallet;
    final wallets = switch (ref.watch(walletListViewModelProvider())) {
      AsyncValue(:final value?) => value,
      _ => [wallet],
    };
    final finish = wallet.finish;
    final positiveTotal = wallets
        .where((w) => w.currentBalance > 0)
        .fold(0, (sum, w) => sum + w.currentBalance);
    final transactions = widget.transactions;
    const gap = SizedBox(height: Spacing.sm);
    final thisMonth = TransactionFilter(month: DateTime(now.year, now.month));

    final Widget tab;
    if (transactions == null) {
      tab = const Padding(
        padding: EdgeInsets.all(Spacing.lg),
        child: Center(child: CircularProgressIndicator()),
      );
    } else if (transactions.isEmpty && _tab == _WalletTab.analysis) {
      // The analysis's own cards, held until there is something to chart
      // (as Home's month summary).
      tab = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlaceholderCard(title: l10n.cashFlow, body: l10n.monthSummaryLater),
          gap,
          PlaceholderCard(
            title: l10n.categorySpending,
            body: l10n.monthSummaryLater,
          ),
        ],
      );
    } else if (transactions.isEmpty) {
      tab = GhostEmptyState(
        ghost: GhostRows(leading: GhostRows.disc(context)),
        title: l10n.noTransactionsYet,
        body: l10n.addFirstTransaction,
      );
    } else if (_tab == _WalletTab.analysis) {
      final inMonth = [
        for (final t in transactions)
          if (TransactionFilter(month: _filter.month).matches(t)) t,
      ];
      final spending = spendingByCategoryOf(
        inMonth,
        categoriesById.values.toList(),
      );
      final expense = inMonth
          .where((t) => t.type == TransactionType.expense)
          .fold(0, (sum, t) => sum + t.amount);
      tab = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CashFlowCard(
            month: _filter.month,
            monthlyCashFlow: monthlyCashFlowOf(transactions, _filter.month),
            currency: currency,
            isBalanceHidden: isBalanceHidden,
          ),
          gap,
          CategorySpendingCard(
            spendingByCategory: spending,
            uncategorizedSpending:
                expense - spending.fold(0, (sum, s) => sum + s.amount),
            currency: currency,
            isBalanceHidden: isBalanceHidden,
          ),
        ],
      );
    } else {
      final filtered = _applyFilter(_filter);
      tab = filtered.isEmpty
          ? EmptyState(
              icon: AppIcons.receipt,
              title: l10n.noTransactionsForFilter,
            )
          : DayGroupedTransactionList(
              inPage: true,
              transactions: filtered,
              categoriesById: categoriesById,
              currency: currency,
              now: now,
              isAmountHidden: isBalanceHidden,
              padding: EdgeInsets.zero,
            );
    }

    void toggleHidden() => ref.read(balanceHiddenProvider.notifier).toggle();

    return SheetPage(
      // Pinned once the wallet scrolls away: back, the wallet and its
      // balance, and the eye, in reach anywhere in a long list.
      bar: SheetPageBar(
        title: wallet.name,
        amount: BalanceAmount(
          amount: formatSignedCents(
            wallet.currentBalance,
            locale: moneyLocale(context),
            currencyCode: currency.code,
          ),
          hidden: isBalanceHidden,
          style: context.label.copyWith(color: colors.inkMuted),
          alignment: AlignmentDirectional.center,
        ),
        leading: CircleIconButton(
          flat: true,
          tint: colors.chip,
          tooltip: l10n.back,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(AppIcons.back, size: IconSize.lg),
        ),
        trailing: HideAmountsButton(
          hidden: isBalanceHidden,
          onPressed: toggleHidden,
        ),
      ),
      top: Column(
        children: [
          _TopBar(
            title: l10n.wallet,
            optionsTooltip: l10n.optionsFor(wallet.name),
            onEdit: () => showWalletFormSheet(context, wallet: wallet),
            onDelete: () => deleteWalletWithUndo(
              context,
              wallet,
              onConfirmed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(height: Spacing.md),
          // Wallet-shaped and centred, not stretched to the page's width.
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: ComponentSize.walletAloneWidth,
            ),
            child: LeatherWallet(
              finish: finish,
              child: WalletFace(
                wallet: wallet,
                finish: finish,
                currency: currency,
                isBalanceHidden: isBalanceHidden,
                isTitle: true,
              ),
            ),
          ),
          const SizedBox(height: Spacing.component),
          Text(
            _standing(l10n, wallet.currentBalance, positiveTotal, currency),
            textAlign: TextAlign.center,
            style: context.label.copyWith(color: colors.inkMuted),
          ),
          const SizedBox(height: Spacing.md),
          // The main action last, on the right (DESIGN.md "Action circles").
          Wrap(
            alignment: WrapAlignment.center,
            spacing: Spacing.component * 2 + Spacing.xxs,
            runSpacing: Spacing.sm,
            children: [
              ActionCircle(
                icon: EyeIcon(
                  color: isBalanceHidden ? colors.onAccent : colors.ink,
                  hidden: isBalanceHidden,
                  size: IconSize.xl,
                ),
                label: l10n.actionHide,
                // On while amounts are hidden, like the Filter action.
                selected: isBalanceHidden,
                onPressed: toggleHidden,
              ),
              // As on the wallets list; Edit is in the ⋯ menu.
              ActionCircle(
                key: const Key('walletFilterAction'),
                icon: const Icon(AppIcons.filter, size: IconSize.xl),
                label: l10n.actionFilter,
                // Nothing to filter yet, as on the wallets list.
                onPressed: transactions?.isEmpty ?? true ? null : _toggleFilter,
                selected: _isFilterOpen,
                // On while it shows anything but this month's everything.
                marked: _filter != thisMonth,
                value: _filter == thisMonth
                    ? null
                    : _filterLabel(l10n, _filter, now),
              ),
              ActionCircle(
                key: const Key('newTransactionAction'),
                icon: const Icon(AppIcons.add, size: IconSize.xl),
                label: l10n.actionTransaction,
                onPressed: () => showTransactionFormSheet(
                  context,
                  initialWalletId: widget.walletId,
                ),
                isMain: true,
              ),
            ],
          ),
        ],
      ),
      sheet: Padding(
        padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Segmented(
              options: [
                (_WalletTab.transactions, l10n.transactions),
                (_WalletTab.analysis, l10n.walletAnalysis),
              ],
              selected: _tab,
              onChanged: (tab) => setState(() => _tab = tab),
            ),
            // The filter, behind Filter as on the wallets list: the month
            // both tabs show (a year back, up to this month), then the
            // transactions' type.
            AnimatedSize(
              duration: context.motion(Motion.segmentSwap),
              curve: Motion.segmentSwapCurve,
              alignment: Alignment.topCenter,
              child: !_isFilterOpen
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        gap,
                        MonthStepper(
                          months: selectorMonths(now)..removeLast(),
                          month: _filter.month,
                          onChanged: (month) => setState(
                            () => _filter = _filter.copyWith(month: month),
                          ),
                        ),
                        if (_tab == _WalletTab.transactions &&
                            (transactions?.isNotEmpty ?? false)) ...[
                          gap,
                          _TypeFilter(
                            transactions: transactions!,
                            filter: _filter,
                            onChanged: (type) => setState(
                              () => _filter = _filter.copyWith(type: type),
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
            gap,
            AnimatedSize(
              duration: context.motion(Motion.segmentSwap),
              curve: Motion.segmentSwapCurve,
              alignment: Alignment.topCenter,
              child: KeyedSubtree(key: ValueKey(_tab), child: tab),
            ),
          ],
        ),
      ),
    );
  }

  /// What the filter shows, for screen readers: "September, Expense".
  String _filterLabel(
    AppLocalizations l10n,
    TransactionFilter filter,
    DateTime now,
  ) {
    final locale = Localizations.localeOf(context).toString();
    final month = filter.month.year == now.year
        ? DateFormat.MMMM(locale).format(filter.month)
        : DateFormat.yMMMM(locale).format(filter.month);
    return [month, ?filter.type?.label(l10n)].join(', ');
  }

  /// Its share of what's in the black, how far in the red, or empty.
  String _standing(
    AppLocalizations l10n,
    int balance,
    int positiveTotal,
    Currency currency,
  ) {
    if (balance < 0) {
      return l10n.walletInRedBy(
        ref.read(balanceHiddenProvider)
            ? hiddenAmount
            : formatSignedCents(
                balance,
                locale: moneyLocale(context),
                currencyCode: currency.code,
              ),
      );
    }
    return switch (positiveShareLabel(balance, positiveTotal)) {
      final share? => l10n.walletShareOfPositive(share),
      null => l10n.walletStatusEmpty,
    };
  }
}

/// Back, the page's name, and the wallet's ⋯ menu.
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.title,
    required this.optionsTooltip,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String optionsTooltip;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;

    return Row(
      children: [
        CircleIconButton(
          flat: true,
          tint: colors.chip,
          tooltip: l10n.back,
          onPressed: () => Navigator.of(context).pop(),
          child: const Icon(AppIcons.back, size: IconSize.lg),
        ),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: context.bodyStrong,
          ),
        ),
        EditDeleteMenuButton(
          tooltip: optionsTooltip,
          onSelected: (action) => switch (action) {
            EditDeleteAction.edit => onEdit(),
            EditDeleteAction.delete => onDelete(),
          },
          child: Container(
            padding: const EdgeInsets.all(Spacing.component),
            decoration: BoxDecoration(
              color: colors.chip,
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppIcons.moreHorizontal,
              size: IconSize.lg,
              color: colors.ink,
            ),
          ),
        ),
      ],
    );
  }
}

/// "All", "Expense" and "Income" as filter tiles, each with how many of
/// the month's transactions it leaves.
class _TypeFilter extends StatelessWidget {
  const _TypeFilter({
    required this.transactions,
    required this.filter,
    required this.onChanged,
  });

  final List<Transaction> transactions;
  final TransactionFilter filter;
  final ValueChanged<TransactionType?> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    String countOf(TransactionType? type) => l10n.transactionsCountLabel(
      transactions.where(filter.copyWith(type: type).matches).length,
    );

    return FilterTiles(
      tiles: [
        (
          icon: AppIcons.allTypes,
          label: l10n.filterTypeAll,
          caption: countOf(null),
          selected: filter.type == null,
          onTap: () => onChanged(null),
        ),
        for (final type in const [
          TransactionType.expense,
          TransactionType.income,
        ])
          (
            icon: type == TransactionType.expense
                ? AppIcons.expense
                : AppIcons.income,
            label: type.label(l10n),
            caption: countOf(type),
            selected: filter.type == type,
            onTap: () => onChanged(type),
          ),
      ],
    );
  }
}
