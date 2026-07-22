import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/dine_in_order_payload.dart';

class FirestoreOrderService {
  FirestoreOrderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// P3-08: Realtime listener cho màn hình bếp.
  /// Giữ đơn ready trong KDS để bếp có thể chuyển sang served.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchKitchenOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['pending', 'accepted', 'preparing', 'ready'])
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllOrders() {
    return _firestore.collection('orders').snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createOrder(
    Map<String, dynamic> data,
  ) {
    return _firestore.collection('orders').add(data);
  }

  Future<DocumentReference<Map<String, dynamic>>> createDineInOrder({
    required String idempotencyKey,
    required String sessionId,
    required String tableId,
    required Map<String, dynamic> data,
  }) async {
    final orderRef = _firestore.collection('orders').doc(idempotencyKey);
    final sessionRef = _firestore.collection('dining_sessions').doc(sessionId);

    await _firestore.runTransaction((transaction) async {
      final orderSnapshot = await transaction.get(orderRef);
      if (orderSnapshot.exists) {
        if (orderSnapshot.data()?['sessionId'] != sessionId) {
          throw StateError('Mã chống trùng đã được dùng cho phiên khác.');
        }
        return;
      }

      final sessionSnapshot = await transaction.get(sessionRef);
      final sessionData = sessionSnapshot.data();
      if (sessionData == null || sessionData['status'] != 'active') {
        throw StateError('Phiên dùng bữa không còn hoạt động.');
      }
      if (sessionData['tableId'] != tableId) {
        throw StateError('Bàn không khớp với phiên dùng bữa.');
      }

      final payload = DineInOrderPayload.fromItems(
        data['items'] as List<dynamic>? ?? const [],
      );

      transaction.set(orderRef, {
        ...data,
        'items': payload.items,
        'subtotal': payload.subtotal,
        'grandTotal': payload.subtotal,
        'idempotencyKey': idempotencyKey,
        'sessionId': sessionId,
        'tableId': tableId,
        'tableName': sessionData['tableName'] as String? ?? tableId,
        'receivedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(sessionRef, {
        'subtotal': FieldValue.increment(payload.subtotal),
        'grandTotal': FieldValue.increment(payload.subtotal),
        'orderCount': FieldValue.increment(1),
        'itemCount': FieldValue.increment(payload.itemCount),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return orderRef;
  }

  /// P3-11: Realtime listener để hiển thị orders trong session của khách.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchSessionOrders(
    String sessionId,
  ) {
    return _firestore
        .collection('orders')
        .where('sessionId', isEqualTo: sessionId)
        .snapshots();
  }

  /// P3-09: Cập nhật trạng thái đơn hàng từ bếp.
  /// status: pending → accepted → preparing → ready → served
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) {
    return _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
