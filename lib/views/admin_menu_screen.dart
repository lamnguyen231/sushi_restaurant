import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../models/sushi_product.dart';
import '../viewmodels/admin_menu_view_model.dart';
import '../widgets/admin_product_row.dart';
import '../widgets/menu_filter_bar.dart';
import '../widgets/menu_pagination_bar.dart';
import '../widgets/product_form_dialog.dart';
import '../widgets/sushi_nav_bar.dart';

class AdminMenuScreen extends ConsumerWidget {
  const AdminMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminMenuViewModelProvider);

    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: asyncState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text('Lỗi: $e', style: const TextStyle(color: AppTheme.vermilion)),
        ),
        data: (state) => _AdminMenuBody(state: state),
      ),
    );
  }
}

class _AdminMenuBody extends ConsumerWidget {
  const _AdminMenuBody({required this.state});

  final AdminMenuState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(adminMenuViewModelProvider.notifier);
    final products = state.pageProducts;
    final filtered = state.filteredProducts;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header bar ────────────────────────────────────────────────────
        Container(
          color: AppTheme.paper,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
          child: Row(
            children: [
              // Back
              IconButton(
                icon: const Icon(Icons.arrow_back, size: 20),
                onPressed: () => context.go('/'),
                tooltip: 'Về trang chủ',
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUẢN LÝ MENU',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    Text(
                      '${state.allProducts.length} sản phẩm tổng cộng',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              // Add button
              ElevatedButton.icon(
                onPressed: () => _showAddDialog(context, ref),
                icon: const Icon(Icons.add, size: 16),
                label: const Text('THÊM MÓN'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.ink,
                  foregroundColor: AppTheme.paper,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.zero,
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: AppTheme.rice),

        // ── Filter bar ────────────────────────────────────────────────────
        Container(
          color: AppTheme.paper,
          padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
          child: MenuFilterBar(
            categories: state.availableCategories,
            selectedCategory: state.categoryFilter,
            selectedArea: state.areaFilter,
            searchQuery: state.searchQuery,
            showAreaFilter: true,
            hint: 'Tìm kiếm tên sản phẩm...',
            onSearch: vm.search,
            onCategoryChanged: vm.filterByCategory,
            onAreaChanged: vm.filterByArea,
            onClear: vm.clearFilters,
          ),
        ),

        const Divider(height: 1, color: AppTheme.rice),

        // ── Table header ──────────────────────────────────────────────────
        Container(
          color: AppTheme.ink,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: const [
              SizedBox(width: 52 + 14), // thumbnail spacer
              Expanded(flex: 3, child: _HeaderCell('SẢN PHẨM')),
              Expanded(flex: 2, child: _HeaderCell('CATEGORY')),
              Expanded(flex: 2, child: _HeaderCell('KHU VỰC')),
              SizedBox(width: 90, child: _HeaderCell('GIÁ', right: true)),
              SizedBox(width: 16),
              SizedBox(width: 82, child: _HeaderCell('TRẠNG THÁI')),
              SizedBox(width: 12),
              SizedBox(width: 80, child: _HeaderCell('THAO TÁC')),
            ],
          ),
        ),

        // ── Product list ──────────────────────────────────────────────────
        Expanded(
          child: products.isEmpty
              ? _EmptyState(hasFilters: state.searchQuery.isNotEmpty ||
                  state.categoryFilter.isNotEmpty ||
                  state.areaFilter != null)
              : ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final product = products[i];
                    return AdminProductRow(
                      product: product,
                      onEdit: () => _showEditDialog(context, ref, product),
                      onDelete: () => _confirmDelete(context, ref, product),
                    );
                  },
                ),
        ),

        // ── Pagination ────────────────────────────────────────────────────
        Container(
          color: AppTheme.paper,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          child: MenuPaginationBar(
            currentPage: state.currentPage,
            totalPages: state.totalPages,
            totalItems: filtered.length,
            pageSize: state.pageSize,
            onPageChanged: vm.goToPage,
          ),
        ),
      ],
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────────────────

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final data = await ProductFormDialog.show(context);
    if (data == null) return;

    await ref.read(adminMenuViewModelProvider.notifier).addProduct(
          name: data.name,
          price: data.price,
          categoryId: data.categoryId,
          isAvailable: data.isAvailable,
          preparationArea: data.preparationArea,
          description: data.description,
          imageUrl: data.imageUrl,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm sản phẩm thành công!')),
      );
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    SushiProduct product,
  ) async {
    final data = await ProductFormDialog.show(context, product: product);
    if (data == null) return;

    await ref.read(adminMenuViewModelProvider.notifier).updateProduct(
          id: product.id,
          name: data.name,
          price: data.price,
          categoryId: data.categoryId,
          isAvailable: data.isAvailable,
          preparationArea: data.preparationArea,
          description: data.description,
          imageUrl: data.imageUrl,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã cập nhật sản phẩm!')),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    SushiProduct product,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(productName: product.name),
    );

    if (confirmed != true) return;

    await ref
        .read(adminMenuViewModelProvider.notifier)
        .deleteProduct(product.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa "${product.name}"'),
          backgroundColor: AppTheme.vermilion,
        ),
      );
    }
  }
}

// ── Sub widgets ───────────────────────────────────────────────────────────────

class _HeaderCell extends StatelessWidget {
  const _HeaderCell(this.label, {this.right = false});
  final String label;
  final bool right;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      textAlign: right ? TextAlign.right : TextAlign.left,
      style: const TextStyle(
        color: AppTheme.paper,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.8,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.restaurant_menu, size: 64, color: AppTheme.rice),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'Không tìm thấy sản phẩm phù hợp' : 'Chưa có sản phẩm',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.mutedInk,
                ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 8),
            const Text(
              'Thử thay đổi bộ lọc hoặc từ khoá tìm kiếm',
              style: TextStyle(color: AppTheme.mutedInk, fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({required this.productName});
  final String productName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 48,
              color: AppTheme.vermilion,
            ),
            const SizedBox(height: 16),
            Text(
              'Xác nhận xóa?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Bạn có chắc muốn xóa "$productName"?\nHành động này không thể hoàn tác.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('HỦY'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.vermilion,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'XÓA',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
