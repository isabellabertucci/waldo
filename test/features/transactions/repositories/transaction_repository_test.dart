import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;
import 'package:waldo/features/transactions/repositories/transaction_repository.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/transactions/models/transaction.dart';
import '../../../helpers/test_app.dart';

void main() {
  late Database db;
  late TransactionRepositoryImpl repo;
  late WalletRepositoryImpl walletRepo;

  setUp(() async {
    db = await createTestDatabase();
    repo = TransactionRepositoryImpl(db);
    walletRepo = WalletRepositoryImpl(db);
  });

  tearDown(() async {
    await db.close();
  });

  Future<int> createWallet({int startingBalance = 0}) {
    return walletRepo.insert(
      Wallet(
        name: 'Test Wallet',
        startingBalance: startingBalance,
        currentBalance: startingBalance,
        createdAt: '2026-08-10T12:00:00.000',
      ),
    );
  }

  group('TransactionRepositoryImpl', () {
    test(
      'insert adds an income transaction and increases wallet balance',
      () async {
        final walletId = await createWallet(startingBalance: 1000);

        await repo.insert(
          Transaction(
            walletId: walletId,
            amount: 500,
            type: TransactionType.income,
            date: '2026-08-10',
            createdAt: '2026-08-10T12:00:00.000',
          ),
        );

        final wallet = await walletRepo.getById(walletId);
        expect(wallet!.currentBalance, 1500);
      },
    );

    test(
      'insert adds an expense transaction and decreases wallet balance',
      () async {
        final walletId = await createWallet(startingBalance: 1000);

        await repo.insert(
          Transaction(
            walletId: walletId,
            amount: 300,
            type: TransactionType.expense,
            date: '2026-08-10',
            createdAt: '2026-08-10T12:00:00.000',
          ),
        );

        final wallet = await walletRepo.getById(walletId);
        expect(wallet!.currentBalance, 700);
      },
    );

    test('getByWallet only returns transactions for that wallet', () async {
      final walletA = await createWallet();
      final walletB = await createWallet();

      await repo.insert(
        Transaction(
          walletId: walletA,
          amount: 100,
          type: TransactionType.income,
          date: '2026-08-10',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );
      await repo.insert(
        Transaction(
          walletId: walletB,
          amount: 200,
          type: TransactionType.income,
          date: '2026-08-10',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );

      final transactions = await repo.getByWallet(walletA);

      expect(transactions, hasLength(1));
      expect(transactions.first.walletId, walletA);
    });

    test(
      'update reverses the old effect and applies the new one, even across wallets',
      () async {
        final walletA = await createWallet(startingBalance: 1000);
        final walletB = await createWallet(startingBalance: 1000);

        final id = await repo.insert(
          Transaction(
            walletId: walletA,
            amount: 500,
            type: TransactionType.expense,
            date: '2026-08-10',
            createdAt: '2026-08-10T12:00:00.000',
          ),
        );

        // Wallet A: 1000 - 500 = 500
        var wA = await walletRepo.getById(walletA);
        expect(wA!.currentBalance, 500);

        final existing = await repo.getById(id);
        await repo.update(
          existing!.copyWith(
            walletId: walletB,
            amount: 200,
            type: TransactionType.income,
          ),
        );

        // Wallet A: reversed back to 1000
        wA = await walletRepo.getById(walletA);
        expect(wA!.currentBalance, 1000);

        // Wallet B: 1000 + 200 = 1200
        final wB = await walletRepo.getById(walletB);
        expect(wB!.currentBalance, 1200);
      },
    );

    test('delete reverses the transaction effect on the wallet', () async {
      final walletId = await createWallet(startingBalance: 1000);

      final id = await repo.insert(
        Transaction(
          walletId: walletId,
          amount: 400,
          type: TransactionType.income,
          date: '2026-08-10',
          createdAt: '2026-08-10T12:00:00.000',
        ),
      );

      var wallet = await walletRepo.getById(walletId);
      expect(wallet!.currentBalance, 1400);

      await repo.delete(id);

      wallet = await walletRepo.getById(walletId);
      expect(wallet!.currentBalance, 1000);
      expect(await repo.getById(id), isNull);
    });

    test('update throws when the transaction has no id', () async {
      final walletId = await createWallet();
      const transactionWithoutId = Transaction(
        walletId: 0,
        amount: 100,
        type: TransactionType.income,
        date: '2026-08-10',
        createdAt: '2026-08-10T12:00:00.000',
      );

      expect(
        () => repo.update(transactionWithoutId),
        throwsA(isA<ArgumentError>()),
      );
      // walletId used only to avoid an unused variable warning
      expect(walletId, isNotNull);
    });
  });
}
