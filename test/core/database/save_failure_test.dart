import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/database/save_failure.dart';
import 'package:waldo/l10n/app_localizations_en.dart';

/// A [DatabaseException] with a chosen result code, as sqflite would throw.
class _FakeDatabaseException extends DatabaseException {
  _FakeDatabaseException(super.message, [this.code]);

  final int? code;

  @override
  int? getResultCode() => code;

  @override
  Object? get result => null;
}

void main() {
  final cases = <(String, Object, SaveFailure)>[
    (
      'a full disk',
      _FakeDatabaseException('disk full', 13),
      SaveFailure.storageFull,
    ),
    (
      'a busy database',
      _FakeDatabaseException('busy', 5),
      SaveFailure.temporary,
    ),
    (
      'a locked database',
      _FakeDatabaseException('locked', 6),
      SaveFailure.temporary,
    ),
    (
      // Android reports the extended code: SQLITE_BUSY_SNAPSHOT.
      'an extended busy code',
      _FakeDatabaseException('busy', 517),
      SaveFailure.temporary,
    ),
    (
      'a closed database',
      _FakeDatabaseException('This database has already been closed'),
      SaveFailure.temporary,
    ),
    (
      'another database error',
      _FakeDatabaseException('io', 10),
      SaveFailure.unknown,
    ),
    (
      'a database error with no code',
      _FakeDatabaseException('?'),
      SaveFailure.unknown,
    ),
    (
      'an error from outside the database',
      StateError('x'),
      SaveFailure.unknown,
    ),
  ];

  for (final (name, error, expected) in cases) {
    test('saveFailureOf classifies $name as $expected', () {
      expect(saveFailureOf(error), expected);
    });
  }

  group('failureMessage', () {
    final l10n = AppLocalizationsEn();

    test('names the cause when it is known', () {
      expect(
        failureMessage(l10n, _FakeDatabaseException('full', 13), unknown: 'x'),
        l10n.saveErrorStorageFull,
      );
      expect(
        failureMessage(l10n, _FakeDatabaseException('busy', 5), unknown: 'x'),
        l10n.saveErrorTemporary,
      );
    });

    test('falls back to the screen\'s own message otherwise', () {
      expect(failureMessage(l10n, StateError('?'), unknown: 'x'), 'x');
    });
  });
}
