import 'package:flutter/material.dart';
import 'package:waldo/core/widgets/rows_card.dart';
import 'package:waldo/core/widgets/sheet_page.dart';
import 'package:waldo/core/widgets/load_error.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/core/router/app_router.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/utils/utils.dart';
import 'package:waldo/features/categories/viewmodels/category_list_view_model.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/models/preferences.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/core/widgets/option_sheet.dart';
import 'package:waldo/features/settings/ui/widgets/settings_row.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';
import 'package:waldo/core/widgets/heading.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);

    // A tab like Home and Wallets: the beige top with the page's title,
    // then the white sheet (DESIGN.md "Settings").
    return Scaffold(
      body: SheetPage(
        // Once the title scrolls away, so nothing slides under the clock.
        bar: SheetPageBar(title: l10n.settings),
        top: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Heading(child: Text(l10n.settings, style: context.titlePage)),
        ),
        sheet: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.pageMargin),
          child: switch (preferencesAsync) {
            AsyncValue(:final value?) => _SettingsBody(preferences: value),
            AsyncValue(hasError: true) => LoadError(
              message: l10n.preferencesError,
              onRetry: () => ref.invalidate(preferencesViewModelProvider),
            ),
            _ => const Padding(
              padding: EdgeInsets.all(Spacing.lg),
              child: Center(child: CircularProgressIndicator()),
            ),
          },
        ),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  const _SettingsBody({required this.preferences});

  final Preferences preferences;

  String _themeLabel(AppLocalizations l10n, bool? isDarkMode) {
    return switch (isDarkMode) {
      null => l10n.themeSystem,
      true => l10n.themeDark,
      false => l10n.themeLight,
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final viewModel = ref.read(preferencesViewModelProvider.notifier);
    final walletsAsync = ref.watch(walletListViewModelProvider());
    final isBalanceHidden = ref.watch(balanceHiddenProvider);
    final categoryCount = switch (ref.watch(categoryListViewModelProvider)) {
      AsyncValue(:final value?) => '${value.length}',
      _ => '',
    };
    final totalBalance = switch (walletsAsync) {
      AsyncValue(:final value?) => value.fold<int>(
        0,
        (sum, w) => sum + w.currentBalance,
      ),
      _ => 0,
    };

    final currencyRow = SettingsRow(
      icon: AppIcons.currency,
      title: l10n.currency,
      value: preferences.currency.code,
      onTap: () => _showCurrencySheet(
        context,
        l10n,
        viewModel,
        preferences,
        totalBalance,
        isBalanceHidden,
      ),
    );
    final dateRow = SettingsRow(
      icon: AppIcons.calendar,
      title: l10n.dateFormat,
      value: DateFormat(
        preferences.dateFormat,
      ).format(ref.watch(clockProvider)()),
      onTap: () => _showDateFormatSheet(
        context,
        l10n,
        viewModel,
        preferences,
        ref.read(clockProvider)(),
      ),
    );
    final themeRow = SettingsRow(
      icon: AppIcons.theme,
      title: l10n.theme,
      value: _themeLabel(l10n, preferences.isDarkMode),
      onTap: () => _showThemeSheet(context, l10n, viewModel, preferences),
    );
    // Categories also live here, not only behind the transaction form.
    final categoriesRow = SettingsRow(
      icon: AppIcons.categoryGeneric,
      title: l10n.categories,
      value: categoryCount,
      onTap: () => const CategoriesRoute().push(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        RowsCard(
          title: l10n.settingsPreferences,
          children: [currencyRow, dateRow, themeRow],
        ),
        const SizedBox(height: Spacing.md),
        RowsCard(title: l10n.settingsOrganize, children: [categoriesRow]),
      ],
    );
  }

  Future<void> _savePreference(
    BuildContext context,
    AppLocalizations l10n,
    Future<void> Function() save,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await save();
    } catch (e) {
      final message = failureMessage(
        l10n,
        e,
        unknown: l10n.preferencesSaveError,
      );
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _showThemeSheet(
    BuildContext context,
    AppLocalizations l10n,
    PreferencesViewModel viewModel,
    Preferences preferences,
  ) {
    showOptionSheet<bool?>(
      context,
      title: l10n.theme,
      initialValue: preferences.isDarkMode,
      options: [
        SheetOption(
          label: l10n.themeSystem,
          value: null,
          icon: AppIcons.themeSystem,
        ),
        SheetOption(
          label: l10n.themeLight,
          value: false,
          icon: AppIcons.themeLight,
        ),
        SheetOption(
          label: l10n.themeDark,
          value: true,
          icon: AppIcons.themeDark,
        ),
      ],
      onConfirm: (value) =>
          _savePreference(context, l10n, () => viewModel.setDarkMode(value)),
    );
  }

  void _showCurrencySheet(
    BuildContext context,
    AppLocalizations l10n,
    PreferencesViewModel viewModel,
    Preferences preferences,
    int totalBalance,
    bool isBalanceHidden,
  ) {
    showOptionSheet<Currency>(
      context,
      title: l10n.currency,
      initialValue: preferences.currency,
      notice: l10n.currencyChangeNotice,
      options: Currency.values
          .map(
            (currency) => SheetOption(
              label: currency.fullName(l10n),
              // The same balance in each currency - showing nothing gets converted.
              subtitle:
                  '${currency.code} · '
                  '${isBalanceHidden ? hiddenAmount : formatCents(totalBalance, locale: moneyLocale(context), currencyCode: currency.code)}',
              value: currency,
              symbolText: currency.symbol,
            ),
          )
          .toList(),
      onConfirm: (value) =>
          _savePreference(context, l10n, () => viewModel.setCurrency(value)),
    );
  }

  void _showDateFormatSheet(
    BuildContext context,
    AppLocalizations l10n,
    PreferencesViewModel viewModel,
    Preferences preferences,
    DateTime now,
  ) {
    showOptionSheet<String>(
      context,
      title: l10n.dateFormat,
      initialValue: preferences.dateFormat,
      options: [
        SheetOption(
          label: DateFormat('dd/MM/yyyy').format(now),
          value: 'dd/MM/yyyy',
          icon: AppIcons.calendar,
        ),
        SheetOption(
          label: DateFormat('MM/dd/yyyy').format(now),
          value: 'MM/dd/yyyy',
          icon: AppIcons.calendar,
        ),
        SheetOption(
          label: DateFormat('yyyy-MM-dd').format(now),
          value: 'yyyy-MM-dd',
          icon: AppIcons.calendar,
        ),
      ],
      onConfirm: (value) =>
          _savePreference(context, l10n, () => viewModel.setDateFormat(value)),
    );
  }
}
