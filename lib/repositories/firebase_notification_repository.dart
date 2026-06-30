import '../services/firebase_notification_service.dart';
import 'notification_repository.dart';

class FirebaseNotificationRepository implements NotificationRepository {
  const FirebaseNotificationRepository(this._notificationService);

  final FirebaseNotificationService _notificationService;

  @override
  Future<void> requestPermission() async {
    await _notificationService.requestPermission();
  }

  @override
  Future<String?> getDeviceToken() {
    return _notificationService.getToken();
  }
}
