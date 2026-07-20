import '../core/enums/app_enums.dart';
import '../models/dining_session.dart';
import '../services/firestore_dining_session_service.dart';
import 'dining_session_repository.dart';

class FirestoreDiningSessionRepository implements DiningSessionRepository {
  const FirestoreDiningSessionRepository(this._sessionService);

  final FirestoreDiningSessionService _sessionService;

  @override
  Future<DiningSession> startSession({
    required String tableId,
    required String openedBy,
    required String openedByName,
    required String deviceId,
    required int guestCount,
  }) async {
    final snapshot = await _sessionService.createSession(
      tableId: tableId,
      openedBy: openedBy,
      openedByName: openedByName,
      deviceId: deviceId,
      guestCount: guestCount,
    );
    return DiningSession.fromFirestoreData(
      id: snapshot.id,
      data: snapshot.data() ?? const <String, dynamic>{},
      fallbackTableId: tableId,
    );
  }

  @override
  Future<void> closeSession(String sessionId) {
    return _sessionService.closeSession(sessionId);
  }

  @override
  Future<void> cancelSession({
    required String sessionId,
    required String cancelledBy,
  }) {
    return _sessionService.cancelSession(
      sessionId: sessionId,
      cancelledBy: cancelledBy,
    );
  }

  @override
  Future<void> setPaymentStatus({
    required String sessionId,
    required PaymentStatus status,
    DiningPaymentMethod? method,
    String? paidBy,
  }) {
    return _sessionService.setPaymentStatus(
      sessionId: sessionId,
      status: status.name,
      paymentMethod: method?.name,
      paidBy: paidBy,
    );
  }

  @override
  Stream<DiningSession?> watchActiveSession(String tableId) {
    return _sessionService.watchActiveSession(tableId).map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      return DiningSession.fromFirestoreData(
        id: doc.id,
        data: doc.data(),
        fallbackTableId: tableId,
      );
    });
  }
}
