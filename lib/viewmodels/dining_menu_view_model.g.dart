// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_menu_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DiningMenuSearchQuery)
const diningMenuSearchQueryProvider = DiningMenuSearchQueryProvider._();

final class DiningMenuSearchQueryProvider
    extends $NotifierProvider<DiningMenuSearchQuery, String> {
  const DiningMenuSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diningMenuSearchQueryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diningMenuSearchQueryHash();

  @$internal
  @override
  DiningMenuSearchQuery create() => DiningMenuSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$diningMenuSearchQueryHash() =>
    r'7ff2f8a96b775a996691ea0db563c909dfd792fb';

abstract class _$DiningMenuSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(DiningMenuCategory)
const diningMenuCategoryProvider = DiningMenuCategoryProvider._();

final class DiningMenuCategoryProvider
    extends $NotifierProvider<DiningMenuCategory, String?> {
  const DiningMenuCategoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diningMenuCategoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diningMenuCategoryHash();

  @$internal
  @override
  DiningMenuCategory create() => DiningMenuCategory();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String?>(value),
    );
  }
}

String _$diningMenuCategoryHash() =>
    r'c8b80bf734cbd746be112a244b67b7826aab3505';

abstract class _$DiningMenuCategory extends $Notifier<String?> {
  String? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<String?, String?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String?, String?>,
              String?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

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
    r'268ddca34340e1a51650c72f17269bf37ae5a569';

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
