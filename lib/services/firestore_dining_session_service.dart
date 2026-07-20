import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreDiningSessionService {
  FirestoreDiningSessionService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<DocumentSnapshot<Map<String, dynamic>>> createSession({
    required String tableId,
    required String openedBy,
    required String openedByName,
    required String deviceId,
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

      final tableName = tableData['name'] as String? ?? tableId;

      transaction.set(sessionRef, {
        'sessionCode': _sessionCode(
          tableName: tableName,
          sessionId: sessionRef.id,
        ),
        'tableId': tableId,
        'tableName': tableName,
        'status': 'active',
        'guestCount': guestCount,
        'openedBy': openedBy,
        'openedByName': openedByName,
        'deviceId': deviceId,
        'startedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'endedAt': null,
        'closedBy': null,
        'paidAt': null,
        'paidBy': null,
        'paymentMethod': null,
        'paymentStatus': 'unpaid',
        'subtotal': 0,
        'discount': 0,
        'serviceCharge': 0,
        'tax': 0,
        'grandTotal': 0,
        'orderCount': 0,
        'itemCount': 0,
      });

      transaction.update(tableRef, {
        'status': 'occupied',
        'activeSessionId': sessionRef.id,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });

    final snapshot = await sessionRef.get();
    if (!snapshot.exists) {
      throw StateError('Không thể tải phiên dùng bữa vừa tạo.');
    }
    return snapshot;
  }

  String _sessionCode({required String tableName, required String sessionId}) {
    final tableCode = tableName
        .replaceAll(RegExp('[^A-Za-z0-9]'), '')
        .toUpperCase();
    final now = DateTime.now();
    final date =
        '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}';
    final suffix = sessionId.substring(sessionId.length - 4).toUpperCase();
    return '${tableCode.isEmpty ? 'TABLE' : tableCode}-$date-$suffix';
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
      final tableSnapshot = await transaction.get(tableRef);
      final tableData = tableSnapshot.data();

      if (sessionData['status'] != 'active') {
        throw StateError('Phiên này không còn hoạt động.');
      }

      if (sessionData['paymentStatus'] != 'paid') {
        throw StateError('Chỉ có thể đóng phiên sau khi đã thanh toán.');
      }

      if (tableData == null) {
        throw StateError('Không tìm thấy bàn của phiên dùng bữa.');
      }

      if (tableData['status'] != 'occupied' ||
          tableData['activeSessionId'] != sessionId) {
        throw StateError('Bàn không còn trỏ đến phiên dùng bữa này.');
      }

      transaction.update(sessionRef, {
        'status': 'closed',
        'endedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(tableRef, {
        'status': 'available',
        'activeSessionId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> cancelSession({
    required String sessionId,
    required String cancelledBy,
  }) async {
    final sessionRef = _firestore.collection('dining_sessions').doc(sessionId);

    await _firestore.runTransaction((transaction) async {
      final sessionSnapshot = await transaction.get(sessionRef);
      final sessionData = sessionSnapshot.data();

      if (sessionData == null) {
        throw StateError('Không tìm thấy phiên dùng bữa.');
      }

      if (sessionData['status'] != 'active') {
        throw StateError('Phiên này không còn hoạt động.');
      }

      final tableId = sessionData['tableId'] as String?;
      if (tableId == null || tableId.isEmpty) {
        throw StateError('Không tìm thấy bàn của phiên dùng bữa.');
      }

      final tableRef = _firestore.collection('tables').doc(tableId);
      final tableSnapshot = await transaction.get(tableRef);
      final tableData = tableSnapshot.data();

      if (tableData == null) {
        throw StateError('Không tìm thấy bàn của phiên dùng bữa.');
      }

      if (tableData['status'] != 'occupied' ||
          tableData['activeSessionId'] != sessionId) {
        throw StateError('Bàn không còn trỏ đến phiên dùng bữa này.');
      }

      transaction.update(sessionRef, {
        'status': 'cancelled',
        'endedAt': FieldValue.serverTimestamp(),
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': cancelledBy,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      transaction.update(tableRef, {
        'status': 'available',
        'activeSessionId': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Future<void> setPaymentStatus({
    required String sessionId,
    required String status,
    String? paymentMethod,
    String? paidBy,
  }) async {
    final sessionRef = _firestore.collection('dining_sessions').doc(sessionId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(sessionRef);
      final data = snapshot.data();
      if (data == null) {
        throw StateError('Không tìm thấy phiên dùng bữa.');
      }
      if (data['status'] != 'active') {
        throw StateError('Phiên này không còn hoạt động.');
      }
      if (status == 'paid' && (paymentMethod == null || paidBy == null)) {
        throw ArgumentError('Cần chọn phương thức và nhân viên thanh toán.');
      }

      transaction.update(sessionRef, {
        'paymentStatus': status,
        'paymentMethod': status == 'paid' ? paymentMethod : null,
        'paidBy': status == 'paid' ? paidBy : null,
        'paidAt': status == 'paid' ? FieldValue.serverTimestamp() : null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchActiveSession(
    String tableId,
  ) {
    return _firestore
        .collection('dining_sessions')
        .where('tableId', isEqualTo: tableId)
        .where('status', isEqualTo: 'active')
        .limit(1)
        .snapshots();
  }
}
