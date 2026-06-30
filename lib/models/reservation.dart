import '../core/enums/app_enums.dart';

class Reservation {
  const Reservation({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.reservationDateTime,
    required this.guestCount,
    required this.status,
    required this.createdAt,
    this.note,
    this.assignedTableId,
  });

  final String id;
  final String customerName;
  final String phone;
  final DateTime reservationDateTime;
  final int guestCount;
  final ReservationStatus status;
  final String? note;
  final String? assignedTableId;
  final DateTime createdAt;
}
