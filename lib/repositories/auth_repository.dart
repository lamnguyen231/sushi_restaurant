import '../models/app_user.dart';

abstract interface class AuthRepository {
  Stream<AppUser?> watchCurrentUser();

  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? cccd,
  });

  Future<void> signOut();
}
