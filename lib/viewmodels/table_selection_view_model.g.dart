// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'table_selection_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TableSelectionViewModel)
const tableSelectionViewModelProvider = TableSelectionViewModelProvider._();

final class TableSelectionViewModelProvider
    extends $StreamNotifierProvider<TableSelectionViewModel, List<TableInfo>> {
  const TableSelectionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'tableSelectionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$tableSelectionViewModelHash();

  @$internal
  @override
  TableSelectionViewModel create() => TableSelectionViewModel();
}

String _$tableSelectionViewModelHash() =>
    r'048fd8cf454245c97fb7efe021bfef4542b4e7cf';

abstract class _$TableSelectionViewModel
    extends $StreamNotifier<List<TableInfo>> {
  Stream<List<TableInfo>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<List<TableInfo>>, List<TableInfo>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<TableInfo>>, List<TableInfo>>,
              AsyncValue<List<TableInfo>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
