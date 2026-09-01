import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/database/db_providers.dart';
import '../models/category.dart';

part 'category_repository.g.dart';

final _log = Logger('waldo.repository.category');

abstract class ICategoryRepository {
  Future<List<Category>> getAll();
  Future<Category?> getById(int id);
  Future<int> insert(Category category);
  Future<void> update(Category category);
  Future<void> delete(int id);
}

class CategoryRepositoryImpl implements ICategoryRepository {
  CategoryRepositoryImpl(this._db);

  final Database _db;

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
  Future<int> insert(Category category) async {
    try {
      final id = await _db.insert(CategoriesTable.table, category.toMap());
      _log.info('insert succeeded: id=$id');
      return id;
    } on DatabaseException catch (e) {
      _log.severe('insert failed', e);
      rethrow;
    }
  }

  @override
  @override
  Future<void> update(Category category) async {
    final id = category.id;
    if (id == null) {
      throw ArgumentError('Cannot update a category without an id');
    }
    try {
      final affectedRows = await _db.update(
        CategoriesTable.table,
        {CategoriesTable.name: category.name},
        where: '${CategoriesTable.id} = ?',
        whereArgs: [id],
      );
      if (affectedRows == 0) {
        _log.warning('update: no rows affected, id=$id');
        throw StateError('Cannot update a category with id $id: not found');
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
        CategoriesTable.table,
        where: '${CategoriesTable.id} = ?',
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
Future<ICategoryRepository> categoryRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return CategoryRepositoryImpl(db);
}
