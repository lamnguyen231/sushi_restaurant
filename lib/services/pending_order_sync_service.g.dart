// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

part of 'pending_order_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(pendingOrderSync)
const pendingOrderSyncProvider = PendingOrderSyncProvider._();

final class PendingOrderSyncProvider
    extends
        $FunctionalProvider<
          PendingOrderSyncService,
          PendingOrderSyncService,
          PendingOrderSyncService
        >
    with $Provider<PendingOrderSyncService> {
  const PendingOrderSyncProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingOrderSyncProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingOrderSyncHash();

  @$internal
  @override
  $ProviderElement<PendingOrderSyncService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PendingOrderSyncService create(Ref ref) {
    return pendingOrderSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingOrderSyncService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingOrderSyncService>(value),
    );
  }
}

String _$pendingOrderSyncHash() => r'dummyhashsync';
