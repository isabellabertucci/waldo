import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pending_category_deletes.g.dart';

/// Categories deleted but still inside their Undo window. Every screen
/// already shows their transactions in "Others", where the delete moves them.
@Riverpod(keepAlive: true)
class PendingCategoryDeletes extends _$PendingCategoryDeletes {
  @override
  Set<int> build() => const {};

  void add(int id) => state = {...state, id};

  void remove(int id) => state = {...state}..remove(id);
}
