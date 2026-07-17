// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_cart_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WebCartViewModel)
const webCartViewModelProvider = WebCartViewModelProvider._();

final class WebCartViewModelProvider
    extends $NotifierProvider<WebCartViewModel, WebCartState> {
  const WebCartViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webCartViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webCartViewModelHash();

  @$internal
  @override
  WebCartViewModel create() => WebCartViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WebCartState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WebCartState>(value),
    );
  }
}

String _$webCartViewModelHash() => r'3df5e134f1b41b4c39ed2d3a9e58d213e1a8bfd8';

abstract class _$WebCartViewModel extends $Notifier<WebCartState> {
  WebCartState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<WebCartState, WebCartState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<WebCartState, WebCartState>,
              WebCartState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
