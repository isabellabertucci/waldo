import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/theme/rounded.dart';
import 'package:waldo/features/wallets/ui/widgets/wallet_form_sheet.dart';

import '../helpers/golden_test_app.dart';
import '../helpers/test_app.dart';

void main() {
  late Database db;

  setUp(() async {
    db = await createTestDatabase();
  });

  tearDown(() => db.close());

  /// The sheet as it sits at the bottom of the screen when opened, over the
  /// page behind it.
  Widget sheet() => Builder(
    builder: (context) => Scaffold(
      body: Align(
        alignment: Alignment.bottomCenter,
        child: Material(
          color: context.appColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(Rounded.lg),
          ),
          child: const WalletFormSheet(),
        ),
      ),
    ),
  );

  goldenTest(
    'New wallet sheet - light',
    fileName: 'wallet_form_sheet_light',
    constraints: BoxConstraints.tight(const Size(460, 1000)),
    builder: () =>
        wrapForGolden(child: sheet(), db: db, brightness: Brightness.light),
  );

  goldenTest(
    'New wallet sheet - dark',
    fileName: 'wallet_form_sheet_dark',
    constraints: BoxConstraints.tight(const Size(460, 1000)),
    builder: () =>
        wrapForGolden(child: sheet(), db: db, brightness: Brightness.dark),
  );
}
