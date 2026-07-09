// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_menu_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(WebMenuViewModel)
const webMenuViewModelProvider = WebMenuViewModelProvider._();

final class WebMenuViewModelProvider
    extends $StreamNotifierProvider<WebMenuViewModel, WebMenuState> {
  const WebMenuViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'webMenuViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$webMenuViewModelHash();

  @$internal
  @override
  WebMenuViewModel create() => WebMenuViewModel();
}

String _$webMenuViewModelHash() => r'58eea16c34d7296fe442e04923184594dbecfcc7';

abstract class _$WebMenuViewModel extends $StreamNotifier<WebMenuState> {
  Stream<WebMenuState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<WebMenuState>, WebMenuState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<WebMenuState>, WebMenuState>,
              AsyncValue<WebMenuState>,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
