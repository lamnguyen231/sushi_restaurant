import 'dart:convert';
import 'dart:math';

import 'package:shared_preferences/shared_preferences.dart';

import '../core/enums/app_enums.dart';
import '../models/dining_session.dart';

class DeviceSessionAssignmentService {
  static const _deviceIdKey = 'dining_device_id';
  static const _sessionKey = 'active_dining_session_assignment';

  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_deviceIdKey);
    if (existing != null && existing.isNotEmpty) return existing;

    final deviceId = _generateDeviceId();
    await prefs.setString(_deviceIdKey, deviceId);
    return deviceId;
  }

  Future<void> saveActiveSession(DiningSession session) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceId = await getOrCreateDeviceId();
    await prefs.setString(
      _sessionKey,
      jsonEncode({
        'deviceId': deviceId,
        'sessionId': session.id,
        'sessionCode': session.sessionCode,
        'tableId': session.tableId,
        'tableName': session.tableName,
        'openedBy': session.openedBy,
        'openedByName': session.openedByName,
        'guestCount': session.guestCount,
        'startedAt': session.startedAt.toIso8601String(),
        'createdAt': session.createdAt.toIso8601String(),
        'updatedAt': session.updatedAt.toIso8601String(),
        'paymentStatus': session.paymentStatus.name,
        'paymentMethod': session.paymentMethod?.name,
        'paidBy': session.paidBy,
        'subtotal': session.subtotal,
        'discount': session.discount,
        'serviceCharge': session.serviceCharge,
        'tax': session.tax,
        'grandTotal': session.grandTotal,
        'orderCount': session.orderCount,
        'itemCount': session.itemCount,
      }),
    );
  }

  Future<DiningSession?> loadActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null || raw.isEmpty) return null;

    final data = jsonDecode(raw) as Map<String, dynamic>;
    final sessionId = data['sessionId'] as String;
    final startedAt = DateTime.parse(data['startedAt'] as String);
    return DiningSession(
      id: sessionId,
      sessionCode:
          data['sessionCode'] as String? ??
          sessionId
              .substring(0, sessionId.length < 8 ? sessionId.length : 8)
              .toUpperCase(),
      tableId: data['tableId'] as String,
      tableName: data['tableName'] as String,
      status: DiningSessionStatus.active,
      openedBy: data['openedBy'] as String? ?? 'unknown_staff',
      openedByName: data['openedByName'] as String?,
      deviceId: data['deviceId'] as String?,
      startedAt: startedAt,
      createdAt: data['createdAt'] == null
          ? startedAt
          : DateTime.parse(data['createdAt'] as String),
      updatedAt: data['updatedAt'] == null
          ? startedAt
          : DateTime.parse(data['updatedAt'] as String),
      paymentStatus: PaymentStatus.values.firstWhere(
        (status) => status.name == data['paymentStatus'],
        orElse: () => PaymentStatus.unpaid,
      ),
      paymentMethod: _paymentMethod(data['paymentMethod']),
      paidBy: data['paidBy'] as String?,
      subtotal: (data['subtotal'] as num? ?? 0).toDouble(),
      discount: (data['discount'] as num? ?? 0).toDouble(),
      serviceCharge: (data['serviceCharge'] as num? ?? 0).toDouble(),
      tax: (data['tax'] as num? ?? 0).toDouble(),
      grandTotal: (data['grandTotal'] as num? ?? 0).toDouble(),
      orderCount: (data['orderCount'] as num? ?? 0).toInt(),
      itemCount: (data['itemCount'] as num? ?? 0).toInt(),
      guestCount: data['guestCount'] as int?,
    );
  }

  Future<void> clearActiveSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  String _generateDeviceId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  DiningPaymentMethod? _paymentMethod(Object? value) {
    if (value is! String) return null;
    for (final method in DiningPaymentMethod.values) {
      if (method.name == value) return method;
    }
    return null;
  }
}
