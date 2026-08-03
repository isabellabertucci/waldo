import 'package:sqflite/sqflite.dart';
import 'migrations/v00001_create_initial_schema.dart' as m00001;

final List<Future<void> Function(Database db)> migrations = [m00001.up];

/// onCreate runs every migration, from the first one up to
/// the current database version. Used when the database is brand new.
Future<void> onCreate(Database db, int targetVersion) async {
  for (var v = 0; v < targetVersion; v++) {
    await migrations[v](db);
  }
}

/// runs the migrations from the version the user already has
/// to the most current version. Used when the database already exists.
Future<void> onUpgrade(Database db, int oldVersion, int newVersion) async {
  for (var v = oldVersion; v < newVersion; v++) {
    await migrations[v](db);
  }
}
