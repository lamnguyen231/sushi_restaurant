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

  @override
  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? cccd,
  }) async {
    final updateData = <String, dynamic>{};
    if (fullName != null) updateData['displayName'] = fullName;
    if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
    if (address != null) updateData['address'] = address;
    if (cccd != null) updateData['cccd'] = cccd;

    if (updateData.isNotEmpty) {
      await _firestore.collection('users').doc(uid).set(
        updateData,
        SetOptions(merge: true),
      );
    }
  }

  @override
  Future<AppUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? cccd,
  }) async {
    final credential = await _authService.createUser(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw StateError('Đăng ký Firebase thành công nhưng không có user.');
    }

    final userData = <String, dynamic>{
      'email': email,
      'role': 'customer',
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (fullName != null && fullName.isNotEmpty) {
      userData['displayName'] = fullName;
    }
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      userData['phoneNumber'] = phoneNumber;
    }
    if (address != null && address.isNotEmpty) {
      userData['address'] = address;
    }
    if (cccd != null && cccd.isNotEmpty) {
      userData['cccd'] = cccd;
    }

    await _firestore.collection('users').doc(user.uid).set(userData);

    return _loadAppUser(user.uid, fallbackEmail: user.email ?? email);
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) {
    return _authService.sendPasswordResetEmail(email: email);
  }

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
      phoneNumber: data?['phoneNumber'] as String?,
      address: data?['address'] as String?,
      cccd: data?['cccd'] as String?,
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
