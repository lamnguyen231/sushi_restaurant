import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/enums/app_enums.dart';
import '../models/app_user.dart';
import '../services/firebase_auth_service.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(this._authService, this._firestore);

  final FirebaseAuthService _authService;
  final FirebaseFirestore _firestore;

  @override
  Stream<AppUser?> watchCurrentUser() {
    return _authService.authStateChanges().asyncMap((user) {
      if (user == null) return null;
      return _loadAppUser(user.uid, fallbackEmail: user.email ?? '');
    });
  }

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final credential = await _authService.signIn(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Đăng nhập Firebase thành công nhưng không có user.');
    }
    return _loadAppUser(user.uid, fallbackEmail: user.email ?? email);
  }

  @override
  Future<void> signOut() => _authService.signOut();

  Future<AppUser> _loadAppUser(
    String uid, {
    required String fallbackEmail,
  }) async {
    final snapshot = await _firestore.collection('users').doc(uid).get();
    final data = snapshot.data();

    return AppUser(
      id: uid,
      email: data?['email'] as String? ?? fallbackEmail,
      displayName: data?['displayName'] as String?,
      role: _roleFromFirestore(data?['role'] as String?),
    );
  }

  UserRole _roleFromFirestore(String? value) {
    return switch (value?.trim().toLowerCase()) {
      'manager' => UserRole.manager,
      'staff' => UserRole.staff,
      'kitchen' => UserRole.kitchen,
      'customer' || 'user' => UserRole.customer,
      _ => UserRole.customer,
    };
  }
}
