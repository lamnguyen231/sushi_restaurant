import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/providers/local_providers.dart';
import '../core/theme/app_theme.dart';
import '../viewmodels/dining_menu_view_model.dart';
import '../widgets/dining_cart_sidebar.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/sushi_product_dining_grid_item.dart';

class DiningMenuScreen extends ConsumerWidget {
  const DiningMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(diningMenuViewModelProvider);
    final session = ref.watch(currentDiningSessionProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dining Menu')),
        body: const EmptyStateView(message: 'Không tìm thấy phiên làm việc. Hãy yêu cầu nhân viên mở bàn.'),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.rice,
      body: Row(
        children: [
          // Bên trái: Menu
          Expanded(
            child: Column(
              children: [
                // Header Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            'SISHU DINING',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.rice,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          session.tableName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Menu Grid
                Expanded(
                  child: menuState.when(
                    loading: () => const LoadingView(message: 'Đang tải danh sách menu'),
                    error: (error, stackTrace) => ErrorView(message: 'Không tải được menu: $error'),
                    data: (menu) {
                      if (menu.isEmpty) {
                        return const EmptyStateView(message: 'Chưa có sản phẩm nào.');
                      }

                      // Tính toán search & filter
                      var filteredMenu = menu;
                      final searchQ = ref.watch(diningMenuSearchQueryProvider).toLowerCase();
                      final selCat = ref.watch(diningMenuCategoryProvider);

                      if (searchQ.isNotEmpty) {
                        filteredMenu = filteredMenu.where((p) => p.name.toLowerCase().contains(searchQ)).toList();
                      }
                      if (selCat != null && selCat.isNotEmpty) {
                        filteredMenu = filteredMenu.where((p) => p.categoryId == selCat).toList();
                      }

                      // Lấy danh sách danh mục duy nhất
                      final categories = menu.map((e) => e.categoryId).toSet().toList();
                      categories.sort(); // Sắp xếp alpha-b cho đẹp

                      return Column(
                        children: [
                          // Search & Filter Bar
                          Container(
                            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                            child: Column(
                              children: [
                                // Search Bar
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: 'Tìm kiếm món ăn...',
                                    prefixIcon: const Icon(Icons.search),
                                    filled: true,
                                    fillColor: Colors.white,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                                  ),
                                  onChanged: (val) {
                                    ref.read(diningMenuSearchQueryProvider.notifier).updateQuery(val);
                                  },
                                ),
                                const SizedBox(height: 16),
                                // Filter Chips
                                SizedBox(
                                  height: 40,
                                  child: ListView.separated(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: categories.length + 1,
                                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                                    itemBuilder: (context, index) {
                                      final isAll = index == 0;
                                      final cat = isAll ? null : categories[index - 1];
                                      final isSelected = selCat == cat;
                                      
                                      return ChoiceChip(
                                        label: Text(isAll ? 'Tất cả' : cat!.toUpperCase()),
                                        selected: isSelected,
                                        onSelected: (selected) {
                                          if (selected) {
                                            ref.read(diningMenuCategoryProvider.notifier).updateCategory(cat);
                                          }
                                        },
                                        selectedColor: AppTheme.vermilion,
                                        showCheckmark: false,
                                        labelStyle: TextStyle(
                                          color: isSelected ? Colors.white : Colors.black87,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                        ),
                                        backgroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                          side: BorderSide(color: isSelected ? AppTheme.vermilion : Colors.grey.shade300),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Grid
                          Expanded(
                            child: filteredMenu.isEmpty
                              ? const EmptyStateView(message: 'Không tìm thấy món ăn phù hợp.')
                              : GridView.builder(
                                  padding: const EdgeInsets.all(24),
                                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 300, 
                                    mainAxisExtent: 280,
                                    crossAxisSpacing: 24,
                                    mainAxisSpacing: 24,
                                  ),
                                  itemCount: filteredMenu.length,
                                  itemBuilder: (context, index) {
                                    final product = filteredMenu[index];
                                    return SushiProductDiningGridItem(
                                      product: product,
                                      onAddToCart: () async {
                                        await ref.read(diningMenuViewModelProvider.notifier).addProductToCart(product);
                                      },
                                    );
                                  },
                                ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          
          // Bên phải: Giỏ hàng Sidebar
          Container(
            width: 380, // Chiều rộng cố định cho sidebar
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(left: BorderSide(color: Colors.grey.shade300)),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(-2, 0)),
              ],
            ),
            child: DiningCartSidebar(session: session),
          ),
        ],
      ),
    );
  }
}
