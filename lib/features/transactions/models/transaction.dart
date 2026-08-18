import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/enums.dart';

part 'transaction.freezed.dart';

@freezed
abstract class Transaction with _$Transaction {
  const Transaction._();

  const factory Transaction({
    int? id,
    required int walletId,
    int? categoryId,
    required int amount,
    required TransactionType type,
    required String date,
    String? description,
    required String createdAt,
  }) = _Transaction;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'wallet_id': walletId,
      'category_id': categoryId,
      'amount': amount,
      'type': type.name,
      'date': date,
      'description': description,
      'created_at': createdAt,
    };
  }

  factory Transaction.fromMap(Map<String, Object?> map) {
    return Transaction(
      id: map['id'] as int?,
      walletId: map['wallet_id'] as int,
      categoryId: map['category_id'] as int?,
      amount: map['amount'] as int,
      type: TransactionType.values.byName(map['type'] as String),
      date: map['date'] as String,
      description: map['description'] as String?,
      createdAt: map['created_at'] as String,
    );
  }
}
