import '../core/enums/app_enums.dart';
import '../models/reservation.dart';
import '../services/firestore_reservation_service.dart';
import 'reservation_repository.dart';

class FirestoreReservationRepository implements ReservationRepository {
  const FirestoreReservationRepository(this._reservationService);

  final FirestoreReservationService _reservationService;

  @override
  Future<void> createReservation(Reservation reservation) {
    return _reservationService.createReservation({
      'customerName': reservation.customerName,
      'phone': reservation.phone,
      'reservationDateTime': reservation.reservationDateTime,
      'guestCount': reservation.guestCount,
      'status': reservation.status.name,
      'note': reservation.note,
      'assignedTableId': reservation.assignedTableId,
      'createdAt': reservation.createdAt,
    });
  }

  @override
  Stream<List<Reservation>> watchReservations() {
    return _reservationService.watchReservations().map(
      (snapshot) => snapshot.docs
          .map((doc) => Reservation.fromFirestore(doc.id, doc.data()))
          .toList(),
    );
  }

  @override
  Future<void> updateReservationStatus(
    String reservationId,
    ReservationStatus status,
  ) {
    return _reservationService.updateReservationStatus(
      reservationId,
      status.name,
    );
  }

  @override
  Future<void> assignTable(String reservationId, String? tableId) {
    return _reservationService.assignTable(reservationId, tableId);
  }
}

