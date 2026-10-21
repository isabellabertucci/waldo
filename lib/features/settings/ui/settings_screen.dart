import 'package:flutter/material.dart';
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
import 'package:waldo/features/settings/ui/widgets/settings_option_sheet.dart';
import 'package:waldo/features/settings/ui/widgets/settings_row.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);

    // Same header as Wallets, so the title shares the page gutter.
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                Spacing.pageMargin,
                Spacing.xs,
                Spacing.pageMargin,
                0,
              ),
              child: Text(l10n.settings, style: context.headlineSmBold),
            ),
            Expanded(
              child: switch (preferencesAsync) {
                AsyncValue(:final value?) => _SettingsBody(preferences: value),
                AsyncValue(hasError: true) => Center(
                  child: Text(l10n.preferencesError),
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
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

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.pageMargin,
        vertical: Spacing.md,
      ),
      children: [
        SectionLabel(title: l10n.moneySection),
        SettingsCard(
          children: [
            SettingsRow(
              icon: AppIcons.currency,
              title: l10n.currency,
              subtitle: l10n.currencyRowSubtitle,
              value: preferences.currency.code,
              onTap: () => _showCurrencySheet(
                context,
                l10n,
                viewModel,
                preferences,
                totalBalance,
                isBalanceHidden,
              ),
            ),
            SettingsRow(
              icon: AppIcons.calendar,
              title: l10n.dateFormat,
              subtitle: l10n.dateFormatRowSubtitle,
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
            ),
            // Categories also live here, not only behind the transaction form.
            SettingsRow(
              icon: AppIcons.categoryGeneric,
              title: l10n.categories,
              value: categoryCount,
              onTap: () => const CategoriesRoute().push(context),
            ),
          ],
        ),

        const SizedBox(height: Spacing.lg),

        SectionLabel(title: l10n.appearanceSection),
        SettingsCard(
          children: [
            SettingsRow(
              icon: AppIcons.theme,
              title: l10n.theme,
              value: _themeLabel(l10n, preferences.isDarkMode),
              onTap: () =>
                  _showThemeSheet(context, l10n, viewModel, preferences),
            ),
          ],
        ),
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
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.appColors.transparent,
      isScrollControlled: true,
      builder: (context) => SettingsOptionSheet<bool?>(
        title: l10n.theme,
        initialValue: preferences.isDarkMode,
        options: [
          SettingsOption(
            label: l10n.themeSystem,
            value: null,
            icon: AppIcons.themeSystem,
          ),
          SettingsOption(
            label: l10n.themeLight,
            value: false,
            icon: AppIcons.themeLight,
          ),
          SettingsOption(
            label: l10n.themeDark,
            value: true,
            icon: AppIcons.themeDark,
          ),
        ],
        onConfirm: (value) =>
            _savePreference(context, l10n, () => viewModel.setDarkMode(value)),
      ),
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
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.appColors.transparent,
      isScrollControlled: true,
      builder: (context) => SettingsOptionSheet<Currency>(
        title: l10n.currency,
        initialValue: preferences.currency,
        notice: l10n.currencyChangeNotice,
        options: Currency.values
            .map(
              (currency) => SettingsOption(
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
      ),
    );
  }

  void _showDateFormatSheet(
    BuildContext context,
    AppLocalizations l10n,
    PreferencesViewModel viewModel,
    Preferences preferences,
    DateTime now,
  ) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      backgroundColor: context.appColors.transparent,
      isScrollControlled: true,
      builder: (context) => SettingsOptionSheet<String>(
        title: l10n.dateFormat,
        initialValue: preferences.dateFormat,
        options: [
          SettingsOption(
            label: DateFormat('dd/MM/yyyy').format(now),
            value: 'dd/MM/yyyy',
            icon: AppIcons.calendar,
          ),
          SettingsOption(
            label: DateFormat('MM/dd/yyyy').format(now),
            value: 'MM/dd/yyyy',
            icon: AppIcons.calendar,
          ),
          SettingsOption(
            label: DateFormat('yyyy-MM-dd').format(now),
            value: 'yyyy-MM-dd',
            icon: AppIcons.calendar,
          ),
        ],
        onConfirm: (value) => _savePreference(
          context,
          l10n,
          () => viewModel.setDateFormat(value),
        ),
      ),
    );
  }
}
