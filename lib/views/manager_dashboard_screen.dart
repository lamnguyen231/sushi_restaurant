import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/firebase_providers.dart';
import '../viewmodels/table_selection_view_model.dart';
import '../widgets/sushi_nav_bar.dart';

class ManagerDashboardScreen extends ConsumerWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    // 1. Fetch tables state for active tables count
    final tablesAsync = ref.watch(tableSelectionViewModelProvider);

    // 2. Fetch all orders state for today's revenue and pending orders count
    final ordersAsync = ref.watch(allOrdersProvider);

    // 3. Fetch reservations state for today's reservations count
    final reservationsAsync = ref.watch(reservationsStreamProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: const SushiNavBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BẢNG ĐIỀU HÀNH QUẢN LÝ',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hôm nay: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(allOrdersProvider);
                    ref.invalidate(tableSelectionViewModelProvider);
                    ref.invalidate(reservationsStreamProvider);
                  },
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('LÀM MỚI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.vermilion,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Statistics Grid (SC-18 metrics)
            LayoutBuilder(
              builder: (context, constraints) {
                final double itemWidth = constraints.maxWidth < 600
                    ? constraints.maxWidth
                    : (constraints.maxWidth - 48) / 4;

                return Wrap(
                  spacing: 16,
                  runSpacing: 16,
                  children: [
                    // Today's Revenue Card
                    ordersAsync.when(
                      data: (orders) {
                        final today = DateTime.now();
                        final todayOrders = orders.where((o) {
                          return o.createdAt.year == today.year &&
                              o.createdAt.month == today.month &&
                              o.createdAt.day == today.day &&
                              (o.status == DineInOrderStatus.served ||
                                  o.status == DineInOrderStatus.completed);
                        });
                        final totalRevenue = todayOrders.fold<double>(
                          0,
                          (sum, o) => sum + o.grandTotal,
                        );
                        return _buildMetricCard(
                          width: itemWidth,
                          title: 'Doanh thu hôm nay',
                          value: formatCurrency.format(totalRevenue),
                          icon: Icons.monetization_on,
                          color: const Color(0xFF10B981), // Emerald Green
                          subtitle: '${todayOrders.length} đơn đã phục vụ',
                        );
                      },
                      loading: () => _buildMetricLoadingCard(itemWidth, 'Doanh thu hôm nay'),
                      error: (e, s) => _buildMetricErrorCard(itemWidth, 'Doanh thu hôm nay'),
                    ),

                    // Active Occupied Tables Card
                    tablesAsync.when(
                      data: (tables) {
                        final occupied = tables.where((t) => t.status == TableStatus.occupied).length;
                        return _buildMetricCard(
                          width: itemWidth,
                          title: 'Số bàn đang bận',
                          value: '$occupied / ${tables.length}',
                          icon: Icons.table_bar,
                          color: const Color(0xFFF59E0B), // Amber Gold
                          subtitle: 'Đang dùng bữa',
                        );
                      },
                      loading: () => _buildMetricLoadingCard(itemWidth, 'Số bàn đang bận'),
                      error: (e, s) => _buildMetricErrorCard(itemWidth, 'Số bàn đang bận'),
                    ),

                    // Pending Orders Card
                    ordersAsync.when(
                      data: (orders) {
                        final pendingCount = orders
                            .where((o) => o.status == DineInOrderStatus.pending)
                            .length;
                        return _buildMetricCard(
                          width: itemWidth,
                          title: 'Đơn hàng đang chờ',
                          value: '$pendingCount',
                          icon: Icons.kitchen,
                          color: const Color(0xFF3B82F6), // Royal Blue
                          subtitle: 'Đơn chưa nhận vào bếp',
                        );
                      },
                      loading: () => _buildMetricLoadingCard(itemWidth, 'Đơn hàng đang chờ'),
                      error: (e, s) => _buildMetricErrorCard(itemWidth, 'Đơn hàng đang chờ'),
                    ),

                    // Active Reservations Card
                    reservationsAsync.when(
                      data: (reservations) {
                        final today = DateTime.now();
                        final todayReservations = reservations.where((r) {
                          return r.reservationDateTime.year == today.year &&
                              r.reservationDateTime.month == today.month &&
                              r.reservationDateTime.day == today.day &&
                              r.status == ReservationStatus.confirmed;
                        }).length;
                        return _buildMetricCard(
                          width: itemWidth,
                          title: 'Đặt bàn hôm nay',
                          value: '$todayReservations',
                          icon: Icons.event,
                          color: const Color(0xFFEC4899), // Pink
                          subtitle: 'Lượt hẹn đã xác nhận',
                        );
                      },
                      loading: () => _buildMetricLoadingCard(itemWidth, 'Đặt bàn hôm nay'),
                      error: (e, s) => _buildMetricErrorCard(itemWidth, 'Đặt bàn hôm nay'),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 40),
            const Divider(color: Color(0xFF2D2D35), height: 1),
            const SizedBox(height: 40),

            // Quick Navigation & Action Cards
            Text(
              'QUẢN LÝ & PHÂN TÍCH',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
            ),
            const SizedBox(height: 20),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.sizeOf(context).width < 800 ? 1 : 2,
              childAspectRatio: 2.8,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildActionCard(
                  context,
                  title: 'Quản lý đơn hàng',
                  subtitle: 'Theo dõi, tìm kiếm và điều chỉnh toàn bộ đơn hàng trong hệ thống.',
                  icon: Icons.receipt_long,
                  route: '/manager/orders',
                  gradient: const [Color(0xFF6366F1), Color(0xFF4F46E5)], // Indigo
                ),
                _buildActionCard(
                  context,
                  title: 'Phân tích doanh thu',
                  subtitle: 'Xem biểu đồ phát triển doanh số, top món ăn chạy nhất.',
                  icon: Icons.trending_up,
                  route: '/manager/analytics/revenue',
                  gradient: const [Color(0xFF10B981), Color(0xFF059669)], // Emerald
                ),
                _buildActionCard(
                  context,
                  title: 'Báo cáo & Xuất file',
                  subtitle: 'Tạo thống kê chi tiết theo khoảng ngày và tải báo cáo PDF/CSV.',
                  icon: Icons.summarize,
                  route: '/manager/reports',
                  gradient: const [Color(0xFF3B82F6), Color(0xFF2563EB)], // Blue
                ),
                _buildActionCard(
                  context,
                  title: 'Phân tích lợi nhuận',
                  subtitle: 'Phân tích chi phí nguyên vật liệu (COGS) và biên lợi nhuận.',
                  icon: Icons.monetization_on,
                  route: '/manager/analytics/profit',
                  gradient: const [Color(0xFFF59E0B), Color(0xFFD97706)], // Amber
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required double width,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF23232C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricLoadingCard(double width, String title) {
    return Container(
      width: width,
      height: 135,
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF23232C)),
      ),
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildMetricErrorCard(double width, String title) {
    return Container(
      width: width,
      height: 135,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.1)),
      ),
      child: const Center(
        child: Text(
          'Lỗi tải',
          style: TextStyle(color: Colors.red, fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required String route,
    required List<Color> gradient,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF23232C)),
      ),
      child: InkWell(
        onTap: () => context.go(route),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: gradient,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
