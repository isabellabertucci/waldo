import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../constants/db_constants.dart';
import 'migrations.dart';
import 'schema_check.dart';

final _log = Logger('waldo.db');

class AppDatabase {
  AppDatabase._();

  static final AppDatabase instance = AppDatabase._();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);

    var db = await _open(path);
    // Until release, v00001 is edited in place, so an older dev install keeps
    // its old tables at the same version. Debug only: recreate it.
    if (kDebugMode && !await _matchesCurrentSchema(db)) {
      _log.warning('Database schema is out of date; recreating it (debug)');
      await db.close();
      await databaseFactory.deleteDatabase(path);
      db = await _open(path);
    }
    return db;
  }

  Future<Database> _open(String path) {
    return openDatabase(
      path,
      version: migrations.length,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: onCreate,
      onUpgrade: onUpgrade,
    );
  }

  /// Compares against a throwaway in-memory database built from the migrations.
  Future<bool> _matchesCurrentSchema(Database db) async {
    final reference = await openDatabase(
      inMemoryDatabasePath,
      version: migrations.length,
      onCreate: onCreate,
      singleInstance: false,
    );
    try {
      return await matchesSchema(db, reference);
    } finally {
      await reference.close();
    }
  }

  // TODO: use only in devMode, delete when in prod.
  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);
    await databaseFactory.deleteDatabase(path);
  }
}
