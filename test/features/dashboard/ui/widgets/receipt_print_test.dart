import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/utils/localization_delegates.dart';
import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../../../helpers/golden_seed.dart';
import '../../../../helpers/test_app.dart';

void main() {
  late Database db;
  late ProviderContainer container;
  final october = DateTime(2026, 10);
  final september = DateTime(2026, 9);

  setUp(() async {
    db = await createTestDatabase();
    final seed = await seedGoldenData(db);
    // September has a receipt too, so switching to it prints one.
    await TransactionRepositoryImpl(db).insert(
      Transaction(
        walletId: seed.walletId,
        amount: 1000,
        type: TransactionType.expense,
        date: '2026-09-12',
        createdAt: '2026-09-12T12:00:00.000',
      ),
    );
    container = ProviderContainer(
      overrides: [
        appDatabaseProvider.overrideWith((ref) async => db),
        clockProvider.overrideWithValue(() => seedToday),
      ],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<void> pumpHome(
    WidgetTester tester, {
    bool reduceMotion = false,
    bool show = true,
  }) async {
    tester.view.physicalSize = const Size(400, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          locale: const Locale('en'),
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: MediaQuery(
            data: MediaQueryData(
              size: const Size(400, 1600),
              disableAnimations: reduceMotion,
            ),
            child: show ? const DashboardScreen() : const SizedBox(),
          ),
        ),
      ),
    );
  }

  /// The receipt header's top edge: higher than [restingTop] mid-print.
  double receiptTop(WidgetTester tester) =>
      tester.getTopLeft(find.textContaining('WALDO')).dy;

  testWidgets('Home prints the month once; new figures only update it', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.pumpAndSettle();
    expect(
      container.read(playedMonthProvider(MonthIntro.receiptPrint)),
      october,
    );
    final restingTop = receiptTop(tester);

    // A new transaction reloads the figures.
    container.invalidate(dashboardViewModelProvider);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(receiptTop(tester), restingTop, reason: 'not printed again');
    await tester.pumpAndSettle();
  });

  testWidgets('Another month prints its own receipt', (tester) async {
    await pumpHome(tester);
    await tester.pumpAndSettle();
    final restingTop = receiptTop(tester);

    container.read(selectedDashboardMonthProvider.notifier).select(september);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(receiptTop(tester), lessThan(restingTop), reason: 'feeding out');

    await tester.pumpAndSettle();
    expect(receiptTop(tester), restingTop);
    expect(
      container.read(playedMonthProvider(MonthIntro.receiptPrint)),
      september,
    );
  });

  testWidgets('Coming back to a printed month, as after scrolling it away, '
      "doesn't print it again", (tester) async {
    await pumpHome(tester);
    await tester.pumpAndSettle();
    final restingTop = receiptTop(tester);

    await pumpHome(tester, show: false);
    await pumpHome(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(receiptTop(tester), restingTop);
  });

  testWidgets('With reduce motion on, a new month shows its receipt at once', (
    tester,
  ) async {
    await pumpHome(tester, reduceMotion: true);
    await tester.pumpAndSettle();
    final restingTop = receiptTop(tester);

    container.read(selectedDashboardMonthProvider.notifier).select(september);
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(receiptTop(tester), restingTop);
  });
}
