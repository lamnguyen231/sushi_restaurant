class LoginViewModelState {
  const LoginViewModelState({
    this.isLoading = false,
    this.errorMessage,
  });

  final bool isLoading;
  final String? errorMessage;
}

class LoginViewModel {
  const LoginViewModel();

  // TODO: Inject AuthRepository and implement Firebase Auth login/logout.
}
