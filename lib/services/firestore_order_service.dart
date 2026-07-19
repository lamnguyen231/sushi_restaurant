import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreOrderService {
  FirestoreOrderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  /// P3-08: Realtime listener cho màn hình bếp.
  /// Lắng nghe orders có status pending/accepted/preparing, sắp xếp theo thời gian.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchKitchenOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['pending', 'accepted', 'preparing'])
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createOrder(
    Map<String, dynamic> data,
  ) {
    return _firestore.collection('orders').add(data);
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
