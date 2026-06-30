abstract interface class NotificationRepository {
  Future<void> requestPermission();

  Future<String?> getDeviceToken();
}
