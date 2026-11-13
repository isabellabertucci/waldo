import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:waldo/core/database/db_providers.dart';
import 'package:waldo/features/preferences/models/preferences.dart';
import 'package:waldo/features/preferences/repositories/preferences_repository.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';

import '../../../helpers/test_app.dart';

class MockPreferencesRepository extends Mock
    implements IPreferencesRepository {}

void main() {
  late Database db;

  setUp(() async => db = await createTestDatabase());
  tearDown(() => db.close());

  ProviderContainer containerFor(Database db) {
    final container = ProviderContainer(
      overrides: [appDatabaseProvider.overrideWith((ref) async => db)],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('Hiding amounts holds after no screen was watching', () async {
    final container = containerFor(db);
    await container.read(preferencesViewModelProvider.future);
    await container.read(balanceHiddenProvider.notifier).toggle();

    // Nothing listens, so both providers are disposed, then read again.
    await container.pump();
    await container.read(preferencesViewModelProvider.future);

    expect(container.read(balanceHiddenProvider), isTrue);
  });

  test('Hidden amounts stay hidden after the app restarts', () async {
    final before = containerFor(db);
    await before.read(preferencesViewModelProvider.future);
    await before.read(balanceHiddenProvider.notifier).toggle();

    // A fresh container on the same database, as on the next launch.
    final after = containerFor(db);
    await after.read(preferencesViewModelProvider.future);

    expect(after.read(balanceHiddenProvider), isTrue);
  });

  test('A failed save shows the amounts again', () async {
    final repo = MockPreferencesRepository();
    when(repo.getPreferences).thenAnswer((_) async => const Preferences());
    when(() => repo.setBalanceHidden(true)).thenThrow(Exception('disk full'));
    final container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWith((ref) async => repo),
      ],
    );
    addTearDown(container.dispose);
    await container.read(preferencesViewModelProvider.future);

    await container.read(balanceHiddenProvider.notifier).toggle();

    expect(container.read(balanceHiddenProvider), isFalse);
  });
}
