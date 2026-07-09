// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_menu_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiningMenuViewModel)
const diningMenuViewModelProvider = DiningMenuViewModelProvider._();

final class DiningMenuViewModelProvider
    extends $StreamNotifierProvider<DiningMenuViewModel, List<SushiProduct>> {
  const DiningMenuViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diningMenuViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diningMenuViewModelHash();

  @$internal
  @override
  DiningMenuViewModel create() => DiningMenuViewModel();
}

String _$diningMenuViewModelHash() =>
    r'20c4753445897b259b2cff42af44dff74a492c00';

abstract class _$DiningMenuViewModel
    extends $StreamNotifier<List<SushiProduct>> {
  Stream<List<SushiProduct>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<SushiProduct>>, List<SushiProduct>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<SushiProduct>>, List<SushiProduct>>,
              AsyncValue<List<SushiProduct>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
