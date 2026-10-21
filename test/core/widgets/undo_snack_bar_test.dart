import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/widgets/undo_snack_bar.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  late ScaffoldMessengerState messenger;

  Future<void> pumpHost(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) {
              messenger = ScaffoldMessenger.of(context);
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
  }

  /// Shows a bar and records its result once it's known.
  List<bool> show(String subtitle) {
    final results = <bool>[];
    showUndoSnackBar(
      messenger,
      title: 'Wallet deleted',
      subtitle: subtitle,
      restoredLabel: 'Wallet restored',
    ).then(results.add);
    return results;
  }

  testWidgets('Shows the title, the item and a countdown from 5', (
    tester,
  ) async {
    await pumpHost(tester);
    show('Index funds');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('Wallet deleted'), findsOneWidget);
    expect(find.text('Index funds'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    expect(find.text('3'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
  });

  testWidgets('Undo completes with true and confirms the restore', (
    tester,
  ) async {
    await pumpHost(tester);
    final results = show('Index funds');
    // Not pumpAndSettle: the countdown would run all the way out.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(results, [true]);
    expect(find.text('Wallet restored'), findsOneWidget);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Wallet restored'), findsNothing);
  });

  testWidgets('Without Undo, completes with false after 5 seconds', (
    tester,
  ) async {
    await pumpHost(tester);
    final results = show('Index funds');
    await tester.pump();

    await tester.pump(const Duration(seconds: 4));
    expect(results, isEmpty);

    await tester.pump(const Duration(seconds: 1, milliseconds: 100));
    await tester.pumpAndSettle();
    expect(results, [false]);
    expect(find.text('Wallet deleted'), findsNothing);
  });

  testWidgets('With a screen reader on, the bar waits for Undo instead of '
      'timing out', (tester) async {
    // VoiceOver or TalkBack: reaching the Undo button takes longer than 5 s.
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(accessibleNavigation: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpHost(tester);
    final results = show('Index funds');
    await tester.pump();

    await tester.pump(const Duration(seconds: 30));
    expect(results, isEmpty);
    expect(find.text('Wallet deleted'), findsOneWidget);
    expect(find.text('5'), findsNothing, reason: 'no clock while it waits');

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(results, [true]);
  });

  testWidgets('A second delete finalizes the first at once and restarts '
      'the countdown', (tester) async {
    await pumpHost(tester);
    final first = show('Index funds');
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    final second = show('Pocket cash');
    // Not pumpAndSettle: the countdown would run all the way out.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 350));

    expect(first, [false]);
    expect(second, isEmpty);
    expect(find.text('Pocket cash'), findsOneWidget);
    expect(find.text('5'), findsOneWidget);

    await tester.pump(const Duration(seconds: 6));
    await tester.pumpAndSettle();
    expect(second, [false]);
  });

  testWidgets('The countdown pauses while the app is in the background', (
    tester,
  ) async {
    await pumpHost(tester);
    final results = show('Index funds');
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 10));
    expect(results, isEmpty);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(results, [false]);
  });
}
