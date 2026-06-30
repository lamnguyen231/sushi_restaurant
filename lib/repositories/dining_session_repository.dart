import '../models/dining_session.dart';

abstract interface class DiningSessionRepository {
  Future<DiningSession> startSession({
    required String tableId,
    required String openedBy,
    int? guestCount,
  });

  Future<void> closeSession(String sessionId);

  Stream<DiningSession?> watchActiveSession(String tableId);
}
