import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:waldo/features/wallets/models/wallet.dart';
import 'package:waldo/features/wallets/repositories/wallet_repository.dart';

part 'wallet_providers.g.dart';

@riverpod
Future<Wallet?> walletById(Ref ref, int id) async {
  final repo = await ref.watch(walletRepositoryProvider.future);
  return repo.getById(id);
}
