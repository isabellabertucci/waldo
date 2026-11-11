import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/theme/app_theme.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/utils/localization_delegates.dart';
import 'package:waldo/features/dashboard/ui/dashboard_screen.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/just_added_wallet.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';
import 'package:waldo/l10n/app_localizations.dart';

import '../../../../helpers/golden_seed.dart';
import '../../../../helpers/test_app.dart';

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await createTestDatabase();
    await seedGoldenData(db);
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
    bool onScreen = true,
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
            // As the shell mutes a tab that isn't on screen.
            child: TickerMode(
              enabled: onScreen,
              child: show ? const DashboardScreen() : const SizedBox(),
            ),
          ),
        ),
      ),
    );
  }

  /// Saves a wallet as the form does: newest, so its card is on top.
  Future<void> addTravelWallet() async {
    final id = await WalletRepositoryImpl(db).insert(
      const Wallet(name: 'Travel', createdAt: '2026-10-09T12:00:00.000'),
    );
    container
        .read(justAddedWalletProvider(WalletLanding.pouch).notifier)
        .set(id);
    container.invalidate(walletListViewModelProvider());
    container.invalidate(dashboardViewModelProvider);
  }

  final travel = find.text('Travel');

  /// Lets the lists reload until the new card is on top.
  Future<void> pumpUntilTravelShows(WidgetTester tester) async {
    for (var i = 0; i < 20 && travel.evaluate().isEmpty; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(travel, findsOneWidget);
  }

  double cardTop(WidgetTester tester) => tester.getTopLeft(travel).dy;

  testWidgets('A new wallet drops its card into the pouch, once', (
    tester,
  ) async {
    await pumpHome(tester);
    await tester.pumpAndSettle();
    await addTravelWallet();
    await pumpUntilTravelShows(tester);
    await tester.pump(const Duration(milliseconds: 50));
    final falling = cardTop(tester);

    await tester.pumpAndSettle();
    final resting = cardTop(tester);
    expect(falling, lessThan(resting), reason: 'it fell in from above');
    expect(
      container.read(justAddedWalletProvider(WalletLanding.pouch)),
      isNull,
    );

    // Back on Home later, as after a tab switch: no second drop.
    await pumpHome(tester, show: false);
    await pumpHome(tester);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(cardTop(tester), resting);
  });

  testWidgets('Made while Home is off screen, it drops when Home comes back', (
    tester,
  ) async {
    // Home was open, then another tab took over (Riverpod pauses it).
    await pumpHome(tester);
    await tester.pumpAndSettle();
    await pumpHome(tester, onScreen: false);
    await addTravelWallet();
    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(
      container.read(justAddedWalletProvider(WalletLanding.pouch)),
      isNotNull,
      reason: 'it waits for Home',
    );

    await pumpHome(tester);
    await pumpUntilTravelShows(tester);
    await tester.pump(const Duration(milliseconds: 50));
    final falling = cardTop(tester);
    await tester.pumpAndSettle();
    expect(falling, lessThan(cardTop(tester)));
    expect(
      container.read(justAddedWalletProvider(WalletLanding.pouch)),
      isNull,
    );
  });

  testWidgets('With reduce motion on, the card simply appears in place', (
    tester,
  ) async {
    await pumpHome(tester, reduceMotion: true);
    await tester.pumpAndSettle();
    await addTravelWallet();
    await pumpUntilTravelShows(tester);
    await tester.pump();
    final shown = cardTop(tester);

    await tester.pumpAndSettle();
    expect(cardTop(tester), shown);
    expect(
      container.read(justAddedWalletProvider(WalletLanding.pouch)),
      isNull,
    );
  });
}
