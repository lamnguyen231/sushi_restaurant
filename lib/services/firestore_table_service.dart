import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTableService {
  FirestoreTableService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _col =>
      _firestore.collection('tables');

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTables() {
    return _col.orderBy('name').snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTable(String tableId) {
    return _col.doc(tableId).get();
  }

  Future<void> addTable({
    required String name,
    required int capacity,
    required String status,
    String? notes,
  }) async {
    await _col.add({
      'name': name,
      'capacity': capacity,
      'status': status,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateTable({
    required String id,
    required String name,
    required int capacity,
    required String status,
    String? notes,
  }) async {
    await _col.doc(id).update({
      'name': name,
      'capacity': capacity,
      'status': status,
      'notes': notes ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteTable(String id) async {
    await _col.doc(id).delete();
  }
}

