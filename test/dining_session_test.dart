import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sushi_restaurant/core/enums/app_enums.dart';
import 'package:sushi_restaurant/models/dining_session.dart';

void main() {
  test('maps the authoritative dining session snapshot', () {
    final startedAt = DateTime.utc(2026, 7, 20, 8);
    final updatedAt = DateTime.utc(2026, 7, 20, 9);

    final session = DiningSession.fromFirestoreData(
      id: 'session-document-id',
      data: {
        'sessionCode': 'BAN1-20260720-ABCD',
        'tableId': 'table_1',
        'tableName': 'Bàn 1',
        'status': 'active',
        'guestCount': 3,
        'openedBy': 'staff_1',
        'openedByName': 'Nguyen Van A',
        'deviceId': 'device_1',
        'startedAt': Timestamp.fromDate(startedAt),
        'createdAt': Timestamp.fromDate(startedAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
        'paymentStatus': 'paid',
        'paymentMethod': 'qr',
        'paidBy': 'staff_1',
        'paidAt': Timestamp.fromDate(updatedAt),
        'subtotal': 120000,
        'discount': 10000,
        'serviceCharge': 5000,
        'tax': 10000,
        'grandTotal': 125000,
        'orderCount': 2,
        'itemCount': 5,
      },
    );

    expect(session.id, 'session-document-id');
    expect(session.sessionCode, 'BAN1-20260720-ABCD');
    expect(session.tableName, 'Bàn 1');
    expect(session.openedByName, 'Nguyen Van A');
    expect(session.deviceId, 'device_1');
    expect(session.startedAt.isAtSameMomentAs(startedAt), isTrue);
    expect(session.updatedAt.isAtSameMomentAs(updatedAt), isTrue);
    expect(session.paymentStatus, PaymentStatus.paid);
    expect(session.paymentMethod, DiningPaymentMethod.qr);
    expect(session.paidBy, 'staff_1');
    expect(session.paidAt?.isAtSameMomentAs(updatedAt), isTrue);
    expect(session.orderCount, 2);
    expect(session.itemCount, 5);
    expect(session.grandTotal, 125000);
  });

  test('uses stable defaults for a legacy dining session snapshot', () {
    final startedAt = DateTime.utc(2026, 1, 1);

    final session = DiningSession.fromFirestoreData(
      id: 'abcdefghijk',
      fallbackTableId: 'table_legacy',
      data: {'startedAt': Timestamp.fromDate(startedAt)},
    );

    expect(session.sessionCode, 'ABCDEFGH');
    expect(session.tableId, 'table_legacy');
    expect(session.tableName, 'table_legacy');
    expect(session.createdAt.isAtSameMomentAs(startedAt), isTrue);
    expect(session.updatedAt.isAtSameMomentAs(startedAt), isTrue);
    expect(session.status, DiningSessionStatus.active);
    expect(session.paymentStatus, PaymentStatus.unpaid);
    expect(session.paymentMethod, isNull);
    expect(session.orderCount, 0);
    expect(session.itemCount, 0);
    expect(session.grandTotal, 0);
  });
}
