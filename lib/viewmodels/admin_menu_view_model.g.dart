// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_menu_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminMenuViewModel)
const adminMenuViewModelProvider = AdminMenuViewModelProvider._();

final class AdminMenuViewModelProvider
    extends $StreamNotifierProvider<AdminMenuViewModel, AdminMenuState> {
  const AdminMenuViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminMenuViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminMenuViewModelHash();

  @$internal
  @override
  AdminMenuViewModel create() => AdminMenuViewModel();
}

String _$adminMenuViewModelHash() =>
    r'8970eba27eb48b1274624ac9ee92b291fa851fd2';

abstract class _$AdminMenuViewModel extends $StreamNotifier<AdminMenuState> {
  Stream<AdminMenuState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AdminMenuState>, AdminMenuState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AdminMenuState>, AdminMenuState>,
              AsyncValue<AdminMenuState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
