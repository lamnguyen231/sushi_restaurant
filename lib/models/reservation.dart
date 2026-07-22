import 'package:cloud_firestore/cloud_firestore.dart';
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

  Reservation copyWith({
    String? id,
    String? customerName,
    String? phone,
    DateTime? reservationDateTime,
    int? guestCount,
    ReservationStatus? status,
    String? note,
    String? assignedTableId,
    DateTime? createdAt,
  }) {
    return Reservation(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      reservationDateTime: reservationDateTime ?? this.reservationDateTime,
      guestCount: guestCount ?? this.guestCount,
      status: status ?? this.status,
      note: note ?? this.note,
      assignedTableId: assignedTableId ?? this.assignedTableId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Reservation.fromFirestore(String id, Map<String, dynamic> data) {
    return Reservation(
      id: id,
      customerName: data['customerName'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      reservationDateTime: data['reservationDateTime'] is Timestamp
          ? (data['reservationDateTime'] as Timestamp).toDate()
          : DateTime.tryParse(data['reservationDateTime'] as String? ?? '') ?? DateTime.now(),
      guestCount: data['guestCount'] as int? ?? 1,
      status: _status(data['status'] as String?),
      note: data['note'] as String?,
      assignedTableId: data['assignedTableId'] as String?,
      createdAt: data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(data['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }

  static ReservationStatus _status(String? value) {
    return ReservationStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => ReservationStatus.pending,
    );
  }
}

