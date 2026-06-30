import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProductService {
  FirestoreProductService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchProducts() {
    return _firestore
        .collection('products')
        .where('isAvailable', isEqualTo: true)
        .snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct(String productId) {
    return _firestore.collection('products').doc(productId).get();
  }
}
