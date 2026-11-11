import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/component_size.dart';
import 'package:waldo/core/widgets/wallet_card_finish.dart';
import 'package:waldo/features/dashboard/ui/widgets/balance_overview_card.dart';
import 'package:waldo/l10n/app_localizations.dart';

void main() {
  Future<void> pumpPouch(
    WidgetTester tester,
    List<String> names, {
    int? walletCount,
    bool landing = false,
  }) {
    return tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: SingleChildScrollView(
            // A new pouch each time, as the dashboard builds one per front card.
            child: BalanceOverviewCard(
              key: UniqueKey(),
              totalBalance: 0,
              currency: Currency.usd,
              isBalanceHidden: false,
              cardMonthLabel: 'Oct 2026',
              walletCount: walletCount ?? names.length,
              peekWalletNames: names,
              landing: landing,
              onAddPressed: () {},
              onToggleBalanceHidden: () {},
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('The three newest cards peek out, each older one only an edge '
      'a step higher; just the front one is named', (tester) async {
    await pumpPouch(tester, ['Travel', 'Savings', 'Cash', 'Old']);

    final tops = [
      for (final e in find.byType(WalletCardBackground).evaluate())
        tester.getTopLeft(find.byWidget(e.widget)).dy,
    ]..sort();
    expect(tops, hasLength(3));
    expect(tops[1] - tops[0], ComponentSize.balancePeekStep);
    expect(tops[2] - tops[1], ComponentSize.balancePeekStep);

    expect(find.text('Travel'), findsOneWidget);
    expect(find.text('OCT 2026'), findsOneWidget);
    for (final hidden in ['Savings', 'Cash', 'Old']) {
      expect(find.text(hidden), findsNothing);
    }
  });

  testWidgets('The pouch sits a step lower for each card behind the front', (
    tester,
  ) async {
    Future<double> pouchTop(List<String> names) async {
      await pumpPouch(tester, names);
      return tester.getTopLeft(find.text('Total balance')).dy;
    }

    final one = await pouchTop(['Cash']);
    final two = await pouchTop(['Savings', 'Cash']);
    final three = await pouchTop(['Travel', 'Savings', 'Cash']);
    final four = await pouchTop(['New', 'Travel', 'Savings', 'Cash']);
    expect(two - one, ComponentSize.balancePeekStep);
    expect(three - two, ComponentSize.balancePeekStep);
    expect(four, three, reason: 'three cards at most');
  });

  /// The top of each card, back to front.
  List<double> cardTops(WidgetTester tester) => [
    for (final e in find.byType(WalletCardBackground).evaluate())
      tester.getTopLeft(find.byWidget(e.widget)).dy,
  ]..sort();

  testWidgets('With the pouch full, a new card in front sends the others up '
      'a step, and the one that was in front loses its name', (tester) async {
    await pumpPouch(
      tester,
      ['New', 'Travel', 'Savings'],
      walletCount: 4,
      landing: true,
    );
    await tester.pumpAndSettle();
    final settled = cardTops(tester);

    await pumpPouch(
      tester,
      ['New', 'Travel', 'Savings'],
      walletCount: 4,
      landing: true,
    );
    await tester.pump(const Duration(milliseconds: 1));
    // Travel and Savings start a step lower, where they were before.
    final start = tester.getTopLeft(find.text('Travel')).dy;
    await tester.pumpAndSettle();
    expect(
      start - tester.getTopLeft(find.text('Travel')).dy,
      closeTo(ComponentSize.balancePeekStep, 0.5),
    );

    expect(cardTops(tester).toSet(), settled.toSet());
    final travelName = tester.widget<FadeTransition>(
      find
          .ancestor(
            of: find.text('Travel'),
            matching: find.byType(FadeTransition),
          )
          .first,
    );
    expect(travelName.opacity.value, 0);
  });

  testWidgets('With room left, the cards stay and the pouch slides down a '
      'step under the new one', (tester) async {
    Future<double> pouchTop() async =>
        tester.getTopLeft(find.text('Total balance')).dy;

    await pumpPouch(tester, ['Travel', 'Savings']);
    final before = await pouchTop();

    await pumpPouch(
      tester,
      ['New', 'Travel', 'Savings'],
      walletCount: 3,
      landing: true,
    );
    await tester.pump(const Duration(milliseconds: 1));
    expect(await pouchTop(), closeTo(before, 1));

    await tester.pumpAndSettle();
    expect(await pouchTop(), before + ComponentSize.balancePeekStep);
  });
}
