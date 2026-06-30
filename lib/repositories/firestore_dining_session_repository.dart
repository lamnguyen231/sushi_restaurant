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
    int? guestCount,
  }) async {
    final sessionRef = await _sessionService.createSession(
      tableId: tableId,
      openedBy: openedBy,
      guestCount: guestCount,
    );
    return DiningSession(
      id: sessionRef.id,
      tableId: tableId,
      tableName: tableId,
      status: DiningSessionStatus.active,
      guestCount: guestCount,
      openedBy: openedBy,
      startedAt: DateTime.now(),
      paymentStatus: PaymentStatus.unpaid,
      subtotal: 0,
      discount: 0,
      serviceCharge: 0,
      tax: 0,
      grandTotal: 0,
    );
  }

  @override
  Future<void> closeSession(String sessionId) {
    return _sessionService.closeSession(sessionId);
  }

  @override
  Stream<DiningSession?> watchActiveSession(String tableId) {
    return _sessionService.watchActiveSession(tableId).map((snapshot) {
      if (snapshot.docs.isEmpty) return null;
      final doc = snapshot.docs.first;
      final data = doc.data();
      return DiningSession(
        id: doc.id,
        tableId: data['tableId'] as String? ?? tableId,
        tableName: data['tableName'] as String? ?? tableId,
        status: DiningSessionStatus.active,
        guestCount: data['guestCount'] as int?,
        openedBy: data['openedBy'] as String? ?? '',
        startedAt: DateTime.now(),
        paymentStatus: PaymentStatus.unpaid,
        subtotal: (data['subtotal'] as num? ?? 0).toDouble(),
        discount: (data['discount'] as num? ?? 0).toDouble(),
        serviceCharge: (data['serviceCharge'] as num? ?? 0).toDouble(),
        tax: (data['tax'] as num? ?? 0).toDouble(),
        grandTotal: (data['grandTotal'] as num? ?? 0).toDouble(),
      );
    });
  }
}
