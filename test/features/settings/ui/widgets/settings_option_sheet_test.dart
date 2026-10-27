import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_colors.dart';
import 'package:waldo/core/theme/app_icons.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/dashed_border.dart';
import 'package:waldo/features/settings/ui/widgets/settings_option_sheet.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  testWidgets('Only the selected option has the app stitch', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SettingsOptionSheet<int>(
            title: 'Theme',
            initialValue: 1,
            onConfirm: (_) {},
            options: const [
              SettingsOption(value: 1, label: 'Light', icon: AppIcons.add),
              SettingsOption(value: 2, label: 'Dark', icon: AppIcons.add),
            ],
          ),
        ),
      ),
    );

    Color stitchOf(String label) => tester
        .widget<DashedBorder>(
          find.ancestor(
            of: find.text(label),
            matching: find.byType(DashedBorder),
          ),
        )
        .color;
    expect(stitchOf('Light'), AppColors.light.primary);
    expect(stitchOf('Dark'), AppColors.light.transparent);
  });
}
