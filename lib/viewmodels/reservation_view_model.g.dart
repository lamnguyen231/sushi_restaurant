// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReservationViewModel)
const reservationViewModelProvider = ReservationViewModelProvider._();

final class ReservationViewModelProvider
    extends $NotifierProvider<ReservationViewModel, AsyncValue<void>> {
  const ReservationViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reservationViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reservationViewModelHash();

  @$internal
  @override
  ReservationViewModel create() => ReservationViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<void> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<void>>(value),
    );
  }
}

String _$reservationViewModelHash() =>
    r'05e7747b8a1a82efbef4ca34cda56ec0c77fcce9';

abstract class _$ReservationViewModel extends $Notifier<AsyncValue<void>> {
  AsyncValue<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<void>, AsyncValue<void>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, AsyncValue<void>>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
