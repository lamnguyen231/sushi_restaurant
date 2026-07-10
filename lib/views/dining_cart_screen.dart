import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/providers/local_providers.dart';
import '../core/providers/firebase_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/cart_item.dart';
import '../models/dining_session.dart';
import '../viewmodels/dining_cart_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/primary_button.dart';

class DiningCartScreen extends ConsumerWidget {
  const DiningCartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentDiningSessionProvider);
    
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Giỏ hàng tại bàn')),
        body: const EmptyStateView(message: 'Không tìm thấy phiên làm việc. Hãy yêu cầu nhân viên mở bàn.'),
      );
    }

    final cartAsync = ref.watch(diningCartViewModelProvider(session.id));

    return Scaffold(
      appBar: AppBar(
        title: const Text('GIỎ HÀNG TẠM'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dining/menu'),
        ),
      ),
      body: cartAsync.when(
        loading: () => const LoadingView(message: 'Đang tải giỏ hàng...'),
        error: (error, stack) => ErrorView(message: 'Lỗi tải giỏ hàng: $error'),
        data: (state) {
          if (state.items.isEmpty) {
            return const EmptyStateView(message: 'Giỏ hàng đang trống. Hãy chọn món thêm nhé!');
          }
          
          return Column(
            children: [
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.all(24),
                  itemCount: state.items.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final item = state.items[index];
                    return _CartItemTile(
                      item: item,
                      sessionId: session.id,
                    );
                  },
                ),
              ),
              _CheckoutBottomBar(
                totalQuantity: state.totalQuantity,
                totalPrice: state.totalPrice,
                onCheckout: () => _submitOrder(context, ref, state, session),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _submitOrder(BuildContext context, WidgetRef ref, DiningCartState state, DiningSession session) async {
    final repo = ref.read(orderRepositoryProvider);
    
    final cartItems = state.items.map<CartItem>((i) => CartItem(
      id: null,
      sessionId: session.id,
      productId: i.product.id,
      name: i.product.name,
      unitPrice: i.product.price,
      quantity: i.localItem.quantity,
      lineTotal: i.product.price * i.localItem.quantity,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    )).toList();

    try {
      await repo.placeDineInOrder(
        sessionId: session.id,
        tableId: session.tableId,
        tableName: session.tableName,
        cartItems: cartItems,
      );
      
      await ref.read(diningCartViewModelProvider(session.id).notifier).clearCart();
      
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi order xuống bếp!')),
      );
      context.go('/dining/orders');
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi gửi order: $e')),
      );
    }
  }
}

class _CartItemTile extends ConsumerWidget {
  const _CartItemTile({required this.item, required this.sessionId});

  final DiningCartItem item;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final product = item.product;
    final qty = item.localItem.quantity;
    
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            product.imageUrl ?? '',
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              color: AppTheme.rice,
              child: const Icon(Icons.image_not_supported, color: AppTheme.mutedInk),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(product.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                formatCurrency.format(product.price),
                style: const TextStyle(color: AppTheme.vermilion, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () {
                ref.read(diningCartViewModelProvider(sessionId).notifier).updateQuantity(product.id, qty - 1);
              },
            ),
            Text('$qty', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () {
                ref.read(diningCartViewModelProvider(sessionId).notifier).updateQuantity(product.id, qty + 1);
              },
            ),
          ],
        )
      ],
    );
  }
}

class _CheckoutBottomBar extends StatelessWidget {
  const _CheckoutBottomBar({
    required this.totalQuantity,
    required this.totalPrice,
    required this.onCheckout,
  });

  final int totalQuantity;
  final double totalPrice;
  final VoidCallback onCheckout;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.paper,
        border: const Border(top: BorderSide(color: AppTheme.rice)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Tổng tiền tạm tính:', style: TextStyle(fontSize: 16)),
                Text(
                  formatCurrency.format(totalPrice),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.vermilion),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: PrimaryButton(
                label: 'GỬI ORDER XUỐNG BẾP ($totalQuantity món)',
                onPressed: onCheckout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
