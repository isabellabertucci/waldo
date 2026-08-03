import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:waldo/core/constants/enums.dart';

part 'wallet.freezed.dart';

@freezed
abstract class Wallet with _$Wallet {
  const Wallet._();

  const factory Wallet({
    int? id,
    required String name,
    @Default(WalletType.cash) WalletType type,
    @Default(0) int startingBalance,
    @Default(0) int currentBalance,
    required String createdAt,
  }) = _Wallet;

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'starting_balance': startingBalance,
      'current_balance': currentBalance,
      'created_at': createdAt,
    };
  }

  factory Wallet.fromMap(Map<String, Object?> map) {
    return Wallet(
      id: map['id'] as int?,
      name: map['name'] as String,
      type: WalletType.values.byName(map['type'] as String),
      startingBalance: map['starting_balance'] as int,
      currentBalance: map['current_balance'] as int,
      createdAt: map['created_at'] as String,
    );
  }
}
