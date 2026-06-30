import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreReservationService {
  FirestoreReservationService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Future<void> createReservation(Map<String, dynamic> data) {
    return _firestore.collection('reservations').add(data).then((_) {});
  }
}
