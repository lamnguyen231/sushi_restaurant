import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/providers/local_providers.dart';
import '../models/order_item.dart';
import '../viewmodels/dining_cart_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';
import '../widgets/staff_session_unlock_button.dart';

class SessionOrdersScreen extends ConsumerWidget {
  const SessionOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(currentDiningSessionProvider);
    if (session == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Đơn đã gọi')),
        body: const EmptyStateView(
          message:
              'Không tìm thấy phiên làm việc. Hãy yêu cầu nhân viên mở bàn.',
        ),
      );
    }

    final ordersAsync = ref.watch(sessionPlacedOrdersProvider(session.id));
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Đơn đã gọi - ${session.tableName}'),
          automaticallyImplyLeading: false,
          actions: [
            TextButton.icon(
              onPressed: () => context.go('/dining/menu'),
              icon: const Icon(Icons.restaurant_menu),
              label: const Text('Menu'),
            ),
            TextButton.icon(
              onPressed: () => context.go('/dining/cart'),
              icon: const Icon(Icons.shopping_cart_outlined),
              label: const Text('Giỏ'),
            ),
            StaffSessionUnlockButton(session: session),
          ],
        ),
        body: ordersAsync.when(
          loading: () => const LoadingView(message: 'Đang tải đơn đã gọi...'),
          error: (error, stack) =>
              ErrorView(message: 'Không tải được đơn: $error'),
          data: (orders) {
            if (orders.isEmpty) {
              return const EmptyStateView(
                message: 'Chưa có món nào được gửi bếp.',
              );
            }

            final items = <OrderItem>[];
            for (final order in orders) {
              items.addAll(order.items);
            }
            final total = orders.fold<double>(
              0,
              (sum, order) => sum + order.grandTotal,
            );

            return Column(
              children: [
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.all(24),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        leading: const Icon(Icons.receipt_long),
                        title: Text(item.productName),
                        subtitle: Text('Số lượng: ${item.quantity}'),
                        trailing: Text(currency.format(item.lineTotal)),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Tổng tạm tính',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        currency.format(total),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
