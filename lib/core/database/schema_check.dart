import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

/// Whether [db] has the same tables, with the same columns, as [reference].
/// Used in debug builds to spot an install made before `v00001` last changed.
Future<bool> matchesSchema(Database db, Database reference) async {
  final actual = await _columnsByTable(db);
  final expected = await _columnsByTable(reference);
  if (!setEquals(actual.keys.toSet(), expected.keys.toSet())) return false;
  return expected.keys.every(
    (table) => setEquals(actual[table], expected[table]),
  );
}

Future<Map<String, Set<String>>> _columnsByTable(Database db) async {
  final tables = await db.rawQuery(
    "SELECT name FROM sqlite_master WHERE type = 'table' "
    "AND name NOT LIKE 'sqlite_%' AND name != 'android_metadata'",
  );
  return {
    for (final row in tables)
      row['name']! as String: {
        for (final column in await db.rawQuery(
          'PRAGMA table_info(${row['name']})',
        ))
          column['name']! as String,
      },
  };
}
