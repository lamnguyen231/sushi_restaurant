// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sqliteCartService)
const sqliteCartServiceProvider = SqliteCartServiceProvider._();

final class SqliteCartServiceProvider
    extends
        $FunctionalProvider<
          SqliteCartService,
          SqliteCartService,
          SqliteCartService
        >
    with $Provider<SqliteCartService> {
  const SqliteCartServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sqliteCartServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sqliteCartServiceHash();

  @$internal
  @override
  $ProviderElement<SqliteCartService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SqliteCartService create(Ref ref) {
    return sqliteCartService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SqliteCartService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SqliteCartService>(value),
    );
  }
}

String _$sqliteCartServiceHash() => r'57a718be18057933c599b68f3ef4b046bacb6384';

@ProviderFor(localCartRepository)
const localCartRepositoryProvider = LocalCartRepositoryProvider._();

final class LocalCartRepositoryProvider
    extends
        $FunctionalProvider<
          LocalCartRepository,
          LocalCartRepository,
          LocalCartRepository
        >
    with $Provider<LocalCartRepository> {
  const LocalCartRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localCartRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localCartRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocalCartRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalCartRepository create(Ref ref) {
    return localCartRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalCartRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalCartRepository>(value),
    );
  }
}

String _$localCartRepositoryHash() =>
    r'83e1e41c80f421c1ea0539f712a8f1028b8dfe8c';

@ProviderFor(CurrentDiningSession)
const currentDiningSessionProvider = CurrentDiningSessionProvider._();

final class CurrentDiningSessionProvider
    extends $NotifierProvider<CurrentDiningSession, DiningSession?> {
  const CurrentDiningSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentDiningSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentDiningSessionHash();

  @$internal
  @override
  CurrentDiningSession create() => CurrentDiningSession();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DiningSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DiningSession?>(value),
    );
  }
}

String _$currentDiningSessionHash() =>
    r'eb7f3b954cd0af89681aa7e6837c2f0ad94aa1db';

abstract class _$CurrentDiningSession extends $Notifier<DiningSession?> {
  DiningSession? build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<DiningSession?, DiningSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DiningSession?, DiningSession?>,
              DiningSession?,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

@ProviderFor(sqlitePendingOrderService)
const sqlitePendingOrderServiceProvider = SqlitePendingOrderServiceProvider._();

final class SqlitePendingOrderServiceProvider
    extends
        $FunctionalProvider<
          SqlitePendingOrderService,
          SqlitePendingOrderService,
          SqlitePendingOrderService
        >
    with $Provider<SqlitePendingOrderService> {
  const SqlitePendingOrderServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sqlitePendingOrderServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sqlitePendingOrderServiceHash();

  @$internal
  @override
  $ProviderElement<SqlitePendingOrderService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SqlitePendingOrderService create(Ref ref) {
    return sqlitePendingOrderService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SqlitePendingOrderService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SqlitePendingOrderService>(value),
    );
  }
}

String _$sqlitePendingOrderServiceHash() => r'dummyhashservice';

@ProviderFor(localPendingOrderRepository)
const localPendingOrderRepositoryProvider = LocalPendingOrderRepositoryProvider._();

final class LocalPendingOrderRepositoryProvider
    extends
        $FunctionalProvider<
          LocalPendingOrderRepository,
          LocalPendingOrderRepository,
          LocalPendingOrderRepository
        >
    with $Provider<LocalPendingOrderRepository> {
  const LocalPendingOrderRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localPendingOrderRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localPendingOrderRepositoryHash();

  @$internal
  @override
  $ProviderElement<LocalPendingOrderRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocalPendingOrderRepository create(Ref ref) {
    return localPendingOrderRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalPendingOrderRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalPendingOrderRepository>(value),
    );
  }
}

String _$localPendingOrderRepositoryHash() => r'dummyhashrepo';
