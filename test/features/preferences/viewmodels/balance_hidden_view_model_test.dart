import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:waldo/features/preferences/viewmodels/balance_hidden_view_model.dart';

void main() {
  test('Hiding amounts holds while no screen is watching', () async {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    container.read(balanceHiddenProvider.notifier).toggle();
    // An auto-dispose provider would be gone, and reset, after this.
    await container.pump();

    expect(container.read(balanceHiddenProvider), isTrue);
  });
}
