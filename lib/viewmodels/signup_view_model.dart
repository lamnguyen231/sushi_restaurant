import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers/firebase_providers.dart';
import '../models/app_user.dart';

part 'signup_view_model.g.dart';

class SignUpViewModelState {
  const SignUpViewModelState({this.user, this.errorMessage});

  final AppUser? user;
  final String? errorMessage;

  bool get isLoggedIn => user != null;
}

@riverpod
class SignUpViewModel extends _$SignUpViewModel {
  @override
  Future<SignUpViewModelState> build() async {
    return const SignUpViewModelState();
  }

  Future<void> signUp({
    required String email,
    required String password,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? cccd,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authRepositoryProvider).signUpWithEmailAndPassword(
            email: email.trim(),
            password: password,
            fullName: fullName?.trim(),
            phoneNumber: phoneNumber?.trim(),
            address: address?.trim(),
            cccd: cccd?.trim(),
          );
      return SignUpViewModelState(user: user);
    });
  }
}
