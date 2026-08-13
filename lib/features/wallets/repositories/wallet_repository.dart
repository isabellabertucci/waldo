import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/logging/log.dart';
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

  void _logDatabaseException(String operation, DatabaseException e) {
    final message = e.toString().toLowerCase();
    if (message.contains('foreign key constraint')) {
      repositoryLog.severe('$operation failed: foreign key constraint', e);
    } else if (message.contains('check constraint')) {
      repositoryLog.severe('$operation failed: check constraint', e);
    } else {
      repositoryLog.severe('$operation failed: database error', e);
    }
  }

  @override
  Future<List<Wallet>> getAll({SortOrder sortOrder = SortOrder.desc}) async {
    try {
      final direction = sortOrder == SortOrder.desc ? 'DESC' : 'ASC';
      final maps = await _db.query(
        WalletsTable.table,
        orderBy: '${WalletsTable.createdAt} $direction',
      );
      repositoryLog.fine('getAll succeeded: rowCount=${maps.length}');
      return maps.map((map) => Wallet.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      _logDatabaseException('getAll', e);
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
        repositoryLog.fine('getById: not found, id=$id');
        return null;
      }
      return Wallet.fromMap(maps.first);
    } on DatabaseException catch (e) {
      _logDatabaseException('getById', e);
      rethrow;
    }
  }

  @override
  Future<int> insert(Wallet wallet) async {
    try {
      final id = await _db.insert(WalletsTable.table, wallet.toMap());
      repositoryLog.info('insert succeeded: id=$id');
      return id;
    } on DatabaseException catch (e) {
      _logDatabaseException('insert', e);
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
        repositoryLog.warning('update: no rows affected, id=$id');
        throw StateError('Cannot update a wallet with id $id: not found');
      }
      repositoryLog.info('update succeeded: id=$id');
    } on DatabaseException catch (e) {
      _logDatabaseException('update', e);
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
      repositoryLog.info(
        'delete succeeded: id=$id, rowsAffected=$affectedRows',
      );
    } on DatabaseException catch (e) {
      _logDatabaseException('delete', e);
      rethrow;
    }
  }
}

@riverpod
Future<IWalletRepository> walletRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return WalletRepositoryImpl(db);
}
