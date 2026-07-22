// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reservation_management_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ReservationManagementViewModel)
const reservationManagementViewModelProvider =
    ReservationManagementViewModelProvider._();

final class ReservationManagementViewModelProvider
    extends
        $StreamNotifierProvider<
          ReservationManagementViewModel,
          List<Reservation>
        > {
  const ReservationManagementViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reservationManagementViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reservationManagementViewModelHash();

  @$internal
  @override
  ReservationManagementViewModel create() => ReservationManagementViewModel();
}

String _$reservationManagementViewModelHash() =>
    r'38396d1dcf965750985148e9d100c35fe536c922';

abstract class _$ReservationManagementViewModel
    extends $StreamNotifier<List<Reservation>> {
  Stream<List<Reservation>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref =
        this.ref as $Ref<AsyncValue<List<Reservation>>, List<Reservation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Reservation>>, List<Reservation>>,
              AsyncValue<List<Reservation>>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
