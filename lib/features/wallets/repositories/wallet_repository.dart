import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import '../models/wallet.dart';

part 'wallet_repository.g.dart';

abstract class IWalletRepository {
  Future<List<Wallet>> getAll({SortOrder sortOrder = SortOrder.desc});
  Future<Wallet?> getById(int id);
  Future<int> insert(Wallet wallet);
  Future<void> update(Wallet wallet);
  Future<void> delete(int id);
}

class WalletRepositoryImpl implements IWalletRepository {
  WalletRepositoryImpl(this._db);

  final Database _db;

  @override
  Future<List<Wallet>> getAll({SortOrder sortOrder = SortOrder.desc}) async {
    final direction = sortOrder == SortOrder.desc ? 'DESC' : 'ASC';
    final maps = await _db.query(
      WalletsTable.table,
      orderBy: '${WalletsTable.createdAt} $direction',
    );
    return maps.map((map) => Wallet.fromMap(map)).toList();
  }

  @override
  Future<Wallet?> getById(int id) async {
    final maps = await _db.query(
      WalletsTable.table,
      where: '${WalletsTable.id} = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Wallet.fromMap(maps.first);
  }

  @override
  Future<int> insert(Wallet wallet) async {
    return await _db.insert(WalletsTable.table, wallet.toMap());
  }

  @override
  Future<void> update(Wallet wallet) async {
    final id = wallet.id;
    if (id == null) {
      throw ArgumentError('Cannot update a wallet without an id');
    }
    await _db.update(
      WalletsTable.table,
      {WalletsTable.name: wallet.name, WalletsTable.type: wallet.type.name},
      where: '${WalletsTable.id} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> delete(int id) async {
    await _db.delete(
      WalletsTable.table,
      where: '${WalletsTable.id} = ?',
      whereArgs: [id],
    );
  }
}

@riverpod
Future<IWalletRepository> walletRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return WalletRepositoryImpl(db);
}
