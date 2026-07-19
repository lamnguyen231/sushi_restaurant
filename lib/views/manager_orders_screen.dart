import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/firebase_providers.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class ManagerOrdersScreen extends ConsumerStatefulWidget {
  const ManagerOrdersScreen({super.key});

  @override
  ConsumerState<ManagerOrdersScreen> createState() => _ManagerOrdersScreenState();
}

class _ManagerOrdersScreenState extends ConsumerState<ManagerOrdersScreen> {
  String _searchQuery = '';
  String _selectedStatusFilter = 'all'; // 'all', 'pending', 'preparing', 'ready', 'served', 'cancelled'
  String? _expandedOrderId;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        title: const Text('QUẢN LÝ ĐƠN HÀNG TOÀN HỆ THỐNG', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5)),
        backgroundColor: const Color(0xFF16161B),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/manager/dashboard'),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const LoadingView(message: 'Đang tải danh sách đơn hàng...'),
        error: (error, stack) => ErrorView(message: 'Lỗi tải đơn hàng: $error'),
        data: (orders) {
          // 1. Filter by search query (Order ID or Table name)
          var filtered = orders.where((o) {
            final matchesQuery = (o.id.toLowerCase().contains(_searchQuery.toLowerCase())) ||
                (o.tableName?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false);
            
            if (!matchesQuery) return false;

            if (_selectedStatusFilter == 'all') return true;
            if (_selectedStatusFilter == 'cancelled') {
              return o.status == DineInOrderStatus.cancelled || o.status == DineInOrderStatus.rejected;
            }
            return o.status.name == _selectedStatusFilter;
          }).toList();

          return Column(
            children: [
              // Search & Filter Panel
              Container(
                color: const Color(0xFF16161B),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  children: [
                    // Search Bar
                    TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Tìm theo mã đơn hoặc tên bàn...',
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        filled: true,
                        fillColor: const Color(0xFF23232C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      ),
                      onChanged: (val) => setState(() => _searchQuery = val),
                    ),
                    const SizedBox(height: 16),
                    // Horizontal status tags filters
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('Tất cả', 'all'),
                          _buildFilterChip('Chờ nhận', 'pending'),
                          _buildFilterChip('Đang chuẩn bị', 'preparing'),
                          _buildFilterChip('Chờ giao', 'ready'),
                          _buildFilterChip('Đã phục vụ', 'served'),
                          _buildFilterChip('Đã hủy/Từ chối', 'cancelled'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Orders List
              Expanded(
                child: filtered.isEmpty
                    ? const Center(
                        child: EmptyStateView(
                          message: 'Không tìm thấy đơn hàng nào phù hợp với bộ lọc.',
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final order = filtered[index];
                          final isExpanded = order.id == _expandedOrderId;
                          final formattedTime = DateFormat('HH:mm - dd/MM/yyyy').format(order.createdAt);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16161B),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: isExpanded ? AppTheme.vermilion : const Color(0xFF23232C),
                                width: isExpanded ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                // Header row clickable to expand
                                InkWell(
                                  onTap: () {
                                    setState(() {
                                      _expandedOrderId = isExpanded ? null : order.id;
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        // Table Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF23232C),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            order.tableName ?? 'Bàn',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Order info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ID: #${order.id.substring(0, 8).toUpperCase()}',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                formattedTime,
                                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Total Price & Status
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.end,
                                          children: [
                                            Text(
                                              formatCurrency.format(order.grandTotal),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            _buildStatusTag(order.status),
                                          ],
                                        ),
                                        const SizedBox(width: 8),
                                        Icon(
                                          isExpanded ? Icons.expand_less : Icons.expand_more,
                                          color: Colors.grey,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Expanded panel detail (SC-19 Details view)
                                if (isExpanded) ...[
                                  const Divider(color: Color(0xFF23232C), height: 1),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Items List title
                                        const Text(
                                          'DANH SÁCH MÓN ĂN',
                                          style: TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.0,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        ...order.items.map((item) => Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    '${item.quantity}x ${item.productName}',
                                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                                  ),
                                                  Text(
                                                    formatCurrency.format(item.lineTotal),
                                                    style: const TextStyle(color: Colors.white, fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            )),
                                        const Divider(color: Color(0xFF23232C), height: 24),
                                        // Status management panel (allow manual override)
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text(
                                              'THAY ĐỔI TRẠNG THÁI:',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 1.0,
                                              ),
                                            ),
                                            Wrap(
                                              spacing: 8,
                                              children: [
                                                // Cancel action (only if not already completed/served)
                                                if (order.status != DineInOrderStatus.served &&
                                                    order.status != DineInOrderStatus.completed &&
                                                    order.status != DineInOrderStatus.cancelled)
                                                  OutlinedButton(
                                                    style: OutlinedButton.styleFrom(
                                                      foregroundColor: Colors.red,
                                                      side: const BorderSide(color: Colors.red),
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    ),
                                                    onPressed: () => _updateStatus(order.id, DineInOrderStatus.cancelled),
                                                    child: const Text('HỦY ĐƠN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  ),
                                                
                                                // Advance status manually
                                                if (order.status == DineInOrderStatus.pending)
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF3B82F6),
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    ),
                                                    onPressed: () => _updateStatus(order.id, DineInOrderStatus.accepted),
                                                    child: const Text('NHẬN ĐƠN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  )
                                                else if (order.status == DineInOrderStatus.accepted)
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFFF59E0B),
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    ),
                                                    onPressed: () => _updateStatus(order.id, DineInOrderStatus.preparing),
                                                    child: const Text('CHẾ BIẾN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  )
                                                else if (order.status == DineInOrderStatus.preparing)
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: const Color(0xFF10B981),
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    ),
                                                    onPressed: () => _updateStatus(order.id, DineInOrderStatus.ready),
                                                    child: const Text('HOÀN THÀNH', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  )
                                                else if (order.status == DineInOrderStatus.ready)
                                                  ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: AppTheme.vermilion,
                                                      foregroundColor: Colors.white,
                                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                    ),
                                                    onPressed: () => _updateStatus(order.id, DineInOrderStatus.served),
                                                    child: const Text('ĐÃ PHỤC VỤ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ],
                            ),
                          );
                        },
                      ),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedStatusFilter == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = value),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.vermilion : const Color(0xFF23232C),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.vermilion : const Color(0xFF2D2D35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTag(DineInOrderStatus status) {
    Color color;
    String text;

    switch (status) {
      case DineInOrderStatus.pending:
        color = const Color(0xFFF59E0B); // Amber
        text = 'Chờ nhận';
      case DineInOrderStatus.accepted:
        color = const Color(0xFF3B82F6); // Blue
        text = 'Đã nhận';
      case DineInOrderStatus.preparing:
        color = const Color(0xFF8B5CF6); // Purple
        text = 'Đang làm';
      case DineInOrderStatus.ready:
        color = const Color(0xFF10B981); // Emerald
        text = 'Chờ giao';
      case DineInOrderStatus.served:
        color = const Color(0xFF22C55E); // Green
        text = 'Đã phục vụ';
      case DineInOrderStatus.completed:
        color = Colors.grey;
        text = 'Đã đóng';
      case DineInOrderStatus.cancelled:
      case DineInOrderStatus.rejected:
        color = Colors.red;
        text = 'Đã hủy';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Future<void> _updateStatus(String orderId, DineInOrderStatus status) async {
    final repo = ref.read(orderRepositoryProvider);
    try {
      await repo.updateOrderStatus(orderId: orderId, status: status.name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã cập nhật trạng thái đơn thành ${status.name} thành công!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi cập nhật trạng thái: $e')),
      );
    }
  }
}
