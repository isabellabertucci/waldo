import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../constants/db_constants.dart';
import '../logging/log.dart';
import 'migrations.dart';

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

    dbLog.info(
      'Database open started: path=$path, targetVersion=${migrations.length}',
    );

    try {
      final db = await openDatabase(
        path,
        version: migrations.length,
        onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
        onCreate: onCreate,
        onUpgrade: onUpgrade,
      );
      dbLog.info('Database open succeeded: version=${await db.getVersion()}');
      return db;
    } catch (error, stackTrace) {
      dbLog.severe('Database open failed', error, stackTrace);
      rethrow;
    }
  }

  // TODO: use only in devMode, delete when in prod.
  static Future<void> deleteDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, dbName);
    await databaseFactory.deleteDatabase(path);
  }
}
