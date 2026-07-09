import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreProductService {
  FirestoreProductService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('products');

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Stream toàn bộ sản phẩm (kể cả không available) – dùng cho admin.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchAllProducts() {
    return _col.orderBy('name').snapshots();
  }

  /// Stream chỉ sản phẩm available – dùng cho user/customer.
  Stream<QuerySnapshot<Map<String, dynamic>>> watchProducts() {
    return _col.where('isAvailable', isEqualTo: true).snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getProduct(String productId) {
    return _col.doc(productId).get();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<DocumentReference<Map<String, dynamic>>> addProduct(
    Map<String, dynamic> data,
  ) {
    return _col.add(data);
  }

  Future<void> updateProduct(String productId, Map<String, dynamic> data) {
    return _col.doc(productId).update(data);
  }

  Future<void> deleteProduct(String productId) {
    return _col.doc(productId).delete();
  }
}
