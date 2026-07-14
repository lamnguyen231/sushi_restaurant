import '../models/pending_order.dart';
import '../services/sqlite_pending_order_service.dart';

class LocalPendingOrderRepository {
  const LocalPendingOrderRepository(this._service);

  final SqlitePendingOrderService _service;

  Future<void> saveOrder(PendingOrder order) => _service.insertPendingOrder(order);

  Future<List<PendingOrder>> getOrders({String? sessionId}) => _service.getPendingOrders(sessionId: sessionId);

  Future<void> updateStatus({
    required String localId,
    required String status,
    String? remoteOrderId,
    String? lastError,
    int? retryCount,
    int? syncedAt,
  }) =>
      _service.updatePendingOrderStatus(
        localId: localId,
        status: status,
        remoteOrderId: remoteOrderId,
        lastError: lastError,
        retryCount: retryCount,
        syncedAt: syncedAt,
      );

  Future<void> deleteOrder(String localId) => _service.deletePendingOrder(localId);

  Future<void> clearSynced(String sessionId) => _service.clearSyncedOrders(sessionId);
}
