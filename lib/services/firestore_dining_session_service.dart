import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDiningSessionService {
  FirestoreDiningSessionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<DocumentReference<Map<String, dynamic>>> createSession({
    required String tableId,
    required String openedBy,
    required int guestCount,
  }) async {
    final sessionRef = _firestore.collection('dining_sessions').doc();
    final tableRef = _firestore.collection('tables').doc(tableId);

    await _firestore.runTransaction((transaction) async {
      final tableSnapshot = await transaction.get(tableRef);
      final tableData = tableSnapshot.data();
      if (tableData == null || tableData['status'] != 'available') {
        throw StateError('Bàn không còn trống để mở phiên mới.');
      }

      transaction.set(sessionRef, {
        'tableId': tableId,
        'tableName': tableData['name'] as String? ?? tableId,
        'status': 'active',
        'guestCount': guestCount,
        'openedBy': openedBy,
        'startedAt': FieldValue.serverTimestamp(),
        'endedAt': null,
        'paymentStatus': 'unpaid',
        'subtotal': 0,
        'discount': 0,
        'serviceCharge': 0,
        'tax': 0,
        'grandTotal': 0,
      });

      transaction.update(tableRef, {
        'status': 'occupied',
        'activeSessionId': sessionRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    return sessionRef;
  }

  Future<void> closeSession(String sessionId) async {
    final sessionRef = _firestore.collection('dining_sessions').doc(sessionId);

    await _firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);
      final sessionData = sessionSnapshot.data();

      if (sessionData == null) {
        throw StateError('Không tìm thấy phiên dùng bữa.');
      }

      final tableId = sessionData['tableId'] as String;
      final tableRef = _firestore.collection('tables').doc(tableId);

      if (sessionData['status'] != 'active') {
        throw StateError('Phiên này không còn hoạt động');
      }

      transaction.update(sessionRef, {
        'status': 'closed',
        'endedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(tableRef, {
        'status': 'available',
        'activeSessionId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchActiveSession(String tableId) {
    return _firestore
        .collection('dining_sessions')
        .where('tableId', isEqualTo: tableId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots();
  }
}
