import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/local_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/dining_session.dart';
import '../models/sushi_product.dart';
import '../viewmodels/dining_cart_view_model.dart';
import '../viewmodels/dining_menu_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/staff_session_unlock_button.dart';
import '../widgets/sushi_product_dining_grid_item.dart';

class DiningMenuScreen extends ConsumerStatefulWidget {
  const DiningMenuScreen({super.key});

  @override
  ConsumerState<DiningMenuScreen> createState() => _DiningMenuScreenState();
}

class _DiningMenuScreenState extends ConsumerState<DiningMenuScreen> {
  bool _showCategories = false;

  @override
  Widget build(BuildContext context) {
    final menuState = ref.watch(diningMenuViewModelProvider);
    final session = ref.watch(currentDiningSessionProvider);

    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Dining Menu')),
        body: const EmptyStateView(
          message:
              'Không tìm thấy phiên làm việc. Hãy yêu cầu nhân viên mở bàn.',
        ),
      );
    }

    final cartState = ref.watch(diningCartViewModelProvider(session.id));
    final cartQuantity = cartState.value?.totalQuantity ?? 0;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppTheme.eggshell,
        appBar: _DiningAppBar(
          session: session,
          cartQuantity: cartQuantity,
          categoriesVisible: _showCategories,
          onToggleCategories: () {
            setState(() => _showCategories = !_showCategories);
          },
        ),
        body: menuState.when(
          loading: () => const LoadingView(message: 'Đang tải danh sách menu'),
          error: (error, stackTrace) =>
              ErrorView(message: 'Không tải được menu: $error'),
          data: (menu) {
            if (menu.isEmpty) {
              return const EmptyStateView(message: 'Chưa có sản phẩm nào.');
            }

            return _MenuWorkspace(
              menu: menu,
              showCategories: _showCategories,
              onProductAdded: (product) async {
                await ref
                    .read(diningMenuViewModelProvider.notifier)
                    .addProductToCart(product);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      duration: const Duration(milliseconds: 900),
                      content: Text('Đã thêm ${product.name} vào giỏ.'),
                    ),
                  );
              },
            );
          },
        ),
      ),
    );
  }
}

class _DiningAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _DiningAppBar({
    required this.session,
    required this.cartQuantity,
    required this.categoriesVisible,
    required this.onToggleCategories,
  });

  final DiningSession session;
  final int cartQuantity;
  final bool categoriesVisible;
  final VoidCallback onToggleCategories;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).width < 900;

    return AppBar(
      toolbarHeight: 72,
      automaticallyImplyLeading: false,
      titleSpacing: compact ? 12 : 24,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!compact) const Text('SISHU DINING') else const Text('SISHU'),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppTheme.rice,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              session.tableName,
              style: const TextStyle(
                color: AppTheme.ink,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
      actions: [
        _HeaderAction(
          tooltip: categoriesVisible ? 'Ẩn danh mục' : 'Hiện danh mục',
          icon: categoriesVisible ? Icons.filter_alt_off : Icons.filter_alt,
          label: compact ? null : 'Danh mục',
          onPressed: onToggleCategories,
        ),
        _CartHeaderAction(quantity: cartQuantity, compact: compact),
        _HeaderAction(
          tooltip: 'Món đã gọi',
          icon: Icons.receipt_long_outlined,
          label: compact ? null : 'Đã gọi',
          onPressed: () => context.go('/dining/orders'),
        ),
        if (compact)
          IconTheme(
            data: const IconThemeData(color: AppTheme.paper),
            child: StaffSessionUnlockButton(session: session, iconOnly: true),
          )
        else
          StaffSessionUnlockButton(session: session),
        SizedBox(width: compact ? 4 : 12),
      ],
    );
  }
}

class _HeaderAction extends StatelessWidget {
  const _HeaderAction({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
    this.label,
  });

  final String tooltip;
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return IconButton(
        tooltip: tooltip,
        color: AppTheme.paper,
        onPressed: onPressed,
        icon: Icon(icon),
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label!),
      style: TextButton.styleFrom(foregroundColor: AppTheme.paper),
    );
  }
}

class _CartHeaderAction extends StatelessWidget {
  const _CartHeaderAction({required this.quantity, required this.compact});

  final int quantity;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Badge(
      isLabelVisible: quantity > 0,
      label: Text(quantity > 99 ? '99+' : '$quantity'),
      offset: compact ? const Offset(-2, 5) : const Offset(-3, 7),
      backgroundColor: AppTheme.vermilion,
      child: _HeaderAction(
        tooltip: 'Giỏ hàng ($quantity món)',
        icon: Icons.shopping_cart_outlined,
        label: compact ? null : 'Giỏ',
        onPressed: () => context.go('/dining/cart'),
      ),
    );
  }
}

class _MenuWorkspace extends ConsumerWidget {
  const _MenuWorkspace({
    required this.menu,
    required this.showCategories,
    required this.onProductAdded,
  });

  final List<SushiProduct> menu;
  final bool showCategories;
  final Future<void> Function(SushiProduct product) onProductAdded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(diningMenuCategoryProvider);
    final searchQuery = ref.watch(diningMenuSearchQueryProvider).toLowerCase();
    final categories =
        menu.map((product) => product.categoryId).toSet().toList()..sort();

    var filteredMenu = menu;
    if (searchQuery.isNotEmpty) {
      filteredMenu = filteredMenu
          .where((product) => product.name.toLowerCase().contains(searchQuery))
          .toList();
    }
    if (selectedCategory != null && selectedCategory.isNotEmpty) {
      filteredMenu = filteredMenu
          .where((product) => product.categoryId == selectedCategory)
          .toList();
    }

    return Row(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          width: showCategories ? 190 : 0,
          child: showCategories
              ? ClipRect(
                  child: OverflowBox(
                    alignment: Alignment.topLeft,
                    minWidth: 190,
                    maxWidth: 190,
                    child: _CategoryRail(
                      categories: categories,
                      selectedCategory: selectedCategory,
                    ),
                  ),
                )
              : null,
        ),
        Expanded(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Tìm kiếm món ăn...',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: ref
                      .read(diningMenuSearchQueryProvider.notifier)
                      .updateQuery,
                ),
              ),
              Expanded(
                child: filteredMenu.isEmpty
                    ? const EmptyStateView(
                        message: 'Không tìm thấy món ăn phù hợp.',
                      )
                    : LayoutBuilder(
                        builder: (context, constraints) {
                          final compact = constraints.maxWidth < 700;
                          final columnCount = switch (constraints.maxWidth) {
                            < 480 => 1,
                            < 720 => 2,
                            < 1000 => 3,
                            _ => 4,
                          };
                          return GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: columnCount,
                                  mainAxisExtent: compact ? 250 : 280,
                                  crossAxisSpacing: 18,
                                  mainAxisSpacing: 18,
                                ),
                            itemCount: filteredMenu.length,
                            itemBuilder: (context, index) {
                              final product = filteredMenu[index];
                              return SushiProductDiningGridItem(
                                product: product,
                                onAddToCart: () => onProductAdded(product),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CategoryRail extends ConsumerWidget {
  const _CategoryRail({
    required this.categories,
    required this.selectedCategory,
  });

  final List<String> categories;
  final String? selectedCategory;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entries = <String?>[null, ...categories];

    return Container(
      width: 190,
      color: AppTheme.paper,
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('DANH MỤC', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 18),
          Expanded(
            child: ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final category = entries[index];
                final selected = selectedCategory == category;
                return OutlinedButton(
                  onPressed: () => ref
                      .read(diningMenuCategoryProvider.notifier)
                      .updateCategory(category),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: selected
                        ? AppTheme.vermilion
                        : AppTheme.paper,
                    foregroundColor: selected ? AppTheme.paper : AppTheme.ink,
                    side: BorderSide(
                      color: selected ? AppTheme.vermilion : AppTheme.ink,
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      category == null ? 'TẤT CẢ' : category.toUpperCase(),
                      maxLines: 1,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
