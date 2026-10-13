import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/database/migrations.dart';
import 'package:waldo/core/database/schema_check.dart';

import '../../helpers/test_app.dart';

void main() {
  // Its own in-memory database, like AppDatabase's reference copy.
  Future<Database> openReference() => databaseFactoryFfiNoIsolate.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: migrations.length,
      onCreate: onCreate,
      singleInstance: false,
    ),
  );

  test('A database built from the current migrations matches', () async {
    final db = await createTestDatabase();
    final reference = await openReference();
    addTearDown(db.close);
    addTearDown(reference.close);

    expect(await matchesSchema(db, reference), isTrue);
  });

  test('An install missing a column added to v00001 does not match', () async {
    final db = await createTestDatabase();
    final reference = await openReference();
    addTearDown(db.close);
    addTearDown(reference.close);
    // A device whose database predates the note column.
    await db.execute('ALTER TABLE transactions DROP COLUMN note');

    expect(await matchesSchema(db, reference), isFalse);
  });
}
