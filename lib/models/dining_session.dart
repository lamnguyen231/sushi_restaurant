import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/enums/app_enums.dart';

class DiningSession {
  const DiningSession({
    required this.id,
    required this.sessionCode,
    required this.tableId,
    required this.tableName,
    required this.status,
    required this.openedBy,
    required this.startedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.paymentStatus,
    required this.subtotal,
    required this.discount,
    required this.serviceCharge,
    required this.tax,
    required this.grandTotal,
    required this.orderCount,
    required this.itemCount,
    this.openedByName,
    this.deviceId,
    this.closedBy,
    this.paidAt,
    this.paidBy,
    this.paymentMethod,
    this.guestCount,
    this.endedAt,
  });

  final String id;
  final String sessionCode;
  final String tableId;
  final String tableName;
  final DiningSessionStatus status;
  final int? guestCount;
  final String openedBy;
  final String? openedByName;
  final String? deviceId;
  final DateTime startedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? endedAt;
  final String? closedBy;
  final DateTime? paidAt;
  final String? paidBy;
  final DiningPaymentMethod? paymentMethod;
  final PaymentStatus paymentStatus;
  final double subtotal;
  final double discount;
  final double serviceCharge;
  final double tax;
  final double grandTotal;
  final int orderCount;
  final int itemCount;

  factory DiningSession.fromFirestoreData({
    required String id,
    required Map<String, dynamic> data,
    String? fallbackTableId,
  }) {
    final tableId = data['tableId'] as String? ?? fallbackTableId ?? '';
    final startedAt =
        _dateTime(data['startedAt']) ??
        _dateTime(data['createdAt']) ??
        DateTime.now();

    return DiningSession(
      id: id,
      sessionCode:
          data['sessionCode'] as String? ??
          id.substring(0, id.length < 8 ? id.length : 8).toUpperCase(),
      tableId: tableId,
      tableName: data['tableName'] as String? ?? tableId,
      status: DiningSessionStatus.values.firstWhere(
        (status) => status.name == data['status'],
        orElse: () => DiningSessionStatus.active,
      ),
      guestCount: (data['guestCount'] as num?)?.toInt(),
      openedBy: data['openedBy'] as String? ?? '',
      openedByName: data['openedByName'] as String?,
      deviceId: data['deviceId'] as String?,
      startedAt: startedAt,
      createdAt: _dateTime(data['createdAt']) ?? startedAt,
      updatedAt: _dateTime(data['updatedAt']) ?? startedAt,
      endedAt: _dateTime(data['endedAt']),
      closedBy: data['closedBy'] as String?,
      paidAt: _dateTime(data['paidAt']),
      paidBy: data['paidBy'] as String?,
      paymentMethod: _paymentMethod(data['paymentMethod']),
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.name == data['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
      subtotal: (data['subtotal'] as num? ?? 0).toDouble(),
      discount: (data['discount'] as num? ?? 0).toDouble(),
      serviceCharge: (data['serviceCharge'] as num? ?? 0).toDouble(),
      tax: (data['tax'] as num? ?? 0).toDouble(),
      grandTotal: (data['grandTotal'] as num? ?? 0).toDouble(),
      orderCount: (data['orderCount'] as num? ?? 0).toInt(),
      itemCount: (data['itemCount'] as num? ?? 0).toInt(),
    );
  }

  static DateTime? _dateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  static DiningPaymentMethod? _paymentMethod(Object? value) {
    if (value is! String) return null;
    for (final method in DiningPaymentMethod.values) {
      if (method.name == value) return method;
    }
    return null;
  }
}
