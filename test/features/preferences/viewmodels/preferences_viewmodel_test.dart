import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:waldo/core/constants/enums.dart';
import 'package:waldo/features/preferences/models/preferences.dart';
import 'package:waldo/features/preferences/repositories/preferences_repository.dart';
import 'package:waldo/features/preferences/viewmodels/preferences_viewmodel.dart';

class MockPreferencesRepository extends Mock
    implements IPreferencesRepository {}

void main() {
  late MockPreferencesRepository mockRepo;
  late ProviderContainer container;

  setUp(() {
    mockRepo = MockPreferencesRepository();
    container = ProviderContainer(
      overrides: [
        preferencesRepositoryProvider.overrideWith((ref) async => mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  test('build reads preferences from the repository', () async {
    when(
      () => mockRepo.getPreferences(),
    ).thenAnswer((_) async => const Preferences(currency: Currency.eur));

    final preferences = await container.read(
      preferencesViewModelProvider.future,
    );

    expect(preferences.currency, Currency.eur);
  });

  test('setCurrency calls the repository and invalidates', () async {
    when(
      () => mockRepo.getPreferences(),
    ).thenAnswer((_) async => const Preferences());
    when(() => mockRepo.setCurrency(Currency.gbp)).thenAnswer((_) async {});

    await container.read(preferencesViewModelProvider.future);
    final notifier = container.read(preferencesViewModelProvider.notifier);

    await notifier.setCurrency(Currency.gbp);

    verify(() => mockRepo.setCurrency(Currency.gbp)).called(1);
  });

  test('setDarkMode(true) calls the repository with true', () async {
    when(
      () => mockRepo.getPreferences(),
    ).thenAnswer((_) async => const Preferences());
    when(() => mockRepo.setDarkMode(true)).thenAnswer((_) async {});

    await container.read(preferencesViewModelProvider.future);
    final notifier = container.read(preferencesViewModelProvider.notifier);

    await notifier.setDarkMode(true);

    verify(() => mockRepo.setDarkMode(true)).called(1);
  });

  test('setDarkMode(null) calls the repository with null', () async {
    when(
      () => mockRepo.getPreferences(),
    ).thenAnswer((_) async => const Preferences());
    when(() => mockRepo.setDarkMode(null)).thenAnswer((_) async {});

    await container.read(preferencesViewModelProvider.future);
    final notifier = container.read(preferencesViewModelProvider.notifier);

    await notifier.setDarkMode(null);

    verify(() => mockRepo.setDarkMode(null)).called(1);
  });

  test('setDateFormat calls the repository and invalidates', () async {
    when(
      () => mockRepo.getPreferences(),
    ).thenAnswer((_) async => const Preferences());
    when(() => mockRepo.setDateFormat('dd/MM/yyyy')).thenAnswer((_) async {});

    await container.read(preferencesViewModelProvider.future);
    final notifier = container.read(preferencesViewModelProvider.notifier);

    await notifier.setDateFormat('dd/MM/yyyy');

    verify(() => mockRepo.setDateFormat('dd/MM/yyyy')).called(1);
  });
}
