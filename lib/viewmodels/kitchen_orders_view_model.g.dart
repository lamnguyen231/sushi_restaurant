// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kitchen_orders_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KitchenOrdersViewModel)
const kitchenOrdersViewModelProvider = KitchenOrdersViewModelProvider._();

final class KitchenOrdersViewModelProvider
    extends
        $StreamNotifierProvider<KitchenOrdersViewModel, List<RestaurantOrder>> {
  const KitchenOrdersViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kitchenOrdersViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kitchenOrdersViewModelHash();

  @$internal
  @override
  KitchenOrdersViewModel create() => KitchenOrdersViewModel();
}

String _$kitchenOrdersViewModelHash() =>
    r'a6b13bf85387ac1a2c73e22d22a04eb5bbf8bed9';

abstract class _$KitchenOrdersViewModel
    extends $StreamNotifier<List<RestaurantOrder>> {
  Stream<List<RestaurantOrder>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<List<RestaurantOrder>>, List<RestaurantOrder>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<RestaurantOrder>>,
                List<RestaurantOrder>
              >,
              AsyncValue<List<RestaurantOrder>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
