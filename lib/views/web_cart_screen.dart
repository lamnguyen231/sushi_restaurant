import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../viewmodels/web_cart_view_model.dart';
import '../widgets/sushi_nav_bar.dart';

class WebCartScreen extends ConsumerWidget {
  const WebCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(webCartViewModelProvider);

    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: cart.isEmpty
          ? const _EmptyCartView()
          : _CartBody(cart: cart),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyCartView extends StatelessWidget {
  const _EmptyCartView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: AppTheme.rice,
          ),
          const SizedBox(height: 20),
          Text(
            'Giỏ hàng trống',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.mutedInk,
                ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy thêm món ăn từ thực đơn để bắt đầu.',
            style: TextStyle(color: AppTheme.mutedInk, fontSize: 14),
          ),
          const SizedBox(height: 28),
          OutlinedButton.icon(
            onPressed: () => context.go('/web/menu'),
            icon: const Icon(Icons.restaurant_menu, size: 16),
            label: const Text('XEM THỰC ĐƠN'),
          ),
        ],
      ),
    );
  }
}

// ── Cart Body ─────────────────────────────────────────────────────────────────

class _CartBody extends ConsumerWidget {
  const _CartBody({required this.cart});

  final WebCartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return isWide
        ? _WideLayout(cart: cart)
        : _NarrowLayout(cart: cart);
  }
}

// ── Wide layout: list | summary ───────────────────────────────────────────────

class _WideLayout extends StatelessWidget {
  const _WideLayout({required this.cart});
  final WebCartState cart;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: _CartItemList(items: cart.items),
        ),
        const SizedBox(width: 1),
        SizedBox(
          width: 340,
          child: _OrderSummary(cart: cart),
        ),
      ],
    );
  }
}

// ── Narrow layout: stacked ────────────────────────────────────────────────────

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({required this.cart});
  final WebCartState cart;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _CartItemList(items: cart.items, shrinkWrap: true),
          _OrderSummary(cart: cart),
        ],
      ),
    );
  }
}

// ── Cart Item List ────────────────────────────────────────────────────────────

class _CartItemList extends StatelessWidget {
  const _CartItemList({required this.items, this.shrinkWrap = false});

  final List<WebCartItem> items;
  final bool shrinkWrap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: shrinkWrap ? MainAxisSize.min : MainAxisSize.max,
      children: [
        // Header
        Container(
          color: AppTheme.ink,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          child: Row(
            children: [
              Text(
                'GIỎ HÀNG  ·  ${items.length} SẢN PHẨM',
                style: const TextStyle(
                  color: AppTheme.paper,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.2,
                ),
              ),
            ],
          ),
        ),
        // Items
        if (shrinkWrap)
          ...items.map((item) => _CartItemTile(item: item))
        else
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (_, i) => _CartItemTile(item: items[i]),
            ),
          ),
      ],
    );
  }
}

// ── Cart Item Tile ────────────────────────────────────────────────────────────

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item});

  final WebCartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(webCartViewModelProvider.notifier);
    final product = item.product;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.paper,
        border: Border(bottom: BorderSide(color: AppTheme.rice)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image thumbnail
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              border: Border.all(color: AppTheme.rice),
              color: AppTheme.eggshell,
            ),
            child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                ? Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.restaurant, color: AppTheme.rice),
                  )
                : const Icon(Icons.restaurant, size: 32, color: AppTheme.rice),
          ),
          const SizedBox(width: 16),

          // Name + category
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontSize: 15,
                      ),
                ),
                const SizedBox(height: 3),
                Text(
                  product.categoryId.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.mutedInk,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${product.price.toStringAsFixed(0)}đ / phần',
                  style: const TextStyle(
                    color: AppTheme.vermilion,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Quantity selector
          _QuantitySelector(
            quantity: item.quantity,
            onDecrement: () => vm.updateQuantity(product.id, item.quantity - 1, note: item.note),
            onIncrement: () => vm.updateQuantity(product.id, item.quantity + 1, note: item.note),
          ),
          const SizedBox(width: 20),

          // Line total
          SizedBox(
            width: 90,
            child: Text(
              '${item.lineTotal.toStringAsFixed(0)}đ',
              textAlign: TextAlign.right,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.ink,
                  ),
            ),
          ),
          const SizedBox(width: 8),

          // Delete button
          IconButton(
            tooltip: 'Xóa khỏi giỏ',
            icon: const Icon(Icons.delete_outline, size: 20),
            color: AppTheme.vermilion,
            onPressed: () => _confirmRemove(context, ref, product.id, product.name, item.note),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmRemove(
    BuildContext context,
    WidgetRef ref,
    String productId,
    String productName,
    String? note,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _RemoveConfirmDialog(productName: productName),
    );
    if (confirmed == true) {
      ref.read(webCartViewModelProvider.notifier).removeItem(productId, note: note);
    }
  }
}

// ── Quantity Selector ─────────────────────────────────────────────────────────

class _QuantitySelector extends StatelessWidget {
  const _QuantitySelector({
    required this.quantity,
    required this.onDecrement,
    required this.onIncrement,
  });

  final int quantity;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppTheme.rice),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _QtyBtn(
            icon: quantity <= 1 ? Icons.delete_outline : Icons.remove,
            color: quantity <= 1 ? AppTheme.vermilion : AppTheme.ink,
            onTap: onDecrement,
          ),
          Container(
            width: 40,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: const BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(color: AppTheme.rice),
              ),
            ),
            child: Text(
              '$quantity',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: AppTheme.ink,
              ),
            ),
          ),
          _QtyBtn(
            icon: Icons.add,
            color: AppTheme.ink,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatefulWidget {
  const _QtyBtn({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_QtyBtn> createState() => _QtyBtnState();
}

class _QtyBtnState extends State<_QtyBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          width: 36,
          height: 36,
          color: _hovered ? AppTheme.eggshell : Colors.transparent,
          child: Icon(widget.icon, size: 16, color: widget.color),
        ),
      ),
    );
  }
}

// ── Order Summary ─────────────────────────────────────────────────────────────

class _OrderSummary extends ConsumerWidget {
  const _OrderSummary({required this.cart});

  final WebCartState cart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      color: AppTheme.paper,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              color: AppTheme.eggshell,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              child: const Text(
                'TỔNG ĐƠN HÀNG',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.4,
                  color: AppTheme.mutedInk,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Items summary
                  ...cart.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${item.product.name}  ×${item.quantity}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppTheme.mutedInk,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${item.lineTotal.toStringAsFixed(0)}đ',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                  const Divider(color: AppTheme.rice, height: 1),
                  const SizedBox(height: 16),

                  // Subtotal
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Tổng cộng',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.mutedInk,
                        ),
                      ),
                      Text(
                        '${cart.subtotal.toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.mutedInk,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'THÀNH TIỀN',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 15,
                            ),
                      ),
                      Text(
                        '${cart.subtotal.toStringAsFixed(0)}đ',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.vermilion,
                              fontSize: 20,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Checkout button
                  ElevatedButton(
                    onPressed: () => context.go('/web/checkout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.vermilion,
                      foregroundColor: Colors.white,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 2.4,
                      ),
                    ),
                    child: const Text('TIẾN HÀNH THANH TOÁN'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: () => context.go('/web/menu'),
                    child: const Text('TIẾP TỤC MUA'),
                  ),
                  const SizedBox(height: 16),

                  // Clear cart
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _confirmClear(context, ref),
                      icon: const Icon(Icons.delete_sweep_outlined, size: 15),
                      label: const Text('Xóa toàn bộ giỏ hàng'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.mutedInk,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => const _ClearCartDialog(),
    );
    if (confirmed == true) {
      ref.read(webCartViewModelProvider.notifier).clearCart();
    }
  }
}

// ── Dialogs ───────────────────────────────────────────────────────────────────

class _RemoveConfirmDialog extends StatelessWidget {
  const _RemoveConfirmDialog({required this.productName});
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
          children: [
            const Icon(Icons.remove_shopping_cart_outlined,
                size: 44, color: AppTheme.vermilion),
            const SizedBox(height: 14),
            Text(
              'Xóa khỏi giỏ hàng?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '"$productName" sẽ bị xóa khỏi giỏ hàng.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.mutedInk, fontSize: 14),
            ),
            const SizedBox(height: 22),
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
                          borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 14),
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

class _ClearCartDialog extends StatelessWidget {
  const _ClearCartDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.delete_sweep_outlined,
                size: 44, color: AppTheme.vermilion),
            const SizedBox(height: 14),
            Text(
              'Xóa toàn bộ giỏ hàng?',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Tất cả sản phẩm trong giỏ sẽ bị xóa.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedInk, fontSize: 14),
            ),
            const SizedBox(height: 22),
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
                          borderRadius: BorderRadius.zero),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'XÓA TẤT CẢ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.6,
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
