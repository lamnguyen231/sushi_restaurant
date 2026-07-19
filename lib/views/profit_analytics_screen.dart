import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class ProfitAnalyticsScreen extends ConsumerWidget {
  const ProfitAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(allOrdersProvider);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        title: const Text('PHÂN TÍCH LỢI NHUẬN & CHI PHÍ', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16161B),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/manager/dashboard'),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const LoadingView(message: 'Đang tải thông tin tài chính...'),
        error: (error, stack) => ErrorView(message: 'Lỗi tải thông tin tài chính: $error'),
        data: (orders) {
          final completedOrders = orders.where((o) =>
              o.status == DineInOrderStatus.served ||
              o.status == DineInOrderStatus.completed).toList();

          if (completedOrders.isEmpty) {
            return const Center(
              child: EmptyStateView(
                message: 'Chưa có đơn hàng hoàn thành để thực hiện phân tích lợi nhuận.',
              ),
            );
          }

          // 1. Tính toán doanh thu
          final double revenue = completedOrders.fold<double>(0, (sum, o) => sum + o.grandTotal);
          
          // 2. Tính toán chi phí nguyên vật liệu (COGS = 45% Revenue)
          final double cogs = revenue * 0.45;

          // 3. Lợi nhuận gộp (Gross Profit)
          final double grossProfit = revenue - cogs;
          const double marginPercent = 55.0; // Gross Profit %

          // 4. Phân rã đóng góp theo danh mục món ăn (Category Breakdown)
          final Map<String, double> categorySales = {};
          for (final o in completedOrders) {
            for (final item in o.items) {
              // Phân loại danh mục dựa trên productId hoặc categoryId (Mock theo tiền tố nếu không có category name)
              final cat = item.productId.contains('drink') || item.productName.toLowerCase().contains('nước') || item.productName.toLowerCase().contains('trà')
                  ? 'Đồ uống'
                  : (item.productName.toLowerCase().contains('sashimi') ? 'Sashimi' : 'Sushi & Rolls');
              
              categorySales[cat] = (categorySales[cat] ?? 0) + item.lineTotal;
            }
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // KPI Financial summary
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.sizeOf(context).width < 600 ? 1 : 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 2.2,
                  children: [
                    _buildFinancialCard(
                      'TỔNG DOANH THU (REVENUE)',
                      formatCurrency.format(revenue),
                      '100%',
                      const Color(0xFF3B82F6),
                    ),
                    _buildFinancialCard(
                      'CHI PHÍ NGUYÊN LIỆU (COGS)',
                      formatCurrency.format(cogs),
                      '45%',
                      const Color(0xFFEF4444),
                    ),
                    _buildFinancialCard(
                      'LỢI NHUẬN GỘP (GROSS PROFIT)',
                      formatCurrency.format(grossProfit),
                      '$marginPercent%',
                      const Color(0xFF10B981),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Revenue vs Cost vs Profit chart comparison
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
                        'BIỂU ĐỒ SO SÁNH TÀI CHÍNH',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Horizontal bars comparison
                      _buildComparisonBar(
                        context,
                        label: 'Doanh thu',
                        value: formatCurrency.format(revenue),
                        percentage: 1.0,
                        color: const Color(0xFF3B82F6),
                      ),
                      const SizedBox(height: 20),
                      _buildComparisonBar(
                        context,
                        label: 'Chi phí (COGS)',
                        value: formatCurrency.format(cogs),
                        percentage: 0.45,
                        color: const Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 20),
                      _buildComparisonBar(
                        context,
                        label: 'Lợi nhuận gộp',
                        value: formatCurrency.format(grossProfit),
                        percentage: 0.55,
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Profit contributions by category table
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
                        'ĐÓNG GÓP DOANH THU & LỢI NHUẬN THEO NHÓM',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Table(
                        columnWidths: const {
                          0: FlexColumnWidth(2),
                          1: FlexColumnWidth(2),
                          2: FlexColumnWidth(2),
                          3: FlexColumnWidth(2),
                        },
                        children: [
                          const TableRow(
                            decoration: BoxDecoration(
                              border: Border(bottom: BorderSide(color: Color(0xFF2D2D35), width: 1.5)),
                            ),
                            children: [
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: Text('Nhóm món', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: Text('Doanh thu', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: Text('Chi phí (45%)', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                              Padding(
                                padding: EdgeInsets.only(bottom: 12.0),
                                child: Text('Lợi nhuận gộp', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                              ),
                            ],
                          ),
                          ...categorySales.entries.map((entry) {
                            final catName = entry.key;
                            final catRevenue = entry.value;
                            final catCogs = catRevenue * 0.45;
                            final catProfit = catRevenue - catCogs;

                            return TableRow(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFF23232C), width: 1)),
                              ),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(catName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(formatCurrency.format(catRevenue), style: const TextStyle(color: Colors.white, fontSize: 14)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(formatCurrency.format(catCogs), style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                                  child: Text(
                                    formatCurrency.format(catProfit),
                                    style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
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

  Widget _buildFinancialCard(String title, String value, String ratio, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF23232C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  ratio,
                  style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonBar(
    BuildContext context, {
    required String label,
    required String value,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500, fontSize: 14)),
            Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final double fullWidth = constraints.maxWidth;
            final double barWidth = fullWidth * percentage;

            return Stack(
              children: [
                Container(
                  height: 16,
                  width: fullWidth,
                  decoration: BoxDecoration(
                    color: const Color(0xFF23232C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                Container(
                  height: 16,
                  width: barWidth,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
