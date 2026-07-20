import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../core/providers/local_providers.dart';
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
    if (user == null ||
        user.id.trim().isEmpty ||
        user.role != UserRole.staff && user.role != UserRole.manager) {
      throw StateError('Cần đăng nhập nhân viên để mở phiên dùng bữa.');
    }
    final openedByName = user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email;
    final deviceId = await ref
        .read(deviceSessionAssignmentServiceProvider)
        .getOrCreateDeviceId();
    return ref
        .read(diningSessionRepositoryProvider)
        .startSession(
          tableId: table.id,
          openedBy: user.id,
          openedByName: openedByName,
          deviceId: deviceId,
          guestCount: guestCount,
        );
  }

  Future<DiningSession> resumeSession(TableInfo table) async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null ||
        user.id.trim().isEmpty ||
        user.role != UserRole.staff && user.role != UserRole.manager) {
      throw StateError('Cần đăng nhập nhân viên để vào phiên dùng bữa.');
    }

    final session = await ref
        .read(diningSessionRepositoryProvider)
        .watchActiveSession(table.id)
        .first;
    if (session == null) {
      throw StateError('Không tìm thấy phiên đang hoạt động cho bàn này.');
    }
    if (table.activeSessionId != session.id) {
      throw StateError('Phiên đang hoạt động không khớp với trạng thái bàn.');
    }

    return session;
  }

  Future<void> cancelSession(String sessionId) async {
    final user = await ref.read(currentUserProvider.future);
    if (user == null ||
        user.id.trim().isEmpty ||
        user.role != UserRole.manager) {
      throw StateError('Chỉ quản lý được hủy phiên dùng bữa.');
    }

    await ref
        .read(diningSessionRepositoryProvider)
        .cancelSession(sessionId: sessionId, cancelledBy: user.id);
  }
}
