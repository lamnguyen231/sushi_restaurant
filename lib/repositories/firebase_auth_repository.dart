import '../core/enums/app_enums.dart';
import '../models/app_user.dart';
import '../services/firebase_auth_service.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository(this._authService);

  final FirebaseAuthService _authService;

  @override
  Stream<AppUser?> watchCurrentUser() {
    return _authService.authStateChanges().map((user) {
      if (user == null) return null;
      return AppUser(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
        // TODO: Load the real role from users/{uid} or custom claims.
        role: UserRole.staff,
      );
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
    return AppUser(
      id: user.uid,
      email: user.email ?? email,
      displayName: user.displayName,
      role: UserRole.staff,
    );
  }

  @override
  Future<void> signOut() => _authService.signOut();
}
