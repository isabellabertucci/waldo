import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import '../models/wallet.dart';

part 'wallet_repository.g.dart';

final _log = Logger('waldo.repository.wallet');

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
    try {
      final direction = sortOrder == SortOrder.desc ? 'DESC' : 'ASC';
      final maps = await _db.query(
        WalletsTable.table,
        orderBy: '${WalletsTable.createdAt} $direction',
      );
      _log.fine('getAll succeeded: rowCount=${maps.length}');
      return maps.map((map) => Wallet.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      _log.severe('getAll failed', e);
      rethrow;
    }
  }

  @override
  Future<Wallet?> getById(int id) async {
    try {
      final maps = await _db.query(
        WalletsTable.table,
        where: '${WalletsTable.id} = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        _log.fine('getById: not found, id=$id');
        return null;
      }
      return Wallet.fromMap(maps.first);
    } on DatabaseException catch (e) {
      _log.severe('getById failed', e);
      rethrow;
    }
  }

  @override
  Future<int> insert(Wallet wallet) async {
    try {
      final id = await _db.insert(WalletsTable.table, wallet.toMap());
      _log.info('insert succeeded: id=$id');
      return id;
    } on DatabaseException catch (e) {
      _log.severe('insert failed', e);
      rethrow;
    }
  }

  @override
  Future<void> update(Wallet wallet) async {
    final id = wallet.id;
    if (id == null) {
      throw ArgumentError('Cannot update a wallet without an id');
    }
    try {
      final affectedRows = await _db.update(
        WalletsTable.table,
        {WalletsTable.name: wallet.name, WalletsTable.type: wallet.type.name},
        where: '${WalletsTable.id} = ?',
        whereArgs: [id],
      );
      if (affectedRows == 0) {
        _log.warning('update: no rows affected, id=$id');
        throw StateError('Cannot update a wallet with id $id: not found');
      }
      _log.info('update succeeded: id=$id, affectedRows=$affectedRows');
    } on DatabaseException catch (e) {
      _log.severe('update failed', e);
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final affectedRows = await _db.delete(
        WalletsTable.table,
        where: '${WalletsTable.id} = ?',
        whereArgs: [id],
      );
      if (affectedRows == 0) {
        _log.warning('delete: no rows affected, id=$id');
      } else {
        _log.info('delete succeeded: id=$id, affectedRows=$affectedRows');
      }
    } on DatabaseException catch (e) {
      _log.severe('delete failed', e);
      rethrow;
    }
  }
}

@riverpod
Future<IWalletRepository> walletRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return WalletRepositoryImpl(db);
}
