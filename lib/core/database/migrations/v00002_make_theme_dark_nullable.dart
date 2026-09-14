// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../../constants/db_constants.dart';

/// SQLite can't drop a NOT NULL constraint with a plain ALTER TABLE, so the
/// table is rebuilt: create the new shape, copy rows over, then swap names.
///
/// Pre-migration rows can't distinguish "never explicitly set" from
/// "explicitly set to light" (both stored as 0), so a stored 0 is mapped to
/// NULL and treated as unset, falling back to the system theme. A stored 1
/// (explicitly chosen dark) is preserved as-is.
Future<void> up(Database db) async {
  await db.execute('''
    CREATE TABLE ${PreferencesTable.table}_new (
      ${PreferencesTable.id} INTEGER PRIMARY KEY AUTOINCREMENT,
      ${PreferencesTable.preferredCurrency} TEXT NOT NULL DEFAULT 'USD',
      ${PreferencesTable.themeDark} INTEGER,
      ${PreferencesTable.dateFormat} TEXT NOT NULL DEFAULT 'yyyy-MM-dd',
      ${PreferencesTable.updatedAt} TEXT NOT NULL
    )
  ''');

  await db.execute('''
    INSERT INTO ${PreferencesTable.table}_new (
      ${PreferencesTable.id},
      ${PreferencesTable.preferredCurrency},
      ${PreferencesTable.themeDark},
      ${PreferencesTable.dateFormat},
      ${PreferencesTable.updatedAt}
    )
    SELECT
      ${PreferencesTable.id},
      ${PreferencesTable.preferredCurrency},
      CASE WHEN ${PreferencesTable.themeDark} = 0 THEN NULL
           ELSE ${PreferencesTable.themeDark} END,
      ${PreferencesTable.dateFormat},
      ${PreferencesTable.updatedAt}
    FROM ${PreferencesTable.table}
  ''');

  await db.execute('DROP TABLE ${PreferencesTable.table}');
  await db.execute(
    'ALTER TABLE ${PreferencesTable.table}_new RENAME TO ${PreferencesTable.table}',
  );
}
