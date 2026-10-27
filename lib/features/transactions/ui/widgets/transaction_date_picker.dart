import 'package:flutter/material.dart';

/// The calendar for a transaction's date, up to today: the month rows stop at
/// the current month, so a later date could never be found again.
Future<DateTime?> showTransactionDatePicker(
  BuildContext context, {
  required DateTime initialDate,
  required DateTime now,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: DateTime(2000),
    // Never before the date it opens on, which the picker requires.
    lastDate: initialDate.isAfter(now) ? initialDate : now,
  );
}
