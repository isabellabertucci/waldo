import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/wallets_x.dart';

Wallet _wallet(LeatherFinish finish) =>
    Wallet(name: finish.name, finish: finish, createdAt: '2026-08-04');

void main() {
  group('suggestedFinish', () {
    test('The first wallet is black', () {
      expect(suggestedFinish(const []), LeatherFinish.black);
    });

    test('Suggests the leather the fewest wallets wear', () {
      final wallets = [
        _wallet(LeatherFinish.black),
        _wallet(LeatherFinish.yellow),
        _wallet(LeatherFinish.white),
      ];

      expect(suggestedFinish(wallets), LeatherFinish.green);
    });

    test('Ties go to the first in order', () {
      final wallets = [for (final f in LeatherFinish.values) _wallet(f)];

      expect(suggestedFinish(wallets), LeatherFinish.black);
    });
  });

  group('positiveShareLabel', () {
    test('Rounds to a whole percent', () {
      expect(positiveShareLabel(217, 1000), '22%');
    });

    test('A sliver reads <1%, not 0%', () {
      expect(positiveShareLabel(1, 100000), '<1%');
    });

    test('Nothing for a wallet at or below zero', () {
      expect(positiveShareLabel(0, 1000), isNull);
      expect(positiveShareLabel(-5, 1000), isNull);
    });
  });
}
