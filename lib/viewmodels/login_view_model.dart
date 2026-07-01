import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers/firebase_providers.dart';
import '../models/app_user.dart';

part 'login_view_model.g.dart';

class LoginViewModelState {
  const LoginViewModelState({this.user, this.errorMessage});

  final AppUser? user;
  final String? errorMessage;

  bool get isLoggedIn => user != null;
}

@riverpod
class LoginViewModel extends _$LoginViewModel {
  @override
  Future<LoginViewModelState> build() async {
    final user = await ref.watch(currentUserProvider.future);
    return LoginViewModelState(user: user);
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref
          .read(authRepositoryProvider)
          .signInWithEmailAndPassword(email: email.trim(), password: password);
      return LoginViewModelState(user: user);
    });
  }

  Future<void> signOut() async {
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(LoginViewModelState());
  }
}
