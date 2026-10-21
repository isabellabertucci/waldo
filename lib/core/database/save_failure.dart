import 'package:sqflite/sqflite.dart';
import 'package:waldo/l10n/app_localizations.dart';

/// Why a save failed, in terms the user can act on.
enum SaveFailure { storageFull, temporary, unknown }

/// Classifies an error thrown while writing, so a sheet can name the problem.
SaveFailure saveFailureOf(Object error) {
  if (error is! DatabaseException) return SaveFailure.unknown;
  if (error.isDatabaseClosedError()) return SaveFailure.temporary;
  // iOS reports the basic code, Android the extended one; the low byte matches.
  return switch ((error.getResultCode() ?? 0) & 0xFF) {
    13 => SaveFailure.storageFull, // SQLITE_FULL
    5 || 6 => SaveFailure.temporary, // SQLITE_BUSY, SQLITE_LOCKED
    _ => SaveFailure.unknown,
  };
}

/// What to tell the person when [error] stopped a write: the cause when it's
/// known, else [unknown], the screen's own "nothing was changed" message.
String failureMessage(
  AppLocalizations l10n,
  Object error, {
  required String unknown,
}) => switch (saveFailureOf(error)) {
  SaveFailure.storageFull => l10n.saveErrorStorageFull,
  SaveFailure.temporary => l10n.saveErrorTemporary,
  SaveFailure.unknown => unknown,
};
