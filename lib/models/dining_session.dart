import '../core/enums/app_enums.dart';

class DiningSession {
  const DiningSession({
    required this.id,
    required this.tableId,
    required this.tableName,
    required this.status,
    required this.openedBy,
    required this.startedAt,
    required this.paymentStatus,
    required this.subtotal,
    required this.discount,
    required this.serviceCharge,
    required this.tax,
    required this.grandTotal,
    this.guestCount,
    this.endedAt,
  });

  final String id;
  final String tableId;
  final String tableName;
  final DiningSessionStatus status;
  final int? guestCount;
  final String openedBy;
  final DateTime startedAt;
  final DateTime? endedAt;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double discount;
  final double serviceCharge;
  final double tax;
  final double grandTotal;
}
