import '../core/enums/app_enums.dart';
import '../models/reservation.dart';

abstract interface class ReservationRepository {
  Future<void> createReservation(Reservation reservation);

  Stream<List<Reservation>> watchReservations();

  Future<void> updateReservationStatus(String reservationId, ReservationStatus status);

  Future<void> assignTable(String reservationId, String? tableId);
}

