import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/ui/widgets/wallets_card_stack.dart';

import '../../../../helpers/test_app.dart';

void main() {
  Future<void> pumpStack(WidgetTester tester, double? savedPercent) async {
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
          onTapWallet: (_) {},
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

  testWidgets('A positive savings rate reads as saved', (tester) async {
    await pumpStack(tester, 75);
    expect(find.text('Saved 75% this month'), findsOneWidget);
  });

  testWidgets('A rate that rounds to 0 reads as saved 0%', (tester) async {
    await pumpStack(tester, -0.3);
    expect(find.text('Saved 0% this month'), findsOneWidget);
  });
}
