import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_list_view_model.dart';

class MockWalletRepository extends Mock implements IWalletRepository {}

void main() {
  late MockWalletRepository mockRepo;
  late ProviderContainer container;

  const older = Wallet(name: 'Older', createdAt: '2026-08-01T00:00:00.000');
  const newer = Wallet(name: 'Newer', createdAt: '2026-08-03T00:00:00.000');

  setUp(() {
    mockRepo = MockWalletRepository();
    container = ProviderContainer(
      overrides: [walletRepositoryProvider.overrideWith((ref) => mockRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test(
    'with no sortOrder, defaults to desc and calls repo.getAll(desc)',
    () async {
      when(
        () => mockRepo.getAll(sortOrder: SortOrder.desc),
      ).thenAnswer((_) async => [newer, older]);

      final wallets = await container.read(
        walletListViewModelProvider().future,
      );

      expect(wallets.first.name, 'Newer');
      verify(() => mockRepo.getAll(sortOrder: SortOrder.desc)).called(1);
    },
  );

  test(
    'with sortOrder asc, calls repo.getAll(asc) and returns oldest first',
    () async {
      when(
        () => mockRepo.getAll(sortOrder: SortOrder.asc),
      ).thenAnswer((_) async => [older, newer]);

      final wallets = await container.read(
        walletListViewModelProvider(sortOrder: SortOrder.asc).future,
      );

      expect(wallets.first.name, 'Older');
      verify(() => mockRepo.getAll(sortOrder: SortOrder.asc)).called(1);
    },
  );
}
