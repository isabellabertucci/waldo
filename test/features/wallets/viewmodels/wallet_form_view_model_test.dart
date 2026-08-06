import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_state.dart';
import 'package:waldo/features/wallets/viewmodels/wallet_form_view_model.dart';

class MockWalletRepository extends Mock implements IWalletRepository {}

void main() {
  late MockWalletRepository mockRepo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(
      const Wallet(name: '', createdAt: '2026-08-04T12:00:00.000'),
    );
  });

  setUp(() {
    mockRepo = MockWalletRepository();
    container = ProviderContainer(
      overrides: [walletRepositoryProvider.overrideWith((ref) => mockRepo)],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build(null) starts empty with the default type', () {
    final state = container.read(walletFormViewModelProvider(null));

    expect(state.name, '');
    expect(state.type, WalletType.cash);
  });

  test('empty name fails and never calls the repository', () async {
    final notifier = container.read(walletFormViewModelProvider(null).notifier);

    final success = await notifier.save(null);

    expect(success, isFalse);
    verifyNever(() => mockRepo.insert(any()));
  });

  test('valid name calls insert', () async {
    when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);

    final notifier = container.read(walletFormViewModelProvider(null).notifier);
    notifier.updateName('Cash');

    final success = await notifier.save(null);

    expect(success, isTrue);
    verify(() => mockRepo.insert(any())).called(1);
  });

  test('invalid balance fails with invalidNumber', () async {
    final notifier = container.read(walletFormViewModelProvider(null).notifier);
    notifier.updateName('Cash');
    notifier.updateBalance('abc');

    final success = await notifier.save(null);

    expect(success, isFalse);
    final state = container.read(walletFormViewModelProvider(null));
    expect(state.balanceError, WalletFormError.invalidNumber);
  });

  test('editing calls update, not insert', () async {
    const existing = Wallet(
      id: 5,
      name: 'Old name',
      createdAt: '2026-08-04T12:00:00.000',
    );
    when(() => mockRepo.update(any())).thenAnswer((_) async {});

    final notifier = container.read(
      walletFormViewModelProvider(existing).notifier,
    );

    final success = await notifier.save(existing);

    expect(success, isTrue);
    verify(() => mockRepo.update(any())).called(1);
    verifyNever(() => mockRepo.insert(any()));
  });
}
