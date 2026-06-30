import '../models/reservation.dart';

abstract interface class ReservationRepository {
  Future<void> createReservation(Reservation reservation);

  Stream<List<Reservation>> watchReservations();
}
