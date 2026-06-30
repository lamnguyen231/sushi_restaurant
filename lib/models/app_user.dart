import '../core/enums/app_enums.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.role,
    this.displayName,
  });

  final String id;
  final String email;
  final String? displayName;
  final UserRole role;
}
