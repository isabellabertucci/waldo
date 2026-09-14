import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/core/theme/spacing.dart';
import 'package:waldo/features/preferences/models/preferences.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';
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
        _SectionLabel(title: l10n.darkMode),
        _SettingsCard(
          children: [
            _SettingsRow(
              icon: Icons.dark_mode_outlined,
              title: l10n.darkMode,
              value: _themeLabel(l10n, preferences.isDarkMode),
              onTap: () =>
                  _showThemeSheet(context, l10n, viewModel, preferences),
            ),
          ],
        ),

        const SizedBox(height: Spacing.lg),

        _SectionLabel(title: l10n.currency),
        _SettingsCard(
          children: [
            _SettingsRow(
              icon: Icons.attach_money,
              title: l10n.currency,
              value: preferences.currency,
              onTap: () =>
                  _showCurrencySheet(context, l10n, viewModel, preferences),
            ),
          ],
        ),

        const SizedBox(height: Spacing.lg),

        _SectionLabel(title: l10n.dateFormat),
        _SettingsCard(
          children: [
            _SettingsRow(
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

  void _showThemeSheet(
    BuildContext context,
    AppLocalizations l10n,
    PreferencesViewModel viewModel,
    Preferences preferences,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _OptionSheet<bool?>(
        title: l10n.darkMode,
        groupValue: preferences.isDarkMode,
        options: [
          _Option(label: l10n.themeSystem, value: null),
          _Option(label: l10n.themeLight, value: false),
          _Option(label: l10n.themeDark, value: true),
        ],
        onSelected: viewModel.setDarkMode,
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
      builder: (context) => _OptionSheet<String>(
        title: l10n.currency,
        groupValue: preferences.currency,
        options: [
          _Option(label: l10n.currencyOptionUsd, value: 'USD'),
          _Option(label: l10n.currencyOptionEur, value: 'EUR'),
          _Option(label: l10n.currencyOptionGbp, value: 'GBP'),
        ],
        onSelected: (value) {
          if (value != null) viewModel.setCurrency(value);
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
      builder: (context) => _OptionSheet<String>(
        title: l10n.dateFormat,
        groupValue: preferences.dateFormat,
        options: [
          _Option(
            label: DateFormat('dd/MM/yyyy').format(now),
            value: 'dd/MM/yyyy',
          ),
          _Option(
            label: DateFormat('MM/dd/yyyy').format(now),
            value: 'MM/dd/yyyy',
          ),
          _Option(
            label: DateFormat('yyyy-MM-dd').format(now),
            value: 'yyyy-MM-dd',
          ),
        ],
        onSelected: (value) {
          if (value != null) viewModel.setDateFormat(value);
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.sm, left: 4),
      child: Text(
        title,
        style: context.textTheme.labelLarge?.copyWith(
          color: context.appColors.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(child: Column(children: children));
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;

    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: BorderRadius.circular(Rounded.md),
        ),
        child: Icon(icon, size: 18, color: colors.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: context.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: context.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: Spacing.xs),
          Icon(Icons.chevron_right, size: 20, color: colors.onSurfaceVariant),
        ],
      ),
    );
  }
}

class _Option<T> {
  const _Option({required this.label, required this.value});

  final String label;
  final T value;
}

class _OptionSheet<T> extends StatelessWidget {
  const _OptionSheet({
    required this.title,
    required this.groupValue,
    required this.options,
    required this.onSelected,
  });

  final String title;
  final T groupValue;
  final List<_Option<T>> options;
  final ValueChanged<T?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(Spacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: Spacing.md),
            RadioGroup<T>(
              groupValue: groupValue,
              onChanged: (value) {
                onSelected(value);
                Navigator.of(context).pop();
              },
              child: Column(
                children: options
                    .map(
                      (option) => RadioListTile<T>(
                        title: Text(option.label),
                        value: option.value,
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
