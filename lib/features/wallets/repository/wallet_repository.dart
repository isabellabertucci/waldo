import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/database/db_providers.dart';
import '../model/wallet.dart';

part 'wallet_repository.g.dart';

abstract class IWalletRepository {
  Future<List<Wallet>> getAll();
  Future<Wallet?> getById(int id);
  Future<int> insert(Wallet wallet);
  Future<void> update(Wallet wallet);
  Future<void> delete(int id);
}

class WalletRepositoryImpl implements IWalletRepository {
  WalletRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<void> delete(int id) {
    throw UnimplementedError();
  }

  @override
  Future<List<Wallet>> getAll() async {
    final maps = await _db.query(WalletsTable.table);
    return maps.map((map) => Wallet.fromMap(map)).toList();
  }

  @override
  Future<Wallet?> getById(int id) {
    throw UnimplementedError();
  }

  @override
  Future<int> insert(Wallet wallet) async {
    return await _db.insert(WalletsTable.table, wallet.toMap());
  }

  @override
  Future<void> update(Wallet wallet) {
    throw UnimplementedError();
  }
}

@riverpod
IWalletRepository walletRepository(Ref ref) {
  final db = ref.watch(appDatabaseProvider).value;
  if (db == null) throw Exception('database not ready');
  return WalletRepositoryImpl(db);
}
