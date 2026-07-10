import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreOrderService {
  FirestoreOrderService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchKitchenOrders() {
    return _firestore
        .collection('orders')
        .where('status', whereIn: ['pending', 'accepted', 'preparing'])
        .orderBy('createdAt')
        .snapshots();
  }

  Future<DocumentReference<Map<String, dynamic>>> createOrder(
    Map<String, dynamic> data,
  ) {
    return _firestore.collection('orders').add(data);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchSessionOrders(String sessionId) {
    return _firestore
        .collection('orders')
        .where('sessionId', isEqualTo: sessionId)
        .orderBy('createdAt')
        .snapshots();
  }
}
