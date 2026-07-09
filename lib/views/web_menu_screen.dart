import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../models/sushi_product.dart';
import '../viewmodels/web_menu_view_model.dart';
import '../widgets/menu_filter_bar.dart';
import '../widgets/menu_pagination_bar.dart';
import '../viewmodels/web_cart_view_model.dart';
import '../widgets/sushi_nav_bar.dart';
import '../widgets/sushi_product_card.dart';
// ProductDetailDialog is defined inside sushi_product_card.dart

class WebMenuScreen extends ConsumerWidget {
  const WebMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(webMenuViewModelProvider);

    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: AppTheme.vermilion),
              const SizedBox(height: 12),
              Text('Không thể tải menu: $e',
                  style: const TextStyle(color: AppTheme.mutedInk)),
            ],
          ),
        ),
        data: (state) => _WebMenuBody(state: state),
      ),
    );
  }
}

class _WebMenuBody extends ConsumerWidget {
  const _WebMenuBody({required this.state});

  final WebMenuState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(webMenuViewModelProvider.notifier);
    final products = state.pageProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Hero banner ──────────────────────────────────────────────────
        _MenuHeroBanner(),

        // ── Filter bar ───────────────────────────────────────────────────
        Container(
          color: AppTheme.paper,
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats row
              Row(
                children: [
                  Text(
                    '${state.filteredProducts.length} MÓN ĂN',
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          letterSpacing: 2.4,
                        ),
                  ),
                  if (state.searchQuery.isNotEmpty ||
                      state.categoryFilter.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Text(
                      '(đã lọc từ ${state.allProducts.length})',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.mutedInk,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 12),
              MenuFilterBar(
                categories: state.availableCategories,
                selectedCategory: state.categoryFilter,
                searchQuery: state.searchQuery,
                hint: 'Tìm kiếm món ăn...',
                onSearch: vm.search,
                onCategoryChanged: vm.filterByCategory,
                onClear: vm.clearFilters,
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: AppTheme.rice),

        // ── Product grid ─────────────────────────────────────────────────
        Expanded(
          child: products.isEmpty
              ? _EmptyMenuState(hasFilter: state.searchQuery.isNotEmpty ||
                  state.categoryFilter.isNotEmpty)
              : _ProductGrid(products: products),
        ),

        // ── Pagination ───────────────────────────────────────────────────
        Container(
          color: AppTheme.paper,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: MenuPaginationBar(
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            totalItems: state.filteredProducts.length,
            pageSize: state.pageSize,
            onPageChanged: vm.goToPage,
          ),
        ),
      ],
    );
  }
}

// ── Hero Banner ───────────────────────────────────────────────────────────────

class _MenuHeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: AppTheme.ink,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Decorative pattern
          CustomPaint(painter: _GridPainter()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'THỰC ĐƠN',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: AppTheme.paper,
                              letterSpacing: 8,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Sushi & Japanese Cuisine',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.rice,
                              fontSize: 14,
                            ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.restaurant_menu,
                  color: AppTheme.rice,
                  size: 48,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.paper.withValues(alpha: 0.04)
      ..strokeWidth = 1;
    for (var x = 0.0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (var y = 0.0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ── Product Grid ──────────────────────────────────────────────────────────────

class _ProductGrid extends ConsumerWidget {
  const _ProductGrid({required this.products});

  final List<SushiProduct> products;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = switch (width) {
      >= 1200 => 4,
      >= 900 => 3,
      >= 600 => 2,
      _ => 1,
    };

    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.72,
      ),
      itemCount: products.length,
      itemBuilder: (context, i) {
        final product = products[i];
        return SushiProductCard(
          product: product,
          onViewDetail: () => ProductDetailDialog.show(
            context,
            product: product,
            onAddToCart: () => _addToCart(context, ref, product),
          ),
          onAddToCart: () => _addToCart(context, ref, product),
        );
      },
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, SushiProduct product) {
    // Thêm vào giỏ hàng (mặc định qty = 1, nếu đã có thì cộng thêm 1)
    ref.read(webCartViewModelProvider.notifier).addItem(product);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã thêm "${product.name}" vào giỏ hàng!\nVui lòng vào giỏ hàng để thêm số lượng và thanh toán.',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF1B4332),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        action: SnackBarAction(
          label: 'GIỎ HÀNG',
          textColor: Colors.white70,
          onPressed: () => context.go('/web/cart'),
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyMenuState extends StatelessWidget {
  const _EmptyMenuState({required this.hasFilter});
  final bool hasFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.no_meals, size: 72, color: AppTheme.rice),
            const SizedBox(height: 16),
            Text(
              hasFilter
                  ? 'Không tìm thấy món ăn phù hợp'
                  : 'Thực đơn đang được cập nhật',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              hasFilter
                  ? 'Hãy thử tìm kiếm khác hoặc xóa bộ lọc'
                  : 'Vui lòng quay lại sau',
              style: const TextStyle(color: AppTheme.mutedInk, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
