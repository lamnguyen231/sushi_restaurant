import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/firebase_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/cart_item.dart';
import '../models/dining_session.dart';
import '../models/order_item.dart';
import '../repositories/order_repository.dart';
import '../viewmodels/dining_cart_view_model.dart';
import 'error_view.dart';
import 'loading_view.dart';
import 'primary_button.dart';

class DiningCartSidebar extends ConsumerWidget {
  const DiningCartSidebar({super.key, required this.session});

  final DiningSession session;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartAsync = ref.watch(diningCartViewModelProvider(session.id));
    final placedOrdersAsync = ref.watch(
      sessionPlacedOrdersProvider(session.id),
    );

    double placedTotal = 0;
    List<OrderItem> allPlacedItems = [];

    if (placedOrdersAsync.hasValue) {
      final Map<String, OrderItem> groupedItems = {};

      for (final order in placedOrdersAsync.value!) {
        placedTotal += order.subtotal;
        for (final item in order.items) {
          if (groupedItems.containsKey(item.productId)) {
            final existing = groupedItems[item.productId]!;
            groupedItems[item.productId] = OrderItem(
              productId: existing.productId,
              productName: existing.productName,
              unitPrice: existing.unitPrice,
              quantity: existing.quantity + item.quantity,
              lineTotal: existing.lineTotal + item.lineTotal,
              note: existing.note,
            );
          } else {
            groupedItems[item.productId] = item;
          }
        }
      }
      allPlacedItems = groupedItems.values.toList();
    }

    double draftTotal = 0;
    int draftQty = 0;
    if (cartAsync.hasValue) {
      draftTotal = cartAsync.value!.totalPrice;
      draftQty = cartAsync.value!.totalQuantity;
    }

    final grandTotal = placedTotal + draftTotal;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Hóa đơn bàn',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/dining/orders'),
                    icon: const Icon(
                      Icons.receipt_long,
                      size: 18,
                      color: AppTheme.vermilion,
                    ),
                    label: const Text(
                      'Lịch sử đơn',
                      style: TextStyle(
                        color: AppTheme.vermilion,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Order ID: #${session.id.substring(0, 6)}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'Table: ${session.tableName}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),

        Expanded(
          child: CustomScrollView(
            slivers: [
              // --- PHẦN 1: ĐÃ GỌI ---
              if (allPlacedItems.isNotEmpty)
                SliverToBoxAdapter(
                  child: Theme(
                    data: Theme.of(
                      context,
                    ).copyWith(dividerColor: Colors.transparent),
                    child: ExpansionTile(
                      initiallyExpanded: false,
                      tilePadding: const EdgeInsets.symmetric(horizontal: 24),
                      title: Row(
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'ĐÃ GỬI BẾP (${allPlacedItems.length} món)',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      children: allPlacedItems
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: 16,
                                left: 24,
                                right: 24,
                              ),
                              child: _PlacedOrderItemCard(item: item),
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ),

              if (allPlacedItems.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: Divider(),
                  ),
                ),

              // --- PHẦN 2: ĐANG CHỌN (DRAFT) ---
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        color: AppTheme.vermilion,
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'MÓN VỪA CHỌN',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.vermilion,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              cartAsync.when(
                loading: () =>
                    const SliverToBoxAdapter(child: LoadingView(message: '')),
                error: (error, stack) => SliverToBoxAdapter(
                  child: ErrorView(message: 'Lỗi: $error'),
                ),
                data: (state) {
                  if (state.items.isEmpty) {
                    return const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'Giỏ hàng trống.\nHãy chọn món bên trái.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: 24,
                          left: 24,
                          right: 24,
                        ),
                        child: _SidebarCartItem(
                          item: state.items[index],
                          sessionId: session.id,
                        ),
                      );
                    }, childCount: state.items.length),
                  );
                },
              ),
            ],
          ),
        ),

        // --- CHECKOUT BAR ---
        _SidebarCheckoutBar(
          draftQuantity: draftQty,
          totalPrice: grandTotal,
          onCheckout: draftQty == 0
              ? null
              : () {
                  if (cartAsync.hasValue) {
                    _submitOrder(context, ref, cartAsync.value!, session);
                  }
                },
        ),
      ],
    );
  }

  Future<void> _submitOrder(
    BuildContext context,
    WidgetRef ref,
    DiningCartState state,
    DiningSession session,
  ) async {
    final repo = ref.read(orderRepositoryProvider);

    // P3-01/P3-02: Dùng name, unitPrice, lineTotal đã snapshot vào LocalCartItem
    final cartItems = state.items
        .map<CartItem>(
          (i) => CartItem(
            id: null,
            sessionId: session.id,
            productId: i.localItem.productId,
            name: i.localItem.name, // snapshot từ SQLite
            unitPrice: i.localItem.unitPrice, // snapshot từ SQLite
            quantity: i.localItem.quantity,
            lineTotal: i.localItem.lineTotal, // tính lại từ getter
            note: i.localItem.notes,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        )
        .toList();

    try {
      await repo.placeDineInOrder(
        sessionId: session.id,
        tableId: session.tableId,
        tableName: session.tableName,
        cartItems: cartItems,
      );

      await ref
          .read(diningCartViewModelProvider(session.id).notifier)
          .clearCart();

      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã gửi order xuống bếp thành công!')),
      );
    } on OrderQueuedOfflineException catch (error) {
      await ref
          .read(diningCartViewModelProvider(session.id).notifier)
          .clearCart();
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi gửi order: $e')));
    }
  }
}

class _PlacedOrderItemCard extends StatelessWidget {
  const _PlacedOrderItemCard({required this.item});
  final OrderItem item;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Center(child: Icon(Icons.check, color: Colors.green)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.productName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency.format(item.unitPrice),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 4),
              const Text(
                'Đã gửi bếp',
                style: TextStyle(
                  color: Colors.green,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            const Text('x', style: TextStyle(color: Colors.grey)),
            const SizedBox(width: 4),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ],
        ),
      ],
    );
  }
}

class _SidebarCartItem extends ConsumerWidget {
  const _SidebarCartItem({required this.item, required this.sessionId});

  final DiningCartItem item;
  final String sessionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    // P3-02: Dùng name và unitPrice đã snapshot trong LocalCartItem
    final localItem = item.localItem;
    final qty = localItem.quantity;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Placeholder icon vì LocalCartItem không lưu imageUrl
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: AppTheme.rice,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.set_meal, color: AppTheme.mutedInk, size: 28),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                formatCurrency.format(item.unitPrice),
                style: const TextStyle(color: AppTheme.vermilion, fontSize: 13),
              ),
              if (localItem.notes != null && localItem.notes!.isNotEmpty)
                Text(
                  localItem.notes!,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        Row(
          children: [
            InkWell(
              onTap: () => ref
                  .read(diningCartViewModelProvider(sessionId).notifier)
                  .updateQuantity(localItem.productId, qty - 1),
              child: const Icon(
                Icons.remove_circle_outline,
                size: 24,
                color: Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '$qty',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(width: 12),
            InkWell(
              onTap: () => ref
                  .read(diningCartViewModelProvider(sessionId).notifier)
                  .updateQuantity(localItem.productId, qty + 1),
              child: const Icon(
                Icons.add_circle_outline,
                size: 24,
                color: AppTheme.vermilion,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SidebarCheckoutBar extends StatelessWidget {
  const _SidebarCheckoutBar({
    required this.draftQuantity,
    required this.totalPrice,
    this.onCheckout,
  });

  final int draftQuantity;
  final double totalPrice;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng cộng:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  formatCurrency.format(totalPrice),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.vermilion,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: PrimaryButton(
                label: draftQuantity > 0
                    ? 'Gửi bếp ($draftQuantity)'
                    : 'Chưa có món mới',
                onPressed: onCheckout,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
