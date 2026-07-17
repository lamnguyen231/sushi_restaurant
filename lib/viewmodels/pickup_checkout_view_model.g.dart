// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pickup_checkout_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PickupCheckoutViewModel)
const pickupCheckoutViewModelProvider = PickupCheckoutViewModelProvider._();

final class PickupCheckoutViewModelProvider
    extends
        $NotifierProvider<
          PickupCheckoutViewModel,
          AsyncValue<RestaurantOrder?>
        > {
  const PickupCheckoutViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pickupCheckoutViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pickupCheckoutViewModelHash();

  @$internal
  @override
  PickupCheckoutViewModel create() => PickupCheckoutViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RestaurantOrder?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RestaurantOrder?>>(value),
    );
  }
}

String _$pickupCheckoutViewModelHash() =>
    r'3408821e6a0ec0bc6f41f8448f24e50a4c6666b7';

abstract class _$PickupCheckoutViewModel
    extends $Notifier<AsyncValue<RestaurantOrder?>> {
  AsyncValue<RestaurantOrder?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref
            as $Ref<AsyncValue<RestaurantOrder?>, AsyncValue<RestaurantOrder?>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<RestaurantOrder?>,
                AsyncValue<RestaurantOrder?>
              >,
              AsyncValue<RestaurantOrder?>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
