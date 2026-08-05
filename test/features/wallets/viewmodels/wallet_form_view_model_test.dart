import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/core/database/migrations.dart' as migrations;
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_state.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await databaseFactoryFfiNoIsolate.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
    await migrations.onCreate(db, migrations.migrations.length);

    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWith((ref) async => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('WalletFormViewModel — initial state', () {
    test('build(null) starts empty with the default type', () {
      final state = container.read(walletFormViewModelProvider(null));

      expect(state.name, '');
      expect(state.type, WalletType.cash);
      expect(state.startingBalance, '');
      expect(state.nameError, isNull);
    });

    test('build(wallet) pre-fills fields from the existing wallet', () {
      const wallet = Wallet(
        id: 1,
        name: 'Cash',
        type: WalletType.credit,
        startingBalance: 12345,
        createdAt: '2026-08-04T12:00:00.000',
      );

      final state = container.read(walletFormViewModelProvider(wallet));

      expect(state.name, 'Cash');
      expect(state.type, WalletType.credit);
      expect(state.startingBalance, '123.45');
    });
  });

  group('WalletFormViewModel — save validation', () {
    test('empty name fails and does not persist anything', () async {
      final notifier = container.read(
        walletFormViewModelProvider(null).notifier,
      );

      final success = await notifier.save(null);

      expect(success, isFalse);
      final state = container.read(walletFormViewModelProvider(null));
      expect(state.nameError, isNotNull);

      final repo = await container.read(walletRepositoryProvider.future);
      expect(await repo.getAll(), isEmpty);
    });

    test('valid name with empty balance succeeds with 0 cents', () async {
      final notifier = container.read(
        walletFormViewModelProvider(null).notifier,
      );
      notifier.updateName('Cash');

      final success = await notifier.save(null);

      expect(success, isTrue);
      final repo = await container.read(walletRepositoryProvider.future);
      final wallets = await repo.getAll();
      expect(wallets.first.startingBalance, 0);
    });

    test('unparsable balance fails with invalidNumber', () async {
      final notifier = container.read(
        walletFormViewModelProvider(null).notifier,
      );
      notifier.updateName('Cash');
      notifier.updateBalance('abc');

      final success = await notifier.save(null);

      expect(success, isFalse);
      final state = container.read(walletFormViewModelProvider(null));
      expect(state.balanceError, WalletFormError.invalidNumber);
    });

    test('negative balance fails with invalidNumber', () async {
      final notifier = container.read(
        walletFormViewModelProvider(null).notifier,
      );
      notifier.updateName('Cash');
      notifier.updateBalance('-5');

      final success = await notifier.save(null);

      expect(success, isFalse);
      final state = container.read(walletFormViewModelProvider(null));
      expect(state.balanceError, WalletFormError.invalidNumber);
    });

    test('valid name and balance inserts the wallet in cents', () async {
      final notifier = container.read(
        walletFormViewModelProvider(null).notifier,
      );
      notifier.updateName('Cash');
      notifier.updateBalance('10.50');

      final success = await notifier.save(null);

      expect(success, isTrue);
      final repo = await container.read(walletRepositoryProvider.future);
      final wallets = await repo.getAll();
      expect(wallets.first.startingBalance, 1050);
      expect(wallets.first.currentBalance, wallets.first.startingBalance);
    });
  });
}
