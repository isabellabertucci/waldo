import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/transactions/models/transaction.dart';

void main() {
  group('Transaction mapping', () {
    test('toMap/fromMap round-trip preserves all fields', () {
      const transaction = Transaction(
        id: 1,
        walletId: 5,
        categoryId: 3,
        amount: 1050,
        type: TransactionType.expense,
        date: '2026-08-10',
        description: 'Groceries',
        createdAt: '2026-08-10T12:00:00.000',
      );

      final map = transaction.toMap();
      final restored = Transaction.fromMap(map);

      expect(restored, transaction);
    });

    test('toMap stores the enum as its string name', () {
      const transaction = Transaction(
        walletId: 5,
        amount: 500,
        type: TransactionType.income,
        date: '2026-08-10',
        createdAt: '2026-08-10T12:00:00.000',
      );

      expect(transaction.toMap()['type'], 'income');
    });

    test('fromMap handles a null categoryId and description', () {
      final map = {
        'id': null,
        'wallet_id': 5,
        'category_id': null,
        'amount': 500,
        'type': 'expense',
        'date': '2026-08-10',
        'description': null,
        'created_at': '2026-08-10T12:00:00.000',
      };

      final transaction = Transaction.fromMap(map);

      expect(transaction.categoryId, isNull);
      expect(transaction.description, isNull);
    });
  });
}
