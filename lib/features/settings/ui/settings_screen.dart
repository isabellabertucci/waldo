import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/features/preferences/currency_x.dart';
import 'package:waldo/features/preferences/models/preferences.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
import 'package:waldo/features/settings/ui/widgets/option_sheet.dart';
import 'package:waldo/features/settings/ui/widgets/settings_row.dart';
import 'package:waldo/l10n/app_localizations.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final preferencesAsync = ref.watch(preferencesViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: switch (preferencesAsync) {
        AsyncError() => Center(child: Text(l10n.preferencesError)),
        AsyncData(:final value) => _SettingsBody(preferences: value),
        _ => const Center(child: CircularProgressIndicator()),
      },
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

    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: Spacing.lg,
        vertical: Spacing.md,
      ),
      children: [
        SectionLabel(title: l10n.darkMode),
        SettingsCard(
          children: [
            SettingsRow(
              icon: Icons.dark_mode_outlined,
              title: l10n.darkMode,
              value: _themeLabel(l10n, preferences.isDarkMode),
              onTap: () =>
                  _showThemeSheet(context, l10n, viewModel, preferences),
            ),
          ],
        ),

        const SizedBox(height: Spacing.lg),

        SectionLabel(title: l10n.currency),
        SettingsCard(
          children: [
            SettingsRow(
              icon: Icons.attach_money,
              title: l10n.currency,
              value: preferences.currency.code,
              onTap: () =>
                  _showCurrencySheet(context, l10n, viewModel, preferences),
            ),
          ],
        ),

        const SizedBox(height: Spacing.lg),

        SectionLabel(title: l10n.dateFormat),
        SettingsCard(
          children: [
            SettingsRow(
              icon: Icons.calendar_today_outlined,
              title: l10n.dateFormat,
              value: DateFormat(preferences.dateFormat).format(DateTime.now()),
              onTap: () =>
                  _showDateFormatSheet(context, l10n, viewModel, preferences),
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
    } catch (_) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.preferencesSaveError)),
      );
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
      builder: (context) => OptionSheet<bool?>(
        title: l10n.darkMode,
        groupValue: preferences.isDarkMode,
        options: [
          Option(label: l10n.themeSystem, value: null),
          Option(label: l10n.themeLight, value: false),
          Option(label: l10n.themeDark, value: true),
        ],
        onSelected: (value) =>
            _savePreference(context, l10n, () => viewModel.setDarkMode(value)),
      ),
    );
  }

  void _showCurrencySheet(
    BuildContext context,
    AppLocalizations l10n,
    PreferencesViewModel viewModel,
    Preferences preferences,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => OptionSheet<Currency>(
        title: l10n.currency,
        groupValue: preferences.currency,
        options: Currency.values
            .map(
              (currency) =>
                  Option(label: currency.label(l10n), value: currency),
            )
            .toList(),
        onSelected: (value) {
          if (value != null) {
            _savePreference(context, l10n, () => viewModel.setCurrency(value));
          }
        },
      ),
    );
  }

  void _showDateFormatSheet(
    BuildContext context,
    AppLocalizations l10n,
    PreferencesViewModel viewModel,
    Preferences preferences,
  ) {
    final now = DateTime.now();
    showModalBottomSheet(
      context: context,
      builder: (context) => OptionSheet<String>(
        title: l10n.dateFormat,
        groupValue: preferences.dateFormat,
        options: [
          Option(
            label: DateFormat('dd/MM/yyyy').format(now),
            value: 'dd/MM/yyyy',
          ),
          Option(
            label: DateFormat('MM/dd/yyyy').format(now),
            value: 'MM/dd/yyyy',
          ),
          Option(
            label: DateFormat('yyyy-MM-dd').format(now),
            value: 'yyyy-MM-dd',
          ),
        ],
        onSelected: (value) {
          if (value != null) {
            _savePreference(
              context,
              l10n,
              () => viewModel.setDateFormat(value),
            );
          }
        },
      ),
    );
  }
}
