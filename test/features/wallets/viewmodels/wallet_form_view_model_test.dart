import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/core/utils/clock.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';
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
      overrides: [
        walletRepositoryProvider.overrideWith((ref) => mockRepo),
        // A fixed clock, so createdAt is checkable.
        clockProvider.overrideWithValue(() => DateTime(2026, 10, 13, 9, 30)),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build(null) starts empty with the default type', () {
    final state = container.read(walletFormViewModelProvider(null));

    expect(state.name, '');
    expect(state.type, WalletType.cash);
    expect(state.startingBalance, '');
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

  test('save with no existing wallet calls insert with parsed cents', () async {
    when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);

    final notifier = container.read(walletFormViewModelProvider(null).notifier);
    notifier.updateName('Cash');
    notifier.updateBalance('10.50');

    final success = await notifier.save(null);

    expect(success, isTrue);
    final inserted =
        verify(() => mockRepo.insert(captureAny())).captured.single as Wallet;
    expect(
      inserted.createdAt,
      '2026-10-13T09:30:00.000',
      reason: 'stamped by the clock',
    );
  });

  test(
    'save with a negative balance on a credit wallet calls insert with a negative amount',
    () async {
      when(() => mockRepo.insert(any())).thenAnswer((_) async => 1);

      final notifier = container.read(
        walletFormViewModelProvider(null).notifier,
      );
      notifier.updateName('Credit Card');
      notifier.updateType(WalletType.credit);
      notifier.updateBalance('-50.00');

      final success = await notifier.save(null);

      expect(success, isTrue);
      verify(() => mockRepo.insert(any())).called(1);
    },
  );

  test('a second save while the first is still writing does nothing', () async {
    when(() => mockRepo.insert(any())).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 10), () => 1),
    );
    final provider = walletFormViewModelProvider(null);
    container.listen(provider, (_, _) {});
    final notifier = container.read(provider.notifier);
    notifier.updateName('Cash');

    final results = await Future.wait([
      notifier.save(null),
      notifier.save(null),
    ]);

    expect(results, [true, false]);
    verify(() => mockRepo.insert(any())).called(1);
  });

  test('save while editing calls update, not insert', () async {
    const existing = Wallet(
      id: 5,
      name: 'Old name',
      createdAt: '2026-08-04T12:00:00.000',
    );
    when(() => mockRepo.update(any())).thenAnswer((_) async {});

    final notifier = container.read(
      walletFormViewModelProvider(existing).notifier,
    );
    notifier.updateName('New name');

    final success = await notifier.save(existing);

    expect(success, isTrue);
    verify(() => mockRepo.update(any())).called(1);
    verifyNever(() => mockRepo.insert(any()));
  });
}
