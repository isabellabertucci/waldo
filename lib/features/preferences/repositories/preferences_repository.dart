import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/database/db_providers.dart';
import '../models/preferences.dart';

part 'preferences_repository.g.dart';

final _log = Logger('waldo.repository.preferences');

abstract class IPreferencesRepository {
  Future<Preferences> getPreferences();
  Future<void> setCurrency(String currency);
  Future<void> setDarkMode(bool? isDarkMode);
  Future<void> setDateFormat(String dateFormat);
}

class PreferencesRepositoryImpl implements IPreferencesRepository {
  PreferencesRepositoryImpl(this._db);

  final Database _db;

  static const _rowId = 1;

  @override
  Future<Preferences> getPreferences() async {
    try {
      final maps = await _db.query(
        PreferencesTable.table,
        where: '${PreferencesTable.id} = ?',
        whereArgs: [_rowId],
      );

      if (maps.isNotEmpty) {
        _log.fine('getPreferences: existing row found');
        return Preferences.fromMap(maps.first);
      }

      _log.info('getPreferences: no row found, inserting defaults');
      const defaults = Preferences();
      await _db.insert(PreferencesTable.table, {
        PreferencesTable.id: _rowId,
        PreferencesTable.preferredCurrency: defaults.currency,
        PreferencesTable.themeDark: null,
        PreferencesTable.dateFormat: defaults.dateFormat,
        PreferencesTable.updatedAt: DateTime.now().toIso8601String(),
      });
      return defaults;
    } on DatabaseException catch (e) {
      _log.severe('getPreferences failed', e);
      rethrow;
    }
  }

  @override
  Future<void> setCurrency(String currency) {
    return _updateColumn(PreferencesTable.preferredCurrency, currency);
  }

  @override
  Future<void> setDarkMode(bool? isDarkMode) {
    return _updateColumn(
      PreferencesTable.themeDark,
      isDarkMode == null ? null : (isDarkMode ? 1 : 0),
    );
  }

  @override
  Future<void> setDateFormat(String dateFormat) {
    return _updateColumn(PreferencesTable.dateFormat, dateFormat);
  }

  Future<void> _updateColumn(String column, Object? value) async {
    try {
      final affectedRows = await _db.update(
        PreferencesTable.table,
        {
          column: value,
          PreferencesTable.updatedAt: DateTime.now().toIso8601String(),
        },
        where: '${PreferencesTable.id} = ?',
        whereArgs: [_rowId],
      );
      if (affectedRows == 0) {
        _log.warning('_updateColumn: no rows affected, column=$column');
      } else {
        _log.info('_updateColumn succeeded: column=$column');
      }
    } on DatabaseException catch (e) {
      _log.severe('_updateColumn failed: column=$column', e);
      rethrow;
    }
  }
}

@riverpod
Future<IPreferencesRepository> preferencesRepository(Ref ref) async {
  final db = await ref.watch(appDatabaseProvider.future);
  return PreferencesRepositoryImpl(db);
}
