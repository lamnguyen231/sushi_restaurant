// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dining_cart_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(sessionPlacedOrders)
const sessionPlacedOrdersProvider = SessionPlacedOrdersFamily._();

final class SessionPlacedOrdersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RestaurantOrder>>,
          List<RestaurantOrder>,
          Stream<List<RestaurantOrder>>
        >
    with
        $FutureModifier<List<RestaurantOrder>>,
        $StreamProvider<List<RestaurantOrder>> {
  const SessionPlacedOrdersProvider._({
    required SessionPlacedOrdersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'sessionPlacedOrdersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$sessionPlacedOrdersHash();

  @override
  String toString() {
    return r'sessionPlacedOrdersProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RestaurantOrder>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RestaurantOrder>> create(Ref ref) {
    final argument = this.argument as String;
    return sessionPlacedOrders(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is SessionPlacedOrdersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$sessionPlacedOrdersHash() =>
    r'8a9dd7fa4e5071e96931fe8d25739a9bb303b9ad';

final class SessionPlacedOrdersFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RestaurantOrder>>, String> {
  const SessionPlacedOrdersFamily._()
    : super(
        retry: null,
        name: r'sessionPlacedOrdersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  SessionPlacedOrdersProvider call(String sessionId) =>
      SessionPlacedOrdersProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'sessionPlacedOrdersProvider';
}

@ProviderFor(DiningCartViewModel)
const diningCartViewModelProvider = DiningCartViewModelFamily._();

final class DiningCartViewModelProvider
    extends $AsyncNotifierProvider<DiningCartViewModel, DiningCartState> {
  const DiningCartViewModelProvider._({
    required DiningCartViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'diningCartViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$diningCartViewModelHash();

  @override
  String toString() {
    return r'diningCartViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  DiningCartViewModel create() => DiningCartViewModel();

  @override
  bool operator ==(Object other) {
    return other is DiningCartViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$diningCartViewModelHash() =>
    r'3bcbdf172f3b2eff40de7391f005835649277cb8';

final class DiningCartViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          DiningCartViewModel,
          AsyncValue<DiningCartState>,
          DiningCartState,
          FutureOr<DiningCartState>,
          String
        > {
  const DiningCartViewModelFamily._()
    : super(
        retry: null,
        name: r'diningCartViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  DiningCartViewModelProvider call(String sessionId) =>
      DiningCartViewModelProvider._(argument: sessionId, from: this);

  @override
  String toString() => r'diningCartViewModelProvider';
}

abstract class _$DiningCartViewModel extends $AsyncNotifier<DiningCartState> {
  late final _$args = ref.$arg as String;
  String get sessionId => _$args;

  FutureOr<DiningCartState> build(String sessionId);
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build(_$args);
    final ref = this.ref as $Ref<AsyncValue<DiningCartState>, DiningCartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<DiningCartState>, DiningCartState>,
              AsyncValue<DiningCartState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
