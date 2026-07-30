import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

part 'db_providers.g.dart';

@riverpod
Future<Database> appDatabase(Ref ref) async {
  return AppDatabase.instance.database;
}
