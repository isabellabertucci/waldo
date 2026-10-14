import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' hide Transaction;

import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/features/dashboard/viewmodels/dashboard_view_model.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';

import '../../../helpers/test_app.dart';

void main() {
  late Database db;
  late ProviderContainer container;

  setUp(() async {
    db = await createTestDatabase();
    container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWith((ref) async => db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('creating a wallet through the form invalidates the dashboard, '
      'so totalBalance reflects it without a manual refresh', () async {
    final before = await container.read(dashboardViewModelProvider.future);
    expect(before.totalBalance, 0);

    final formNotifier = container.read(
      walletFormViewModelProvider(null).notifier,
    );
    formNotifier.updateName('Checking');
    formNotifier.updateBalance('100.00');
    await formNotifier.save(null);

    final after = await container.read(dashboardViewModelProvider.future);
    expect(after.totalBalance, 10000);
  });

  test(
    'deleting a wallet invalidates the dashboard so totalBalance drops',
    () async {
      final formNotifier = container.read(
        walletFormViewModelProvider(null).notifier,
      );
      formNotifier.updateName('Checking');
      formNotifier.updateBalance('50.00');
      await formNotifier.save(null);

      final withWallet = await container.read(
        dashboardViewModelProvider.future,
      );
      expect(withWallet.totalBalance, 5000);

      final repo = await container.read(walletRepositoryProvider.future);
      final inserted = (await repo.getAll()).first;

      await container
          .read(walletListViewModelProvider().notifier)
          .confirmDelete(inserted.id!);

      final afterDelete = await container.read(
        dashboardViewModelProvider.future,
      );
      expect(afterDelete.totalBalance, 0);
    },
  );
}
