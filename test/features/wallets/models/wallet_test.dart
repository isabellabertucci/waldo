import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';

void main() {
  group('Wallet mapping', () {
    test('toMap/fromMap round-trip preserves all fields', () {
      const wallet = Wallet(
        id: 1,
        name: 'Cash',
        type: WalletType.credit,
        startingBalance: 1050,
        currentBalance: 2000,
        createdAt: '2026-08-04T12:00:00.000',
      );

      final map = wallet.toMap();
      final restored = Wallet.fromMap(map);

      expect(restored, wallet);
    });

    test('toMap stores the enum as its string name', () {
      const wallet = Wallet(
        name: 'Savings',
        type: WalletType.savings,
        createdAt: '2026-08-04T12:00:00.000',
      );

      expect(wallet.toMap()['type'], 'savings');
    });

    test('fromMap parses a null id as a new wallet', () {
      final map = {
        'id': null,
        'name': 'Cash',
        'type': 'cash',
        'starting_balance': 0,
        'current_balance': 0,
        'created_at': '2026-08-04T12:00:00.000',
      };

      expect(Wallet.fromMap(map).id, isNull);
    });
  });
}
