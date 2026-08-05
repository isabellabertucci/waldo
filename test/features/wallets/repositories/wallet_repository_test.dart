import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/core/database/migrations.dart' as migrations;
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
  });

  late Database db;
  late WalletRepositoryImpl repo;

  setUp(() async {
    db = await databaseFactoryFfiNoIsolate.openDatabase(inMemoryDatabasePath);
    await db.execute('PRAGMA foreign_keys = ON');
    await migrations.onCreate(db, migrations.migrations.length);
    repo = WalletRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  group('WalletRepositoryImpl', () {
    test('insert then getAll returns the inserted wallet', () async {
      await repo.insert(
        const Wallet(name: 'Cash', createdAt: '2026-08-04T12:00:00.000'),
      );

      final wallets = await repo.getAll();

      expect(wallets, hasLength(1));
      expect(wallets.first.name, 'Cash');
    });

    test('getAll orders by createdAt descending', () async {
      await repo.insert(
        const Wallet(name: 'Older', createdAt: '2026-08-01T00:00:00.000'),
      );
      await repo.insert(
        const Wallet(name: 'Newer', createdAt: '2026-08-03T00:00:00.000'),
      );

      final wallets = await repo.getAll();

      expect(wallets.first.name, 'Newer');
      expect(wallets.last.name, 'Older');
    });

    test('getById returns null for a non-existent id', () async {
      final wallet = await repo.getById(999);
      expect(wallet, isNull);
    });

    test('update changes the wallet fields', () async {
      final id = await repo.insert(
        const Wallet(name: 'Cash', createdAt: '2026-08-04T12:00:00.000'),
      );
      final wallet = await repo.getById(id);

      await repo.update(
        wallet!.copyWith(name: 'Renamed', type: WalletType.savings),
      );
      final updated = await repo.getById(id);

      expect(updated!.name, 'Renamed');
      expect(updated.type, WalletType.savings);
    });

    test('delete removes a wallet with no transactions', () async {
      final id = await repo.insert(
        const Wallet(name: 'Cash', createdAt: '2026-08-04T12:00:00.000'),
      );

      await repo.delete(id);

      expect(await repo.getById(id), isNull);
    });

    test(
      'delete throws a friendly error when the wallet has transactions',
      () async {
        final walletId = await repo.insert(
          const Wallet(name: 'Cash', createdAt: '2026-08-04T12:00:00.000'),
        );

        await db.insert(TransactionsTable.table, {
          TransactionsTable.walletId: walletId,
          TransactionsTable.amount: 500,
          TransactionsTable.type: 'expense',
          TransactionsTable.date: '2026-08-04',
          TransactionsTable.createdAt: '2026-08-04T12:00:00.000',
        });

        expect(
          () => repo.delete(walletId),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('has transactions'),
            ),
          ),
        );

        expect(await repo.getById(walletId), isNotNull);
      },
    );
  });
}
