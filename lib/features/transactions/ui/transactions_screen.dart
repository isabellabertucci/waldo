import 'package:flutter/material.dart';
import 'package:waldo/core/theme/icon_size.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/core/widgets/circle_icon_button.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/core/widgets/wallet_card_finish.dart';
import 'package:waldo/features/categories/models/category.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/features/wallets/wallets_x.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../../core/widgets/empty_state.dart';
import 'package:waldo/core/widgets/eye_icon.dart';
import 'package:waldo/core/widgets/heading.dart';
import '../models/transaction.dart';
import '../models/transaction_filter.dart';
import '../viewmodels/transaction_list_view_model.dart';
import 'widgets/day_grouped_transaction_list.dart';
import 'widgets/transaction_form_sheet.dart';
import 'widgets/transaction_filter_sheet.dart';
import '../transactions_x.dart';

/// Room under the list so the last row scrolls clear of the floating nav.
const _navBarClearance = 72.0; // one-off: the nav pill's height plus its gap

/// The wallet's finish beside its name: a small card, not a round badge.
const _thumbnailSize = Size(52, 40); // one-off

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

    final Widget body;
    if (walletsAsync.hasError || transactionsAsync.hasError) {
      body = Center(child: Text(l10n.walletsError));
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
      body = Center(child: Text(l10n.walletsError));
    } else {
      body = const Center(child: CircularProgressIndicator());
    }

    return Scaffold(body: SafeArea(child: body));
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
  // Null while the transactions list is still loading - the header above
  // (name, balance, Hero thumbnail) doesn't wait on it, only this list does.
  final List<Transaction>? transactions;

  @override
  ConsumerState<_TransactionsBody> createState() => _TransactionsBodyState();
}

class _TransactionsBodyState extends ConsumerState<_TransactionsBody> {
  late TransactionFilter _filter;

  // The Hero is only kept for the push; once it lands it's dropped, so popping
  // back is a plain transition.
  bool _showHero = true;
  Animation<double>? _routeAnimation;

  @override
  void initState() {
    super.initState();
    final now = ref.read(clockProvider)();
    _filter = TransactionFilter(month: DateTime(now.year, now.month));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animation = ModalRoute.of(context)?.animation;
    if (animation != _routeAnimation) {
      _routeAnimation?.removeStatusListener(_handleRouteAnimationStatus);
      _routeAnimation = animation;
      _routeAnimation?.addStatusListener(_handleRouteAnimationStatus);
    }
  }

  void _handleRouteAnimationStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && mounted) {
      setState(() => _showHero = false);
    }
  }

  @override
  void dispose() {
    _routeAnimation?.removeStatusListener(_handleRouteAnimationStatus);
    super.dispose();
  }

  List<Transaction> _applyFilter(TransactionFilter filter) {
    final transactions = widget.transactions;
    if (transactions == null) return const [];
    return transactions.where(filter.matches).toList();
  }

  Future<void> _openFilterSheet(String locale) async {
    final result = await showModalBottomSheet<TransactionFilter>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (_) => TransactionFilterSheet(
        initial: _filter,
        locale: locale,
        now: ref.read(clockProvider)(),
        countForFilter: (f) => _applyFilter(f).length,
      ),
    );
    if (result != null && mounted) setState(() => _filter = result);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = context.appColors;
    final locale = Localizations.localeOf(context).toString();
    final now = ref.watch(clockProvider)();
    final filterMonthLabel = _filter.month.year == now.year
        ? DateFormat.MMMM(locale).format(_filter.month)
        : DateFormat.yMMMM(locale).format(_filter.month);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);
    final currency = switch (preferencesAsync) {
      AsyncValue(:final value?) => value.currency,
      _ => Currency.usd,
    };
    final categoriesAsync = ref.watch(categoryListViewModelProvider);
    final categoriesById = switch (categoriesAsync) {
      AsyncValue(:final value?) => {
        for (final c in value)
          if (c.id != null) c.id!: c,
      },
      _ => const <int, Category>{},
    };
    final isBalanceHidden = ref.watch(balanceHiddenProvider);
    final filtered = _applyFilter(_filter);
    // Same order the Wallets stack lists them in, so the same wallet always
    // gets the same finish here as it does on its own card there.
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final walletIndex = switch (walletsAsync) {
      AsyncValue(:final value?) => value.indexWhere(
        (w) => w.id == widget.walletId,
      ),
      _ => -1,
    };
    final finish = WalletCardFinish.fromIndex(
      walletIndex < 0 ? 0 : walletIndex,
    );

    final typeLabel = _filter.type?.label(l10n) ?? l10n.filterTypeAll;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            Spacing.pageMargin,
            Spacing.xs,
            Spacing.pageMargin,
            0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleIconButton(
                tooltip: l10n.back,
                onPressed: () => Navigator.of(context).pop(),
                child: const Icon(AppIcons.back),
              ),
              Row(
                children: [
                  DashedStitchButton(
                    icon: const Icon(AppIcons.add),
                    tooltip: l10n.newTransaction,
                    onPressed: () => showTransactionFormSheet(
                      context,
                      initialWalletId: widget.walletId,
                    ),
                  ),
                  const SizedBox(width: Spacing.xs),
                  CircleIconButton(
                    tooltip: isBalanceHidden
                        ? l10n.showBalance
                        : l10n.hideBalance,
                    onPressed: () =>
                        ref.read(balanceHiddenProvider.notifier).toggle(),
                    child: EyeIcon(
                      color: colors.onSurface,
                      hidden: isBalanceHidden,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(Rounded.sm),
                child: SizedBox(
                  width: _thumbnailSize.width,
                  height: _thumbnailSize.height,
                  // The wallet's own finish, with a Hero from its card (see `_showHero`).
                  child: _showHero
                      ? Hero(
                          tag: 'walletCardBg_${widget.walletId}',
                          child: WalletCardBackground(finish: finish),
                        )
                      : WalletCardBackground(finish: finish),
                ),
              ),
              const SizedBox(width: Spacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Heading(
                      child: Text(
                        widget.wallet.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.headlineLgStrong,
                      ),
                    ),
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '${widget.wallet.type.label(l10n)} · ',
                          ),
                          TextSpan(
                            text: isBalanceHidden
                                ? hiddenAmount
                                : formatCents(
                                    widget.wallet.currentBalance,
                                    locale: moneyLocale(context),
                                    currencyCode: currency.code,
                                  ),
                            // one-off: bolds only the balance in the inherited line style.
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color:
                                  !isBalanceHidden &&
                                      widget.wallet.currentBalance < 0
                                  ? colors.error
                                  : colors.onSurface,
                            ),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: context.textTheme.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: Spacing.md),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
          child: Material(
            color: colors.surface,
            borderRadius: BorderRadius.circular(Rounded.pill),
            // Named by what it shows (WCAG 2.5.3, for voice control), without
            // the "·"; the hint says what a tap does.
            child: Semantics(
              button: true,
              label: '$filterMonthLabel, ${l10n.filterChipLabel(typeLabel)}',
              hint: l10n.filterHint,
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(Rounded.pill),
                onTap: () => _openFilterSheet(locale),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: Spacing.sm,
                    vertical: Spacing.sm,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        AppIcons.filter,
                        size: IconSize.lg,
                        color: colors.onSurfaceVariant,
                      ),
                      const SizedBox(width: Spacing.xs),
                      Text(filterMonthLabel, style: context.bodyMdBold),
                      const SizedBox(width: Spacing.xxs),
                      Expanded(
                        child: Text(
                          '· ${l10n.filterChipLabel(typeLabel)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textTheme.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                        ),
                      ),
                      Icon(
                        AppIcons.chevronDown,
                        color: colors.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: widget.transactions == null
              ? const Center(child: CircularProgressIndicator())
              : widget.transactions!.isEmpty
              ? EmptyState(
                  icon: AppIcons.receipt,
                  title: l10n.noTransactionsYet,
                  subtitle: l10n.addFirstTransaction,
                )
              : filtered.isEmpty
              ? EmptyState(
                  icon: AppIcons.receipt,
                  title: l10n.noTransactionsForFilter,
                )
              : DayGroupedTransactionList(
                  transactions: filtered,
                  categoriesById: categoriesById,
                  currency: currency,
                  now: now,
                  isAmountHidden: isBalanceHidden,
                  padding: const EdgeInsets.fromLTRB(
                    Spacing.pageMargin,
                    Spacing.md,
                    Spacing.pageMargin,
                    Spacing.lg + _navBarClearance,
                  ),
                ),
        ),
      ],
    );
  }
}
