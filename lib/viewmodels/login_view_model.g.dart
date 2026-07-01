// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LoginViewModel)
const loginViewModelProvider = LoginViewModelProvider._();

final class LoginViewModelProvider
    extends $AsyncNotifierProvider<LoginViewModel, LoginViewModelState> {
  const LoginViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'loginViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$loginViewModelHash();

  @$internal
  @override
  LoginViewModel create() => LoginViewModel();
}

String _$loginViewModelHash() => r'8540ac82b612632555222665e591e874bdfc5472';

abstract class _$LoginViewModel extends $AsyncNotifier<LoginViewModelState> {
  FutureOr<LoginViewModelState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<LoginViewModelState>, LoginViewModelState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LoginViewModelState>, LoginViewModelState>,
              AsyncValue<LoginViewModelState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
