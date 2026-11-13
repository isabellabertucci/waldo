import 'package:logging/logging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/core/constants/enums.dart';
import '../models/preferences.dart';
import '../repositories/preferences_repository.dart';

part 'preferences_viewmodel.g.dart';

final _log = Logger('waldo.vm.preferences');

@riverpod
class PreferencesViewModel extends _$PreferencesViewModel {
  @override
  Future<Preferences> build() async {
    final repo = await ref.watch(preferencesRepositoryProvider.future);
    return repo.getPreferences();
  }

  Future<void> setCurrency(Currency currency) async {
    final repo = await ref.read(preferencesRepositoryProvider.future);
    await repo.setCurrency(currency);
    _log.info('setCurrency succeeded: currency=$currency');
    ref.invalidateSelf();
  }

  Future<void> setDarkMode(bool? isDarkMode) async {
    final repo = await ref.read(preferencesRepositoryProvider.future);
    await repo.setDarkMode(isDarkMode);
    _log.info('setDarkMode succeeded: isDarkMode=$isDarkMode');
    ref.invalidateSelf();
  }

  Future<void> setDateFormat(String format) async {
    final repo = await ref.read(preferencesRepositoryProvider.future);
    await repo.setDateFormat(format);
    _log.info('setDateFormat succeeded: format=$format');
    ref.invalidateSelf();
  }

  /// Saves the eye toggle. Updates the loaded preferences in place, so
  /// [balanceHiddenProvider] never sees the old value during a reload.
  Future<void> setBalanceHidden(bool isHidden) async {
    final repo = await ref.read(preferencesRepositoryProvider.future);
    await repo.setBalanceHidden(isHidden);
    _log.info('setBalanceHidden succeeded: isHidden=$isHidden');
    final current = state.value;
    if (current == null) {
      ref.invalidateSelf();
    } else {
      state = AsyncData(current.copyWith(isBalanceHidden: isHidden));
    }
  }
}
