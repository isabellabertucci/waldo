import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/confirmation_dialog.dart';
import 'package:waldo/core/widgets/dashed_stitch_button.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  testWidgets('Cancel and the confirm button are the same size', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () => ConfirmationDialog.show(
              context,
              title: 'Delete wallet',
              content: 'This deletes it.',
              confirmLabel: 'Delete',
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    Size sizeOf(String label) => tester.getSize(
      find.ancestor(
        of: find.text(label),
        matching: find.byType(DashedStitchButton),
      ),
    );
    expect(sizeOf('Cancel'), sizeOf('Delete'));
    expect(sizeOf('Cancel').height, greaterThanOrEqualTo(48));
  });
}
