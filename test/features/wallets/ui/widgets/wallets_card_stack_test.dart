import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/ui/widgets/wallets_card_stack.dart';

import '../../../../helpers/test_app.dart';

void main() {
  Future<void> pumpStack(
    WidgetTester tester,
    double? savedPercent, {
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
          savedPercent: savedPercent,
          onTapWallet: onTapWallet ?? (_) {},
          onEditWallet: (_) {},
          onDeleteWallet: (_) {},
        ),
      ),
    );
    addTearDown(db.close);
  }

  testWidgets('A negative savings rate reads as overspending', (tester) async {
    await pumpStack(tester, -50);
    expect(find.text('Spent 50% more than you received'), findsOneWidget);
  });

  testWidgets('A positive rate reads as kept', (tester) async {
    await pumpStack(tester, 75);
    expect(find.text('Kept 75% of what you received'), findsOneWidget);
  });

  testWidgets('A rate that rounds to 0 reads as kept 0%', (tester) async {
    await pumpStack(tester, -0.3);
    expect(find.text('Kept 0% of what you received'), findsOneWidget);
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
}
