import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/constants/db_constants.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

import '../../../helpers/test_app.dart';

void main() {
  late Database db;
  late WalletRepositoryImpl repo;

  setUp(() async {
    db = await createTestDatabase();
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

    test('getAll with SortOrder.asc returns oldest first', () async {
      await repo.insert(
        const Wallet(name: 'Older', createdAt: '2026-08-01T00:00:00.000'),
      );
      await repo.insert(
        const Wallet(name: 'Newer', createdAt: '2026-08-03T00:00:00.000'),
      );

      final wallets = await repo.getAll(sortOrder: SortOrder.asc);

      expect(wallets.first.name, 'Older');
      expect(wallets.last.name, 'Newer');
    });

    test('getById returns null for a non-existent id', () async {
      final wallet = await repo.getById(999);
      expect(wallet, isNull);
    });

    test(
      'update only changes name and type, not balance or createdAt',
      () async {
        final id = await repo.insert(
          const Wallet(
            name: 'Cash',
            startingBalance: 1000,
            currentBalance: 2000,
            createdAt: '2026-08-04T12:00:00.000',
          ),
        );
        final wallet = await repo.getById(id);

        await repo.update(
          wallet!.copyWith(
            name: 'Renamed',
            type: WalletType.savings,
            startingBalance: 999999,
            currentBalance: 888888,
            createdAt: '2020-01-01T00:00:00.000',
          ),
        );
        final updated = await repo.getById(id);

        expect(updated!.name, 'Renamed');
        expect(updated.type, WalletType.savings);
        expect(updated.startingBalance, 1000);
        expect(updated.currentBalance, 2000);
        expect(updated.createdAt, '2026-08-04T12:00:00.000');
      },
    );

    test('update throws when the wallet has no id', () async {
      const walletWithoutId = Wallet(
        name: 'No id',
        createdAt: '2026-08-04T12:00:00.000',
      );

      expect(() => repo.update(walletWithoutId), throwsA(isA<ArgumentError>()));
    });

    test('delete removes a wallet with no transactions', () async {
      final id = await repo.insert(
        const Wallet(name: 'Cash', createdAt: '2026-08-04T12:00:00.000'),
      );

      await repo.delete(id);

      expect(await repo.getById(id), isNull);
    });

    test(
      'delete cascades and removes transactions belonging to the wallet',
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

        await repo.delete(walletId);

        expect(await repo.getById(walletId), isNull);

        final remainingTransactions = await db.query(
          TransactionsTable.table,
          where: '${TransactionsTable.walletId} = ?',
          whereArgs: [walletId],
        );
        expect(remainingTransactions, isEmpty);
      },
    );
  });
}
