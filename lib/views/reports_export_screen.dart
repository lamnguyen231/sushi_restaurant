import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'dart:convert';
import '../services/file_saver/file_saver.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../core/providers/firebase_providers.dart';
import '../widgets/error_view.dart';
import '../widgets/loading_view.dart';

class ReportsExportScreen extends ConsumerStatefulWidget {
  const ReportsExportScreen({super.key});

  @override
  ConsumerState<ReportsExportScreen> createState() => _ReportsExportScreenState();
}

class _ReportsExportScreenState extends ConsumerState<ReportsExportScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  bool _isExportingPdf = false;
  bool _isExportingCsv = false;

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(allOrdersProvider);
    final formatCurrency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final formattedStart = DateFormat('dd/MM/yyyy').format(_startDate);
    final formattedEnd = DateFormat('dd/MM/yyyy').format(_endDate);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: AppBar(
        title: const Text('BÁO CÁO & XUẤT FILE DOANH THU', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFF16161B),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/manager/dashboard'),
        ),
      ),
      body: ordersAsync.when(
        loading: () => const LoadingView(message: 'Đang tải thông tin báo cáo...'),
        error: (error, stack) => ErrorView(message: 'Lỗi tải dữ liệu báo cáo: $error'),
        data: (orders) {
          // Lọc các đơn hàng nằm trong khoảng ngày được chọn (So sánh ngày không tính giờ)
          final startDay = DateTime(_startDate.year, _startDate.month, _startDate.day);
          final endDay = DateTime(_endDate.year, _endDate.month, _endDate.day, 23, 59, 59);

          final rangeOrders = orders.where((o) =>
              o.createdAt.isAfter(startDay) && o.createdAt.isBefore(endDay)).toList();

          final completed = rangeOrders.where((o) =>
              o.status == DineInOrderStatus.served ||
              o.status == DineInOrderStatus.completed).toList();

          final cancelled = rangeOrders.where((o) =>
              o.status == DineInOrderStatus.cancelled ||
              o.status == DineInOrderStatus.rejected).toList();

          final double revenue = completed.fold<double>(0, (sum, o) => sum + o.grandTotal);
          final double aov = completed.isEmpty ? 0 : revenue / completed.length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Date Range Picker Panel
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF16161B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF23232C)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'CHỌN KHOẢNG THỜI GIAN BÁO CÁO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDatePickerButton(
                              label: 'Từ ngày',
                              valueStr: formattedStart,
                              onTap: () => _selectDate(context, isStart: true),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildDatePickerButton(
                              label: 'Đến ngày',
                              valueStr: formattedEnd,
                              onTap: () => _selectDate(context, isStart: false),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // 2. Summary stats (SC-25 statistics)
                Text(
                  'TỔNG HỢP SỐ LIỆU',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.sizeOf(context).width < 600 ? 2 : 4,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.4,
                  children: [
                    _buildStatCard('Doanh thu', formatCurrency.format(revenue), Colors.green),
                    _buildStatCard('Đơn thành công', '${completed.length} đơn', Colors.blue),
                    _buildStatCard('Đơn đã hủy', '${cancelled.length} đơn', Colors.red),
                    _buildStatCard('Đơn trung bình (AOV)', formatCurrency.format(aov), Colors.amber),
                  ],
                ),
                const SizedBox(height: 32),

                // 3. Export actions panel
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
                        'XUẤT FILE DỮ LIỆU BÁO CÁO',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Dữ liệu sẽ được kết xuất dưới dạng cấu trúc tệp chuẩn để tải xuống thiết bị của bạn.',
                        style: TextStyle(color: Colors.grey, fontSize: 13, height: 1.4),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE11D48), // Rose Red for PDF
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: (_isExportingPdf || _isExportingCsv)
                                  ? null
                                  : () => _handleExport(
                                        isPdf: true,
                                        revenue: revenue,
                                        completedCount: completed.length,
                                        cancelledCount: cancelled.length,
                                        aov: aov,
                                      ),
                              icon: _isExportingPdf
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.picture_as_pdf),
                              label: Text(_isExportingPdf ? 'ĐANG XUẤT...' : 'XUẤT FILE PDF'),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF059669), // Green for CSV
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: (_isExportingPdf || _isExportingCsv)
                                  ? null
                                  : () => _handleExport(
                                        isPdf: false,
                                        revenue: revenue,
                                        completedCount: completed.length,
                                        cancelledCount: cancelled.length,
                                        aov: aov,
                                      ),
                              icon: _isExportingCsv
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : const Icon(Icons.table_view),
                              label: Text(_isExportingCsv ? 'ĐANG XUẤT...' : 'XUẤT FILE CSV'),
                            ),
                          ),
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

  Widget _buildDatePickerButton({
    required String label,
    required String valueStr,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF23232C),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2D2D35)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  valueStr,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const Icon(Icons.calendar_today, color: Colors.grey, size: 16),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF16161B),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF23232C)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: accentColor.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, {required bool isStart}) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.vermilion,
              onPrimary: Colors.white,
              surface: Color(0xFF16161B),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: const Color(0xFF0F0F11),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
          // Đảm bảo ngày bắt đầu không lớn hơn ngày kết thúc
          if (_startDate.isAfter(_endDate)) {
            _endDate = _startDate;
          }
        } else {
          _endDate = picked;
          // Đảm bảo ngày kết thúc không nhỏ hơn ngày bắt đầu
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate;
          }
        }
      });
    }
  }

  Future<void> _handleExport({
    required bool isPdf,
    required double revenue,
    required int completedCount,
    required int cancelledCount,
    required double aov,
  }) async {
    setState(() {
      if (isPdf) {
        _isExportingPdf = true;
      } else {
        _isExportingCsv = true;
      }
    });

    final formatStart = DateFormat('dd-MM-yyyy').format(_startDate);
    final formatEnd = DateFormat('dd-MM-yyyy').format(_endDate);

    try {
      if (isPdf) {
        final pdf = pw.Document();
        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Padding(
                padding: const pw.EdgeInsets.all(32),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('SUSHI RESTAURANT - REVENUE REPORT',
                        style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 8),
                    pw.Text(
                        'Giai doan: ${DateFormat('dd/MM/yyyy').format(_startDate)} - ${DateFormat('dd/MM/yyyy').format(_endDate)}'),
                    pw.Divider(height: 24),
                    pw.SizedBox(height: 16),
                    pw.Text('TONG HOP SO LIEU (SUMMARY STATISTICS)',
                        style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 12),
                    pw.Text('1. Tong Doanh thu (Total Revenue): ${revenue.toStringAsFixed(0)} VND'),
                    pw.Text('2. Don hang thanh cong (Completed Orders): $completedCount'),
                    pw.Text('3. Don hang da huy (Cancelled Orders): $cancelledCount'),
                    pw.Text('4. Gia tri don trung binh (AOV): ${aov.toStringAsFixed(0)} VND'),
                    pw.SizedBox(height: 32),
                    pw.Divider(height: 24),
                    pw.Text(
                        'Ngay lap bao cao: ${DateFormat('HH:mm dd/MM/yyyy').format(DateTime.now())}',
                        style: const pw.TextStyle(color: PdfColors.grey)),
                  ],
                ),
              );
            },
          ),
        );
        final bytes = await pdf.save();
        saveFile(
          'BaoCao_DoanhThu_${formatStart}_$formatEnd.pdf',
          bytes,
          'application/pdf',
        );
      } else {
        final csvString = '\uFEFF'
            'BÁO CÁO DOANH THU VÀ ĐƠN HÀNG\n'
            'Thời gian từ ngày,${DateFormat('dd/MM/yyyy').format(_startDate)},đến ngày,${DateFormat('dd/MM/yyyy').format(_endDate)}\n'
            'Ngày kết xuất,${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}\n\n'
            'Chỉ số,Giá trị\n'
            'Tổng doanh thu (VND),${revenue.toStringAsFixed(0)}\n'
            'Đơn hàng thành công,$completedCount\n'
            'Đơn hàng đã hủy,$cancelledCount\n'
            'Giá trị đơn trung bình (AOV),${aov.toStringAsFixed(0)}\n';
        final bytes = utf8.encode(csvString);
        saveFile(
          'BaoCao_DoanhThu_${formatStart}_$formatEnd.csv',
          bytes,
          'text/csv',
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('Lỗi xuất file: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isExportingPdf = false;
          _isExportingCsv = false;
        });
      }
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: isPdf ? const Color(0xFFE11D48) : const Color(0xFF059669),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                isPdf
                    ? 'Báo cáo PDF giai đoạn $formatStart đến $formatEnd đã được tải xuống!'
                    : 'Báo cáo CSV giai đoạn $formatStart đến $formatEnd đã được lưu trữ thành công!',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
