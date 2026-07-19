// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_order_sync_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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

String _$pendingOrderSyncHash() => r'1cac4da74c9bb3ffa04f02673b3501e919c73164';
