import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers/firebase_providers.dart';
import '../models/sushi_product.dart';

part 'web_menu_view_model.g.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class WebMenuState {
  const WebMenuState({
    this.allProducts = const [],
    this.searchQuery = '',
    this.categoryFilter = '',
    this.currentPage = 0,
    this.pageSize = 12,
  });

  final List<SushiProduct> allProducts;
  final String searchQuery;
  final String categoryFilter;
  final int currentPage;
  final int pageSize;

  // ── Derived ─────────────────────────────────────────────────────────────────

  List<SushiProduct> get filteredProducts {
    var list = allProducts;

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    if (categoryFilter.isNotEmpty) {
      list = list.where((p) => p.categoryId == categoryFilter).toList();
    }

    return list;
  }

  List<SushiProduct> get pageProducts {
    final filtered = filteredProducts;
    final start = currentPage * pageSize;
    if (start >= filtered.length) return [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get totalPages {
    final count = filteredProducts.length;
    if (count == 0) return 1;
    return ((count - 1) ~/ pageSize) + 1;
  }

  List<String> get availableCategories {
    final cats = allProducts.map((p) => p.categoryId).toSet().toList();
    cats.sort();
    return cats;
  }

  WebMenuState copyWith({
    List<SushiProduct>? allProducts,
    String? searchQuery,
    String? categoryFilter,
    int? currentPage,
    int? pageSize,
  }) {
    return WebMenuState(
      allProducts: allProducts ?? this.allProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

@riverpod
class WebMenuViewModel extends _$WebMenuViewModel {
  @override
  Stream<WebMenuState> build() async* {
    final repo = ref.watch(productRepositoryProvider);
    yield* repo.watchAvailableProducts().map(
          (products) => WebMenuState(allProducts: products),
        );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _update(WebMenuState Function(WebMenuState s) fn) {
    final current = state.asData?.value ?? const WebMenuState();
    state = AsyncData(fn(current));
  }

  void search(String query) {
    _update((s) => s.copyWith(searchQuery: query, currentPage: 0));
  }

  void filterByCategory(String categoryId) {
    _update((s) => s.copyWith(categoryFilter: categoryId, currentPage: 0));
  }

  void goToPage(int page) {
    _update((s) => s.copyWith(currentPage: page));
  }

  void clearFilters() {
    _update((s) => s.copyWith(searchQuery: '', categoryFilter: '', currentPage: 0));
  }
}
