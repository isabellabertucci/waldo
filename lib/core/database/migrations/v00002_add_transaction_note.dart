// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import '../../constants/db_constants.dart';

Future<void> up(Database db) async {
  await db.execute('''
    ALTER TABLE ${TransactionsTable.table}
    ADD COLUMN ${TransactionsTable.note} TEXT
  ''');
}
