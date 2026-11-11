import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/theme/motion.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/viewmodels/just_added_wallet.dart';
import 'package:waldo/features/wallets/ui/widgets/wallets_card_stack.dart';

import '../../../../helpers/test_app.dart';

void main() {
  Future<void> pumpStack(
    WidgetTester tester,
    double? keptPercent, {
    ValueChanged<Wallet>? onTapWallet,
  }) async {
    final db = await pumpWidgetWithProviders(
      tester,
      Scaffold(
        body: WalletsCardStack(
          wallets: const [
            Wallet(id: 1, name: 'Cash', createdAt: '2026-08-01T12:00:00.000'),
          ],
          currency: Currency.usd,
          isBalanceHidden: false,
          keptPercent: keptPercent,
          onTapWallet: onTapWallet ?? (_) {},
          onEditWallet: (_) {},
          onDeleteWallet: (_) {},
        ),
      ),
    );
    addTearDown(db.close);
  }

  /// The total's one screen-reader stop, which reads the caption whole.
  String caption(WidgetTester tester) =>
      tester.getSemantics(find.text('Total balance')).label;

  testWidgets('A negative savings rate reads as overspending', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpStack(tester, -50);
    expect(caption(tester), contains('Spent 50% more than you received'));
    semantics.dispose();
  });

  testWidgets('A positive rate reads as kept', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpStack(tester, 75);
    expect(caption(tester), contains('Kept 75% of what you received'));
    semantics.dispose();
  });

  testWidgets('A rate that rounds to 0 reads as kept 0%', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpStack(tester, -0.3);
    expect(caption(tester), contains('Kept 0% of what you received'));
    semantics.dispose();
  });

  testWidgets('Tapping the empty lower part of a card opens the wallet', (
    tester,
  ) async {
    Wallet? tapped;
    await pumpStack(tester, null, onTapWallet: (w) => tapped = w);

    // Bottom-left corner, well away from the name, type and balance.
    final card = tester.getRect(find.byKey(const Key('walletCard_1')));
    await tester.tapAt(card.bottomLeft + const Offset(24, -16));
    await tester.pumpAndSettle();

    expect(tapped?.id, 1);
  });

  testWidgets('The kept percentage simply shows, with nothing moving', (
    tester,
  ) async {
    await pumpStack(tester, 75);
    await tester.pump();

    expect(find.text('Kept 75% of what you received'), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });

  group('Cards moving', () {
    Wallet wallet(int id) => Wallet(
      id: id,
      name: 'Wallet $id',
      createdAt: '2026-08-0${id}T12:00:00.000',
    );
    final wallets = ValueNotifier<List<Wallet>>([]);
    late ProviderContainer container;

    setUp(() => wallets.value = [wallet(1), wallet(2), wallet(3)]);

    Future<void> pumpCards(
      WidgetTester tester, {
      bool reduceMotion = false,
    }) async {
      final db = await pumpWidgetWithProviders(
        tester,
        MediaQuery(
          data: MediaQueryData(
            size: const Size(400, 1200),
            disableAnimations: reduceMotion,
          ),
          child: Scaffold(
            body: ValueListenableBuilder(
              valueListenable: wallets,
              // No wallets, no stack: the screen shows its empty state.
              builder: (context, wallets, _) => wallets.isEmpty
                  ? const SizedBox()
                  : WalletsCardStack(
                      wallets: wallets,
                      currency: Currency.usd,
                      isBalanceHidden: false,
                      keptPercent: null,
                      onTapWallet: (_) {},
                      onEditWallet: (_) {},
                      onDeleteWallet: (_) {},
                    ),
            ),
          ),
        ),
      );
      addTearDown(db.close);
      container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold)),
      );
    }

    Finder card(int id) => find.byKey(Key('walletCard_$id'));
    Rect rect(WidgetTester tester, int id) => tester.getRect(card(id));

    testWidgets('A deleted card slides straight out, and the cards below '
        'close the gap without a jump', (tester) async {
      final haptics = recordHaptics(tester);
      await pumpCards(tester);
      final before = rect(tester, 2);
      final belowBefore = rect(tester, 3);

      wallets.value = [wallet(1), wallet(3)];
      await tester.pump();
      expect(haptics, ['HapticFeedbackType.mediumImpact']);
      // Under way at once, only ever to the left: no shake first.
      var lastLeft = before.left;
      for (var t = 0; t < 4; t++) {
        await tester.pump(Motion.cardGapDelay ~/ 5);
        expect(rect(tester, 2).left, lessThan(lastLeft));
        lastLeft = rect(tester, 2).left;
      }
      expect(rect(tester, 3), belowBefore);

      await tester.pump(Motion.cardLeave);
      expect(rect(tester, 2).right, lessThan(0));

      var lastBelow = rect(tester, 3);
      while (card(2).evaluate().isNotEmpty) {
        lastBelow = rect(tester, 3);
        await tester.pump(const Duration(milliseconds: 16));
      }
      expect(rect(tester, 3).top, closeTo(lastBelow.top, 0.5));
      expect(rect(tester, 3).top, before.top);
    });

    testWidgets('Undo brings the card back as the cards below make room', (
      tester,
    ) async {
      await pumpCards(tester);
      final before = rect(tester, 2);
      final belowBefore = rect(tester, 3);
      wallets.value = [wallet(1), wallet(3)];
      await tester.pumpAndSettle();

      wallets.value = [wallet(1), wallet(2), wallet(3)];
      await tester.pump();
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(of: card(2), matching: find.byType(Opacity)).first,
            )
            .opacity,
        0,
      );
      // Still where it was, and from there it moves down.
      expect(rect(tester, 3).top, before.top);

      await tester.pumpAndSettle();
      expect(rect(tester, 2), before);
      expect(rect(tester, 3), belowBefore);
    });

    testWidgets('A new wallet\'s card drops in from above while the others '
        'make room, once', (tester) async {
      final haptics = recordHaptics(tester);
      await pumpCards(tester);
      final first = rect(tester, 1);

      final justAdded = justAddedWalletProvider(WalletLanding.stack);
      container.read(justAdded.notifier).set(4);
      wallets.value = [wallet(4), wallet(1), wallet(2), wallet(3)];
      await tester.pump();
      // Made in the sheet over the stack: it waits for the sheet to slide
      // away, unseen above its place, the card below still where it was.
      for (var i = 0; i < 3; i++) {
        await tester.pump(Motion.sheetExit ~/ 3);
      }
      expect(
        rect(tester, 4).top,
        lessThanOrEqualTo(first.top - Motion.cardLandHeight),
      );
      expect(
        tester
            .widget<Opacity>(
              find.ancestor(of: card(4), matching: find.byType(Opacity)).first,
            )
            .opacity,
        0,
      );
      expect(rect(tester, 1).top, first.top);

      await tester.pumpAndSettle();
      expect(rect(tester, 4).top, first.top);
      expect(rect(tester, 1).top, greaterThan(first.top));
      expect(haptics, ['HapticFeedbackType.lightImpact']);
      expect(container.read(justAdded), isNull);
    });

    testWidgets('A wallet made from Home lands the first time the stack '
        'shows', (tester) async {
      await pumpCards(tester);
      final first = rect(tester, 1);
      wallets.value = [];
      await tester.pumpAndSettle();
      container
          .read(justAddedWalletProvider(WalletLanding.stack).notifier)
          .set(4);

      wallets.value = [wallet(4), wallet(1), wallet(2), wallet(3)];
      await tester.pump();
      expect(rect(tester, 4).top, lessThan(first.top));
      await tester.pumpAndSettle();
      expect(rect(tester, 4).top, first.top);
    });

    testWidgets('With reduce motion on, a deleted card is simply gone', (
      tester,
    ) async {
      await pumpCards(tester, reduceMotion: true);

      wallets.value = [wallet(1), wallet(3)];
      await tester.pump();
      expect(card(2), findsNothing);
    });
  });
}
