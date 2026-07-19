import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class RevenueAnalyticsScreen extends ConsumerWidget {
  const RevenueAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        title: const Text('PHÂN TÍCH DOANH THU & DOANH SỐ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16161B),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/manager/dashboard'),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const LoadingView(message: 'Đang tải dữ liệu phân tích...'),
        error: (error, stack) => ErrorView(message: 'Lỗi tải phân tích: $error'),
        data: (orders) {
          // Lọc các đơn đã hoàn thành/phục vụ thành công
          final completedOrders = orders.where((o) =>
              o.status == DineInOrderStatus.served ||
              o.status == DineInOrderStatus.completed).toList();

          if (completedOrders.isEmpty) {
            return const Center(
              child: EmptyStateView(
                message: 'Chưa có đơn hàng hoàn thành để thực hiện phân tích.',
              ),
            );
          }

          // 1. Phân tích doanh thu 7 ngày gần nhất
          final Map<String, double> last7DaysSales = {};
          final today = DateTime.now();
          for (int i = 6; i >= 0; i--) {
            final date = today.subtract(Duration(days: i));
            final dateStr = DateFormat('dd/MM').format(date);
            last7DaysSales[dateStr] = 0;
          }

          for (final o in completedOrders) {
            final dateStr = DateFormat('dd/MM').format(o.createdAt);
            if (last7DaysSales.containsKey(dateStr)) {
              last7DaysSales[dateStr] = last7DaysSales[dateStr]! + o.grandTotal;
            }
          }

          // Tìm doanh thu lớn nhất trong 7 ngày để scale chiều cao cột
          final maxDayRevenue = last7DaysSales.values.fold<double>(
            100000, // Giá trị tối thiểu để tránh chia cho 0
            (max, v) => v > max ? v : max,
          );

          // 2. Thống kê món ăn bán chạy nhất (Top Selling Products)
          final Map<String, _ProductSalesStats> productStatsMap = {};
          for (final o in completedOrders) {
            for (final item in o.items) {
              if (productStatsMap.containsKey(item.productId)) {
                final existing = productStatsMap[item.productId]!;
                productStatsMap[item.productId] = _ProductSalesStats(
                  name: existing.name,
                  quantity: existing.quantity + item.quantity,
                  totalSales: existing.totalSales + item.lineTotal,
                );
              } else {
                productStatsMap[item.productId] = _ProductSalesStats(
                  name: item.productName,
                  quantity: item.quantity,
                  totalSales: item.lineTotal,
                );
              }
            }
          }

          final topSellingList = productStatsMap.values.toList()
            ..sort((a, b) => b.quantity.compareTo(a.quantity));
          final topSellingLimited = topSellingList.take(5).toList();

          // 3. Doanh thu tổng cộng & Giá trị đơn TB (AOV)
          final totalRevenue = completedOrders.fold<double>(0, (sum, o) => sum + o.grandTotal);
          final aov = completedOrders.isEmpty ? 0.0 : totalRevenue / completedOrders.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Summary Row
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricCard(
                        'Tổng doanh thu tích lũy',
                        formatCurrency.format(totalRevenue),
                        Icons.payments,
                        const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricCard(
                        'Giá trị đơn trung bình (AOV)',
                        formatCurrency.format(aov),
                        Icons.shopping_bag,
                        const Color(0xFF3B82F6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 7-day Revenue Bar Chart (Custom Widget)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF23232C)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DOANH THU 7 NGÀY GẦN NHẤT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        height: 200,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: last7DaysSales.entries.map((entry) {
                            final date = entry.key;
                            final value = entry.value;
                            // Tính chiều cao cột theo tỷ lệ %
                            final double heightPercentage = value / maxDayRevenue;
                            final double colHeight = (heightPercentage * 160).clamp(8, 160);

                            return Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                // Hiển thị số tiền nhỏ phía trên mỗi cột
                                Text(
                                  value > 0
                                      ? (value >= 1000000
                                          ? '${(value / 1000000).toStringAsFixed(1)}M'
                                          : '${(value / 1000).toStringAsFixed(0)}K')
                                      : '0',
                                  style: const TextStyle(color: Colors.grey, fontSize: 10),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  width: 28,
                                  height: colHeight,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                                      begin: Alignment.bottomCenter,
                                      end: Alignment.topCenter,
                                    ),
                                    borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF10B981).withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  date,
                                  style: const TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Top Selling List (SC-20 Top List)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF23232C)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOP 5 MÓN ĂN BÁN CHẠY NHẤT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 20),
                      if (topSellingLimited.isEmpty)
                        const Center(child: Text('Chưa có số liệu.', style: TextStyle(color: Colors.grey)))
                      else
                        ...topSellingLimited.asMap().entries.map((entry) {
                          final idx = entry.key;
                          final stat = entry.value;
                          final rankColor = idx == 0
                              ? const Color(0xFFF59E0B) // Vàng Nhất
                              : (idx == 1 ? Colors.grey : const Color(0xFFCD7F32)); // Đồng/Bạc

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                // Rank icon or number
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: idx < 3 ? rankColor.withOpacity(0.15) : const Color(0xFF23232C),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '${idx + 1}',
                                      style: TextStyle(
                                        color: idx < 3 ? rankColor : Colors.grey,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Product info
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        stat.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 15,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Đã bán: ${stat.quantity} phần',
                                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                                // Revenue generated
                                Text(
                                  formatCurrency.format(stat.totalSales),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF23232C)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductSalesStats {
  _ProductSalesStats({
    required this.name,
    required this.quantity,
    required this.totalSales,
  });

  final String name;
  final int quantity;
  final double totalSales;
}
