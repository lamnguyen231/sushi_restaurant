import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreReservationService {
  FirestoreReservationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> createReservation(Map<String, dynamic> data) {
    return _firestore.collection('reservations').add(data).then((_) {});
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchReservations() {
    return _firestore
        .collection('reservations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<void> updateReservationStatus(String id, String statusName) async {
    final resRef = _firestore.collection('reservations').doc(id);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(resRef);
      final data = snapshot.data();
      if (data == null) return;

      final assignedTableId = data['assignedTableId'] as String?;

      transaction.update(resRef, {
        'status': statusName,
      });

      // Release table if reservation is completed, cancelled, or noShow
      if (assignedTableId != null &&
          (statusName == 'completed' ||
              statusName == 'cancelled' ||
              statusName == 'noShow')) {
        final tableRef = _firestore.collection('tables').doc(assignedTableId);
        final tableSnapshot = await transaction.get(tableRef);
        final tableData = tableSnapshot.data();
        if (tableData != null && tableData['status'] == 'reserved') {
          transaction.update(tableRef, {
            'status': 'available',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // If status changes to seated, mark table as occupied
      if (assignedTableId != null && statusName == 'seated') {
        final tableRef = _firestore.collection('tables').doc(assignedTableId);
        final tableSnapshot = await transaction.get(tableRef);
        final tableData = tableSnapshot.data();
        if (tableData != null &&
            (tableData['status'] == 'reserved' ||
                tableData['status'] == 'available')) {
          transaction.update(tableRef, {
            'status': 'occupied',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }
    });
  }

  Future<void> assignTable(String reservationId, String? tableId) async {
    final resRef = _firestore.collection('reservations').doc(reservationId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(resRef);
      final data = snapshot.data();
      if (data == null) return;

      final oldTableId = data['assignedTableId'] as String?;
      final currentStatus = data['status'] as String?;

      // Release old table
      if (oldTableId != null && oldTableId != tableId) {
        final oldTableRef = _firestore.collection('tables').doc(oldTableId);
        final oldTableSnapshot = await transaction.get(oldTableRef);
        final oldTableData = oldTableSnapshot.data();
        if (oldTableData != null && oldTableData['status'] == 'reserved') {
          transaction.update(oldTableRef, {
            'status': 'available',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Assign new table
      if (tableId != null) {
        final newTableRef = _firestore.collection('tables').doc(tableId);
        final newTableSnapshot = await transaction.get(newTableRef);
        final newTableData = newTableSnapshot.data();

        transaction.update(resRef, {
          'assignedTableId': tableId,
          'status': currentStatus == 'pending' ? 'confirmed' : currentStatus,
        });

        if (newTableData != null && newTableData['status'] == 'available') {
          transaction.update(newTableRef, {
            'status': 'reserved',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } else {
        transaction.update(resRef, {
          'assignedTableId': null,
        });
      }
    });
  }

}
