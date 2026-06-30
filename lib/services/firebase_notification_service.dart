import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseNotificationService {
  FirebaseNotificationService({FirebaseMessaging? messaging})
    : _messaging = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _messaging;

  Future<NotificationSettings> requestPermission() {
    return _messaging.requestPermission();
  }

  Future<String?> getToken() => _messaging.getToken();
}
