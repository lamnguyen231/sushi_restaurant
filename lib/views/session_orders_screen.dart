import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/local_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/restaurant_order.dart';
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
        appBar: AppBar(title: const Text('Lịch sử gọi món')),
        body: const EmptyStateView(
          message: 'Không tìm thấy phiên làm việc. Hãy liên hệ nhân viên để mở bàn.',
        ),
      );
    }

    final ordersAsync = ref.watch(sessionPlacedOrdersProvider(session.id));
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text('ĐƠN ĐÃ GỬI BẾP - ${session.tableName.toUpperCase()}'),
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/dining/menu'),
          ),
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
          loading: () => const LoadingView(message: 'Đang tải lịch sử gọi món...'),
          error: (error, stack) => ErrorView(message: 'Lỗi tải lịch sử: $error'),
          data: (orders) {
            if (orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyStateView(
                      message: 'Bàn chưa đặt món ăn nào.\nHãy quay lại menu để gọi món nhé!',
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => context.go('/dining/menu'),
                      child: const Text('QUAY LẠI MENU'),
                    ),
                  ],
                ),
              );
            }

            final activeOrders = orders.where((o) =>
                o.status != DineInOrderStatus.cancelled &&
                o.status != DineInOrderStatus.rejected);
            
            final sessionTotal = activeOrders.fold<double>(
              0,
              (sum, order) => sum + order.grandTotal,
            );

            return Column(
              children: [
                // Thông tin tóm tắt phiên đặt món
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'TÓM TẮT PHIÊN ĂN',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.mutedInk,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Số lượng đơn đã gửi: ${orders.length} đơn',
                            style: const TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'TỔNG TIỀN TẠM TÍNH:',
                            style: TextStyle(fontSize: 13, color: AppTheme.mutedInk),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatCurrency.format(sessionTotal),
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.vermilion,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: AppTheme.rice),

                // Danh sách các đơn đã đặt
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return _OrderHistoryCard(order: order);
                    },
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

class _OrderHistoryCard extends StatelessWidget {
  const _OrderHistoryCard({required this.order});
  final RestaurantOrder order;

  @override
  Widget build(BuildContext context) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final timeStr = DateFormat('HH:mm').format(order.createdAt);

    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Đơn hàng
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.receipt_long, color: AppTheme.mutedInk, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Đơn lúc $timeStr',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '#${order.id.substring(0, 6).toUpperCase()}',
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ),
                _buildStatusBadge(order.status),
              ],
            ),
          ),
          
          // Chi tiết món ăn trong đơn
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ...order.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Text(
                              '${item.quantity}x',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.vermilion,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                                  ),
                                  if (item.note != null && item.note!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        'Ghi chú: ${item.note}',
                                        style: TextStyle(
                                          color: Colors.amber.shade900,
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        formatCurrency.format(item.lineTotal),
                        style: const TextStyle(fontSize: 15),
                      ),
                    ],
                  ),
                )),
                const Divider(height: 24, color: AppTheme.rice),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tạm tính đơn này:', style: TextStyle(color: AppTheme.mutedInk)),
                    Text(
                      formatCurrency.format(order.grandTotal),
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(DineInOrderStatus status) {
    Color color;
    String text;
    switch (status) {
      case DineInOrderStatus.pending:
        color = Colors.amber;
        text = 'Chờ nhận';
        break;
      case DineInOrderStatus.accepted:
        color = Colors.blue;
        text = 'Bếp đã nhận';
        break;
      case DineInOrderStatus.preparing:
        color = Colors.orange;
        text = 'Đang chế biến';
        break;
      case DineInOrderStatus.ready:
        color = Colors.green;
        text = 'Đang giao món';
        break;
      case DineInOrderStatus.served:
        color = Colors.teal;
        text = 'Đã phục vụ';
        break;
      case DineInOrderStatus.cancelled:
        color = Colors.red;
        text = 'Đã hủy';
        break;
      case DineInOrderStatus.rejected:
        color = Colors.red;
        text = 'Bị từ chối';
        break;
      default:
        color = Colors.grey;
        text = status.name;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
