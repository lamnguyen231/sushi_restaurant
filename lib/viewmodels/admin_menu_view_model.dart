import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../models/sushi_product.dart';

part 'admin_menu_view_model.g.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class AdminMenuState {
  const AdminMenuState({
    this.allProducts = const [],
    this.searchQuery = '',
    this.categoryFilter = '',
    this.areaFilter,
    this.currentPage = 0,
    this.pageSize = 10,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<SushiProduct> allProducts;
  final String searchQuery;
  final String categoryFilter;
  final PreparationArea? areaFilter;
  final int currentPage;
  final int pageSize;
  final bool isSubmitting;
  final String? errorMessage;

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

    if (areaFilter != null) {
      list = list.where((p) => p.preparationArea == areaFilter).toList();
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

  AdminMenuState copyWith({
    List<SushiProduct>? allProducts,
    String? searchQuery,
    String? categoryFilter,
    Object? areaFilter = _sentinel,
    int? currentPage,
    int? pageSize,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
  }) {
    return AdminMenuState(
      allProducts: allProducts ?? this.allProducts,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      areaFilter: areaFilter == _sentinel
          ? this.areaFilter
          : areaFilter as PreparationArea?,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage:
          errorMessage == _sentinel ? this.errorMessage : errorMessage as String?,
    );
  }
}

const _sentinel = Object();

// ── ViewModel ─────────────────────────────────────────────────────────────────

@riverpod
class AdminMenuViewModel extends _$AdminMenuViewModel {
  @override
  Stream<AdminMenuState> build() async* {
    final repo = ref.watch(productRepositoryProvider);
    yield* repo.watchAllProducts().map(
          (products) => AdminMenuState(allProducts: products),
        );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  void _update(AdminMenuState Function(AdminMenuState s) fn) {
    final current = state.asData?.value ?? const AdminMenuState();
    state = AsyncData(fn(current));
  }

  // ── Filter / Search / Pagination ─────────────────────────────────────────────

  void search(String query) {
    _update((s) => s.copyWith(searchQuery: query, currentPage: 0));
  }

  void filterByCategory(String categoryId) {
    _update((s) => s.copyWith(categoryFilter: categoryId, currentPage: 0));
  }

  void filterByArea(PreparationArea? area) {
    _update((s) => s.copyWith(areaFilter: area, currentPage: 0));
  }

  void goToPage(int page) {
    _update((s) => s.copyWith(currentPage: page));
  }

  void clearFilters() {
    _update(
      (s) => s.copyWith(
        searchQuery: '',
        categoryFilter: '',
        areaFilter: null,
        currentPage: 0,
      ),
    );
  }

  // ── CRUD ─────────────────────────────────────────────────────────────────────

  Future<void> addProduct({
    required String name,
    required double price,
    required String categoryId,
    required bool isAvailable,
    required PreparationArea preparationArea,
    String? description,
    String? imageUrl,
  }) async {
    _update((s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await ref.read(productRepositoryProvider).addProduct(
            name: name,
            price: price,
            categoryId: categoryId,
            isAvailable: isAvailable,
            preparationArea: preparationArea,
            description: description,
            imageUrl: imageUrl,
          );
      _update((s) => s.copyWith(isSubmitting: false));
    } catch (e) {
      _update((s) => s.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required String categoryId,
    required bool isAvailable,
    required PreparationArea preparationArea,
    String? description,
    String? imageUrl,
  }) async {
    _update((s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await ref.read(productRepositoryProvider).updateProduct(
            id: id,
            name: name,
            price: price,
            categoryId: categoryId,
            isAvailable: isAvailable,
            preparationArea: preparationArea,
            description: description,
            imageUrl: imageUrl,
          );
      _update((s) => s.copyWith(isSubmitting: false));
    } catch (e) {
      _update((s) => s.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    _update((s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await ref.read(productRepositoryProvider).deleteProduct(productId);
      _update((s) => s.copyWith(isSubmitting: false));
    } catch (e) {
      _update((s) => s.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
