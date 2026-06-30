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
    // TODO: Add Firestore reservation listener when manager screen is implemented.
    return const Stream.empty();
  }
}
