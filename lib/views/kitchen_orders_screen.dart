import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../models/restaurant_order.dart';
import '../viewmodels/kitchen_orders_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class KitchenOrdersScreen extends ConsumerStatefulWidget {
  const KitchenOrdersScreen({super.key});

  @override
  ConsumerState<KitchenOrdersScreen> createState() => _KitchenOrdersScreenState();
}

class _KitchenOrdersScreenState extends ConsumerState<KitchenOrdersScreen> {
  String? _selectedOrderId;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(kitchenOrdersViewModelProvider);

    return Theme(
      data: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          foregroundColor: Colors.white,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BẾP - HỆ THỐNG HIỂN THỊ ĐƠN HÀNG (KDS)'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go('/'),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => ref.invalidate(kitchenOrdersViewModelProvider),
            ),
          ],
        ),
        body: ordersAsync.when(
          loading: () => const LoadingView(message: 'Đang tải danh sách đơn hàng cho bếp...'),
          error: (err, stack) => ErrorView(message: 'Lỗi tải đơn hàng: $err'),
          data: (orders) {
            if (orders.isEmpty) {
              return const Center(
                child: EmptyStateView(
                  message: 'Không có đơn hàng nào cần chuẩn bị trong bếp lúc này!',
                ),
              );
            }

            // Tự động chọn đơn hàng đầu tiên nếu chưa chọn hoặc đơn cũ đã hoàn thành
            final activeIds = orders.map((o) => o.id).toList();
            if (_selectedOrderId == null || !activeIds.contains(_selectedOrderId)) {
              _selectedOrderId = orders.first.id;
            }

            final selectedOrder = orders.firstWhere((o) => o.id == _selectedOrderId);

            return Row(
              children: [
                // Cột trái: Danh sách đơn hàng
                SizedBox(
                  width: 360,
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(right: BorderSide(color: Color(0xFF2D2D2D))),
                      color: Color(0xFF181818),
                    ),
                    child: ListView.builder(
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final isSelected = order.id == _selectedOrderId;
                        final duration = DateTime.now().difference(order.createdAt);
                        final durationText = duration.inMinutes > 0 
                            ? '${duration.inMinutes} phút trước' 
                            : 'Vừa xong';

                        return Container(
                          color: isSelected ? const Color(0xFF2D2D2D) : Colors.transparent,
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  order.tableName ?? 'Bàn ${order.tableId ?? "Không tên"}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                _buildStatusBadge(order.status),
                              ],
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${order.items.length} món • $durationText',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                  Text(
                                    '#${order.id.substring(0, 5).toUpperCase()}',
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                _selectedOrderId = order.id;
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // Cột phải: Panel chi tiết đơn hàng (P3-10)
                Expanded(
                  child: Container(
                    color: const Color(0xFF121212),
                    child: _buildOrderDetailPanel(selectedOrder),
                  ),
                ),
              ],
            );
          },
        ),
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
        text = 'Đã nhận';
        break;
      case DineInOrderStatus.preparing:
        color = Colors.orange;
        text = 'Đang làm';
        break;
      case DineInOrderStatus.ready:
        color = Colors.green;
        text = 'Hoàn thành';
        break;
      default:
        color = Colors.grey;
        text = status.name.toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color, width: 1.5),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.bold),
      ),
    );
  }

  // P3-10: Màn hình chi tiết đơn hàng cho bếp
  Widget _buildOrderDetailPanel(RestaurantOrder order) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedTime = DateFormat('HH:mm:ss dd/MM').format(order.createdAt);

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header chi tiết đơn hàng
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.tableName ?? 'Bàn ${order.tableId ?? "Không tên"}',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Thời gian đặt: $formattedTime | Đơn: #${order.id.toUpperCase()}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              _buildActionButtons(order),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Color(0xFF2D2D2D)),
          const SizedBox(height: 16),
          
          // Danh sách các món ăn trong đơn
          const Text(
            'DANH SÁCH MÓN ĂN',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.5),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.separated(
              itemCount: order.items.length,
              separatorBuilder: (context, index) => const Divider(color: Color(0xFF1E1E1E)),
              itemBuilder: (context, index) {
                final item = order.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Số lượng món
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.vermilion,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'x${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Tên món + Ghi chú
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.productName,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            if (item.note != null && item.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 6.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2C1C1A),
                                    border: Border.all(color: Colors.red.shade900.withOpacity(0.5)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 16),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Ghi chú: ${item.note}',
                                        style: const TextStyle(color: Colors.amber, fontStyle: FontStyle.italic, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Giá món (Snapshot)
                      Text(
                        formatCurrency.format(item.lineTotal),
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // Footer
          const Divider(color: Color(0xFF2D2D2D)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng tiền tạm tính:',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                formatCurrency.format(order.grandTotal),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.vermilion),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // P3-09: Xử lý nút thay đổi trạng thái của đơn bếp
  Widget _buildActionButtons(RestaurantOrder order) {
    final notifier = ref.read(kitchenOrdersViewModelProvider.notifier);

    switch (order.status) {
      case DineInOrderStatus.pending:
        return Row(
          children: [
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              onPressed: () => notifier.updateStatus(order.id, DineInOrderStatus.rejected),
              child: const Text('TỪ CHỐI'),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              ),
              onPressed: () => notifier.updateStatus(order.id, DineInOrderStatus.accepted),
              child: const Text('NHẬN ĐƠN'),
            ),
          ],
        );
      case DineInOrderStatus.accepted:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () => notifier.updateStatus(order.id, DineInOrderStatus.preparing),
          child: const Text('BẮT ĐẦU CHẾ BIẾN'),
        );
      case DineInOrderStatus.preparing:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () => notifier.updateStatus(order.id, DineInOrderStatus.ready),
          child: const Text('HOÀN THÀNH MÓN'),
        );
      case DineInOrderStatus.ready:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          onPressed: () => notifier.updateStatus(order.id, DineInOrderStatus.served),
          child: const Text('ĐÃ PHỤC VỤ (SERVED)'),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
