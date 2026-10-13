import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/models/transaction_filter.dart';

void main() {
  Transaction transactionOn(String date, TransactionType type) {
    return Transaction(
      walletId: 1,
      amount: 500,
      type: type,
      date: date,
      createdAt: '2026-10-01T12:00:00.000',
    );
  }

  group('TransactionFilter.matches', () {
    final october = TransactionFilter(month: DateTime(2026, 10));

    test('accepts a transaction in the filtered month', () {
      expect(
        october.matches(
          transactionOn('2026-10-15T09:30:00.000', TransactionType.expense),
        ),
        isTrue,
      );
    });

    test('a leap-day transaction belongs to February, not March', () {
      final leapDay = transactionOn(
        '2028-02-29T23:30:00.000',
        TransactionType.expense,
      );
      expect(
        TransactionFilter(month: DateTime(2028, 2)).matches(leapDay),
        isTrue,
      );
      expect(
        TransactionFilter(month: DateTime(2028, 3)).matches(leapDay),
        isFalse,
      );
    });

    test('rejects a transaction in a different month', () {
      expect(
        october.matches(
          transactionOn('2026-09-30T23:59:00.000', TransactionType.expense),
        ),
        isFalse,
      );
    });

    test('rejects the same month in a different year', () {
      expect(
        october.matches(
          transactionOn('2025-10-15T09:30:00.000', TransactionType.expense),
        ),
        isFalse,
      );
    });

    test('with no type accepts both income and expense', () {
      expect(
        october.matches(
          transactionOn('2026-10-15T09:30:00.000', TransactionType.income),
        ),
        isTrue,
      );
      expect(
        october.matches(
          transactionOn('2026-10-15T09:30:00.000', TransactionType.expense),
        ),
        isTrue,
      );
    });

    test('with a type rejects the other type', () {
      final incomeOnly = october.copyWith(type: TransactionType.income);

      expect(
        incomeOnly.matches(
          transactionOn('2026-10-15T09:30:00.000', TransactionType.income),
        ),
        isTrue,
      );
      expect(
        incomeOnly.matches(
          transactionOn('2026-10-15T09:30:00.000', TransactionType.expense),
        ),
        isFalse,
      );
    });
  });
}
