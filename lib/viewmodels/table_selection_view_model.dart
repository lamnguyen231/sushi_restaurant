import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers/firebase_providers.dart';
import '../models/dining_session.dart';
import '../models/table_info.dart';

part 'table_selection_view_model.g.dart';

@riverpod
class TableSelectionViewModel extends _$TableSelectionViewModel {
  @override
  Stream<List<TableInfo>> build() {
    return ref.watch(tableRepositoryProvider).watchTables();
  }

  Future<DiningSession> startSession(
    TableInfo table, {
    required int guestCount,
  }) async {
    final user = await ref.read(currentUserProvider.future);
    final openedBy = user?.id ?? 'unknown_staff';
    return ref
        .read(diningSessionRepositoryProvider)
        .startSession(
          tableId: table.id,
          openedBy: openedBy,
          guestCount: guestCount,
        );
  }

  Future<void> closeSession(String sessionId) async {
    await ref.read(diningSessionRepositoryProvider).closeSession(sessionId);
  }
}
