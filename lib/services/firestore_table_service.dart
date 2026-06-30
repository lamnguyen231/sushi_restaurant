import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreTableService {
  FirestoreTableService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<QuerySnapshot<Map<String, dynamic>>> watchTables() {
    return _firestore.collection('tables').orderBy('name').snapshots();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getTable(String tableId) {
    return _firestore.collection('tables').doc(tableId).get();
  }
}
