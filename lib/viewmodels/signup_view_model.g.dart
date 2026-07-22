// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'signup_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SignUpViewModel)
const signUpViewModelProvider = SignUpViewModelProvider._();

final class SignUpViewModelProvider
    extends $AsyncNotifierProvider<SignUpViewModel, SignUpViewModelState> {
  const SignUpViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'signUpViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$signUpViewModelHash();

  @$internal
  @override
  SignUpViewModel create() => SignUpViewModel();
}

String _$signUpViewModelHash() => r'42eab81fcea8d5f94b1ecb66f9bf85c6204ce513';

abstract class _$SignUpViewModel extends $AsyncNotifier<SignUpViewModelState> {
  FutureOr<SignUpViewModelState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<SignUpViewModelState>, SignUpViewModelState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<SignUpViewModelState>,
                SignUpViewModelState
              >,
              AsyncValue<SignUpViewModelState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
