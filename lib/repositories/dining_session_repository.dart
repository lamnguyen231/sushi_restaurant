import '../core/enums/app_enums.dart';
import '../models/dining_session.dart';

abstract interface class DiningSessionRepository {
  Future<DiningSession> startSession({
    required String tableId,
    required String openedBy,
    required String openedByName,
    required String deviceId,
    required int guestCount,
  });

  Future<void> closeSession(String sessionId);

  Future<void> cancelSession({
    required String sessionId,
    required String cancelledBy,
  });

  Future<void> setPaymentStatus({
    required String sessionId,
    required PaymentStatus status,
    DiningPaymentMethod? method,
    String? paidBy,
  });

  Stream<DiningSession?> watchActiveSession(String tableId);
}
