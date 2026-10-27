import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import '../models/category.dart';

part 'category_repository.g.dart';

final _log = Logger('waldo.repository.category');

/// "Others" is where a deleted category's transactions go, so it stays.
class CannotDeleteOthersCategoryException implements Exception {}

class DuplicateCategoryNameException implements Exception {}

abstract class ICategoryRepository {
  Future<List<Category>> getAll();
  Future<Category?> getById(int id);

  /// The built-in "Others" category: the home of uncategorized transactions.
  Future<Category> getOthers();
  Future<int> insert(Category category);
  Future<int> countTransactions(int categoryId);

  /// Moves the category's transactions to "Others", then deletes it.
  Future<void> delete(int id);
}

class CategoryRepositoryImpl implements ICategoryRepository {
  CategoryRepositoryImpl(this._db);

  final Database _db;

  static const _othersWhere =
      '${CategoriesTable.isDefault} = 1 AND ${CategoriesTable.type} = ?';

  @override
  Future<List<Category>> getAll() async {
    try {
      final maps = await _db.query(
        CategoriesTable.table,
        orderBy: '${CategoriesTable.name} ASC',
      );
      _log.fine('getAll succeeded: rowCount=${maps.length}');
      return maps.map((map) => Category.fromMap(map)).toList();
    } on DatabaseException catch (e) {
      _log.severe('getAll failed', e);
      rethrow;
    }
  }

  @override
  Future<Category?> getById(int id) async {
    try {
      final maps = await _db.query(
        CategoriesTable.table,
        where: '${CategoriesTable.id} = ?',
        whereArgs: [id],
      );
      if (maps.isEmpty) {
        _log.fine('getById: not found, id=$id');
        return null;
      }
      return Category.fromMap(maps.first);
    } on DatabaseException catch (e) {
      _log.severe('getById failed', e);
      rethrow;
    }
  }

  @override
  Future<Category> getOthers() async {
    try {
      final maps = await _db.query(
        CategoriesTable.table,
        where: _othersWhere,
        whereArgs: [CategoryType.others.name],
        limit: 1,
      );
      if (maps.isEmpty) throw StateError('The Others category is missing');
      _log.fine('getOthers succeeded: id=${maps.first[CategoriesTable.id]}');
      return Category.fromMap(maps.first);
    } on DatabaseException catch (e) {
      _log.severe('getOthers failed', e);
      rethrow;
    }
  }

  @override
  Future<int> insert(Category category) async {
    try {
      final id = await _db.insert(CategoriesTable.table, category.toMap());
      _log.info('insert succeeded: id=$id');
      return id;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        _log.warning('insert rejected: duplicate name');
        throw DuplicateCategoryNameException();
      }
      _log.severe('insert failed', e);
      rethrow;
    }
  }

  @override
  Future<int> countTransactions(int categoryId) async {
    try {
      final result = await _db.rawQuery(
        'SELECT COUNT(*) AS count FROM ${TransactionsTable.table} '
        'WHERE ${TransactionsTable.categoryId} = ?',
        [categoryId],
      );
      final count = result.first['count']! as int;
      _log.fine('countTransactions: categoryId=$categoryId, count=$count');
      return count;
    } on DatabaseException catch (e) {
      _log.severe('countTransactions failed', e);
      rethrow;
    }
  }

  @override
  Future<void> delete(int id) async {
    try {
      final others = await getOthers();
      if (others.id == id) throw CannotDeleteOthersCategoryException();

      // Both steps or neither, so no transaction is left pointing nowhere.
      await _db.transaction((txn) async {
        final moved = await txn.update(
          TransactionsTable.table,
          {TransactionsTable.categoryId: others.id},
          where: '${TransactionsTable.categoryId} = ?',
          whereArgs: [id],
        );
        final deleted = await txn.delete(
          CategoriesTable.table,
          where: '${CategoriesTable.id} = ?',
          whereArgs: [id],
        );
        _log.info(
          'delete succeeded: id=$id, deleted=$deleted, movedToOthers=$moved',
        );
      });
    } on DatabaseException catch (e) {
      _log.severe('delete failed', e);
      rethrow;
    }
  }
}

@riverpod
Future<ICategoryRepository> categoryRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return CategoryRepositoryImpl(db);
}
