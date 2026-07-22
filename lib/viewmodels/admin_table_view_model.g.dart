// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_table_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AdminTableViewModel)
const adminTableViewModelProvider = AdminTableViewModelProvider._();

final class AdminTableViewModelProvider
    extends $StreamNotifierProvider<AdminTableViewModel, AdminTableState> {
  const AdminTableViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'adminTableViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$adminTableViewModelHash();

  @$internal
  @override
  AdminTableViewModel create() => AdminTableViewModel();
}

String _$adminTableViewModelHash() =>
    r'99fdd7d14b70cd3db111ee4f237ce89fb1d3f945';

abstract class _$AdminTableViewModel extends $StreamNotifier<AdminTableState> {
  Stream<AdminTableState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AdminTableState>, AdminTableState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<AdminTableState>, AdminTableState>,
              AsyncValue<AdminTableState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
