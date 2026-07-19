import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../repositories/auth_repository.dart';
import '../../repositories/dining_session_repository.dart';
import '../../repositories/firebase_auth_repository.dart';
import '../../repositories/firebase_notification_repository.dart';
import '../../repositories/firestore_dining_session_repository.dart';
import '../../repositories/firestore_order_repository.dart';
import '../../repositories/firestore_product_repository.dart';
import '../../repositories/firestore_reservation_repository.dart';
import '../../repositories/firestore_table_repository.dart';
import '../../repositories/notification_repository.dart';
import '../../repositories/order_repository.dart';
import '../../repositories/product_repository.dart';
import '../../repositories/reservation_repository.dart';
import '../../repositories/table_repository.dart';
import '../../services/firebase_auth_service.dart';
import '../../services/firebase_notification_service.dart';
import '../../services/firestore_dining_session_service.dart';
import '../../services/firestore_order_service.dart';
import '../../services/firestore_product_service.dart';
import '../../services/firestore_reservation_service.dart';
import '../../services/firestore_table_service.dart';
import '../../models/app_user.dart';
import 'local_providers.dart';

part 'firebase_providers.g.dart';

@riverpod
FirebaseAuth firebaseAuth(Ref ref) => FirebaseAuth.instance;

@riverpod
FirebaseFirestore firebaseFirestore(Ref ref) => FirebaseFirestore.instance;

@riverpod
FirebaseMessaging firebaseMessaging(Ref ref) => FirebaseMessaging.instance;

@riverpod
FirebaseAuthService firebaseAuthService(Ref ref) {
  return FirebaseAuthService(auth: ref.watch(firebaseAuthProvider));
}

@riverpod
FirestoreProductService firestoreProductService(Ref ref) {
  return FirestoreProductService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
FirestoreOrderService firestoreOrderService(Ref ref) {
  return FirestoreOrderService(firestore: ref.watch(firebaseFirestoreProvider));
}

@riverpod
FirestoreTableService firestoreTableService(Ref ref) {
  return FirestoreTableService(firestore: ref.watch(firebaseFirestoreProvider));
}

@riverpod
FirestoreDiningSessionService firestoreDiningSessionService(Ref ref) {
  return FirestoreDiningSessionService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
FirestoreReservationService firestoreReservationService(Ref ref) {
  return FirestoreReservationService(
    firestore: ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
FirebaseNotificationService firebaseNotificationService(Ref ref) {
  return FirebaseNotificationService(
    messaging: ref.watch(firebaseMessagingProvider),
  );
}

@riverpod
AuthRepository authRepository(Ref ref) {
  return FirebaseAuthRepository(
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(firebaseFirestoreProvider),
  );
}

@riverpod
Stream<AppUser?> currentUser(Ref ref) {
  return ref.watch(authRepositoryProvider).watchCurrentUser();
}

@riverpod
ProductRepository productRepository(Ref ref) {
  return FirestoreProductRepository(ref.watch(firestoreProductServiceProvider));
}

@riverpod
OrderRepository orderRepository(Ref ref) {
  return FirestoreOrderRepository(
    ref.watch(firestoreOrderServiceProvider),
    ref.watch(localPendingOrderRepositoryProvider),
  );
}

@riverpod
TableRepository tableRepository(Ref ref) {
  return FirestoreTableRepository(ref.watch(firestoreTableServiceProvider));
}

@riverpod
DiningSessionRepository diningSessionRepository(Ref ref) {
  return FirestoreDiningSessionRepository(
    ref.watch(firestoreDiningSessionServiceProvider),
  );
}

@riverpod
ReservationRepository reservationRepository(Ref ref) {
  return FirestoreReservationRepository(
    ref.watch(firestoreReservationServiceProvider),
  );
}

@riverpod
NotificationRepository notificationRepository(Ref ref) {
  return FirebaseNotificationRepository(
    ref.watch(firebaseNotificationServiceProvider),
  );
}

@riverpod
Future<void> initializeNotifications(Ref ref) async {
  final repo = ref.watch(notificationRepositoryProvider);
  try {
    await repo.requestPermission();
    final token = await repo.getDeviceToken();
    // print FCM token for development and debugging
    debugPrint('FCM Token: $token');
  } catch (e) {
    debugPrint('Error initializing notifications: $e');
  }
}

