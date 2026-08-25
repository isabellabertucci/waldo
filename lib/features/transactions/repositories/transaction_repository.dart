import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import '../models/transaction.dart';

part 'transaction_repository.g.dart';

final _log = Logger('waldo.repository.transaction');

abstract class ITransactionRepository {
  Future<List<Transaction>> getByWallet(
    int walletId, {
    SortOrder sortOrder = SortOrder.desc,
  });
  Future<Transaction?> getById(int id);
  Future<int> insert(Transaction transaction);
  Future<void> update(Transaction transaction);
  Future<void> delete(int id);
}

class TransactionRepositoryImpl implements ITransactionRepository {
  TransactionRepositoryImpl(this._db);

  final Database _db;

  Future<void> _adjustWalletBalance(
    DatabaseExecutor executor,
    int walletId,
    int delta,
  ) async {
    await executor.rawUpdate(
      'UPDATE ${WalletsTable.table} '
      'SET ${WalletsTable.currentBalance} = ${WalletsTable.currentBalance} + ? '
      'WHERE ${WalletsTable.id} = ?',
      [delta, walletId],
    );
  }

  @override
  Future<List<Transaction>> getByWallet(
    int walletId, {
    SortOrder sortOrder = SortOrder.desc,
  }) async {
    try {
      final direction = sortOrder == SortOrder.desc ? 'DESC' : 'ASC';
      final maps = await _db.query(
        TransactionsTable.table,
        where: '${TransactionsTable.walletId} = ?',
        whereArgs: [walletId],
        // Tie-break on id when dates are equal, so ordering is stable
        // and deterministic instead of relying on unspecified SQLite order.
        orderBy:
            '${TransactionsTable.date} $direction, ${TransactionsTable.id} $direction',
      );
      _log.fine(
        'getByWallet succeeded: walletId=$walletId, rowCount=${maps.length}',
      );
      return maps.map((map) => Transaction.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      _log.severe('getByWallet failed', e);
      rethrow;
    }
  }

  @override
  Future<Transaction?> getById(int id) async {
    try {
      final maps = await _db.query(
        TransactionsTable.table,
        where: '${TransactionsTable.id} = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        _log.fine('getById: not found, id=$id');
        return null;
      }
      return Transaction.fromMap(maps.first);
    } on DatabaseException catch (e) {
      _log.severe('getById failed', e);
      rethrow;
    }
  }

  @override
  Future<int> insert(Transaction transaction) async {
    try {
      return await _db.transaction((txn) async {
        final id = await txn.insert(
          TransactionsTable.table,
          transaction.toMap(),
        );
        await _adjustWalletBalance(
          txn,
          transaction.walletId,
          transaction.signedAmount,
        );
        _log.info('insert succeeded: id=$id, walletId=${transaction.walletId}');
        return id;
      });
    } on DatabaseException catch (e) {
      _log.severe('insert failed', e);
      rethrow;
    }
  }

  @override
  Future<void> update(Transaction transaction) async {
    final id = transaction.id;
    if (id == null) {
      throw ArgumentError('Cannot update a transaction without an id');
    }
    try {
      await _db.transaction((txn) async {
        final existingMaps = await txn.query(
          TransactionsTable.table,
          where: '${TransactionsTable.id} = ?',
          whereArgs: [id],
        );
        if (existingMaps.isEmpty) {
          _log.warning('update: no rows affected, id=$id');
          throw StateError(
            'Cannot update a transaction with id $id: not found',
          );
        }
        final existing = Transaction.fromMap(existingMaps.first);

        // Reverse the old effect on the old wallet, then apply the new
        // effect on the (possibly different) new wallet.
        await _adjustWalletBalance(
          txn,
          existing.walletId,
          -existing.signedAmount,
        );
        await _adjustWalletBalance(
          txn,
          transaction.walletId,
          transaction.signedAmount,
        );

        // Only the fields a user can actually edit are written. id and
        // created_at are never overwritten by an update.
        final affectedRows = await txn.update(
          TransactionsTable.table,
          {
            TransactionsTable.walletId: transaction.walletId,
            TransactionsTable.categoryId: transaction.categoryId,
            TransactionsTable.amount: transaction.amount,
            TransactionsTable.type: transaction.type.name,
            TransactionsTable.date: transaction.date,
            TransactionsTable.description: transaction.description,
          },
          where: '${TransactionsTable.id} = ?',
          whereArgs: [id],
        );
        _log.info('update succeeded: id=$id, affectedRows=$affectedRows');
      });
    } on DatabaseException catch (e) {
      _log.severe('update failed', e);
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      await _db.transaction((txn) async {
        final existingMaps = await txn.query(
          TransactionsTable.table,
          where: '${TransactionsTable.id} = ?',
          whereArgs: [id],
        );
        if (existingMaps.isEmpty) {
          _log.warning('delete: no rows affected, id=$id');
          return;
        }
        final existing = Transaction.fromMap(existingMaps.first);

        final affectedRows = await txn.delete(
          TransactionsTable.table,
          where: '${TransactionsTable.id} = ?',
          whereArgs: [id],
        );

        await _adjustWalletBalance(
          txn,
          existing.walletId,
          -existing.signedAmount,
        );

        _log.info('delete succeeded: id=$id, affectedRows=$affectedRows');
      });
    } on DatabaseException catch (e) {
      _log.severe('delete failed', e);
      rethrow;
    }
  }
}

@riverpod
Future<ITransactionRepository> transactionRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return TransactionRepositoryImpl(db);
}
