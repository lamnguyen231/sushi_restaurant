import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../core/providers/local_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/dining_session.dart';
import '../models/order_item.dart';
import '../models/restaurant_order.dart';
import '../viewmodels/dining_cart_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/ink_frame.dart';
import '../widgets/loading_view.dart';
import '../widgets/primary_button.dart';

class SessionReceiptScreen extends ConsumerStatefulWidget {
  const SessionReceiptScreen({required this.unlockedSessionId, super.key});

  final String? unlockedSessionId;

  @override
  ConsumerState<SessionReceiptScreen> createState() =>
      _SessionReceiptScreenState();
}

class _SessionReceiptScreenState extends ConsumerState<SessionReceiptScreen> {
  DiningPaymentMethod? _selectedMethod;
  bool _isUpdating = false;

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(currentDiningSessionProvider);
    if (session == null) {
      return const Scaffold(
        body: EmptyStateView(message: 'Không tìm thấy phiên dùng bữa.'),
      );
    }
    if (widget.unlockedSessionId != session.id) {
      return Scaffold(
        appBar: AppBar(title: const Text('HÓA ĐƠN')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const EmptyStateView(
                message: 'Nhân viên cần mở khóa bằng PIN để xem hóa đơn.',
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () => context.go('/dining/orders'),
                child: const Text('QUAY LẠI'),
              ),
            ],
          ),
        ),
      );
    }

    final repository = ref.watch(diningSessionRepositoryProvider);
    return StreamBuilder<DiningSession?>(
      stream: repository.watchActiveSession(session.tableId),
      initialData: session,
      builder: (context, snapshot) {
        final activeSession = snapshot.data ?? session;
        final ordersAsync = ref.watch(
          sessionPlacedOrdersProvider(activeSession.id),
        );
        return Scaffold(
          appBar: AppBar(
            title: Text('HÓA ĐƠN - ${activeSession.tableName.toUpperCase()}'),
            leading: IconButton(
              tooltip: 'Quay lại đơn đã gọi',
              onPressed: _isUpdating
                  ? null
                  : () => context.go('/dining/orders'),
              icon: const Icon(Icons.arrow_back),
            ),
          ),
          body: ordersAsync.when(
            loading: () => const LoadingView(message: 'Đang lập hóa đơn...'),
            error: (error, stack) =>
                ErrorView(message: 'Không thể tải hóa đơn: $error'),
            data: (orders) => _buildReceipt(context, activeSession, orders),
          ),
        );
      },
    );
  }

  Widget _buildReceipt(
    BuildContext context,
    DiningSession session,
    List<RestaurantOrder> orders,
  ) {
    final validOrders = orders
        .where(
          (order) =>
              order.status != DineInOrderStatus.cancelled &&
              order.status != DineInOrderStatus.rejected,
        )
        .toList();
    final items = _groupItems(validOrders);
    final total = validOrders.fold<double>(
      0,
      (sum, order) => sum + order.grandTotal,
    );
    final paid = session.paymentStatus == PaymentStatus.paid;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final receipt = _ReceiptPanel(
          session: session,
          items: items,
          total: total,
        );
        final payment = _PaymentPanel(
          paid: paid,
          total: total,
          selectedMethod: _selectedMethod ?? session.paymentMethod,
          isUpdating: _isUpdating,
          onMethodSelected: paid
              ? null
              : (method) => setState(() => _selectedMethod = method),
          onTogglePaid: _isUpdating ? null : () => _togglePaid(session, paid),
          onCloseSession: paid && !_isUpdating
              ? () => _closeSession(session)
              : null,
        );

        if (wide) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: receipt),
                const SizedBox(width: 24),
                Expanded(flex: 2, child: payment),
              ],
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [receipt, const SizedBox(height: 16), payment],
        );
      },
    );
  }

  Future<void> _togglePaid(DiningSession session, bool currentlyPaid) async {
    final user = ref.read(currentUserProvider).value;
    final method = _selectedMethod ?? session.paymentMethod;
    if (!currentlyPaid && method == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn phương thức thanh toán.')),
      );
      return;
    }
    if (!currentlyPaid && user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy nhân viên xác nhận.')),
      );
      return;
    }

    setState(() => _isUpdating = true);
    try {
      await ref
          .read(diningSessionRepositoryProvider)
          .setPaymentStatus(
            sessionId: session.id,
            status: currentlyPaid ? PaymentStatus.unpaid : PaymentStatus.paid,
            method: currentlyPaid ? null : method,
            paidBy: currentlyPaid ? null : user!.id,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            currentlyPaid
                ? 'Đã chuyển hóa đơn về trạng thái chưa thanh toán.'
                : 'Demo: Đã ghi nhận thanh toán thành công.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể cập nhật thanh toán: $error')),
      );
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _closeSession(DiningSession session) async {
    setState(() => _isUpdating = true);
    try {
      await ref.read(diningSessionRepositoryProvider).closeSession(session.id);
      await ref
          .read(diningCartViewModelProvider(session.id).notifier)
          .clearCart();
      await ref
          .read(deviceSessionAssignmentServiceProvider)
          .clearActiveSession();
      if (!mounted) return;
      context.go('/staff/tables');
      ref.read(currentDiningSessionProvider.notifier).clear();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể đóng phiên: $error')));
      setState(() => _isUpdating = false);
    }
  }

  List<OrderItem> _groupItems(List<RestaurantOrder> orders) {
    final grouped = <String, OrderItem>{};
    for (final order in orders) {
      for (final item in order.items) {
        final existing = grouped[item.productId];
        grouped[item.productId] = existing == null
            ? item
            : OrderItem(
                productId: existing.productId,
                productName: existing.productName,
                unitPrice: existing.unitPrice,
                quantity: existing.quantity + item.quantity,
                note: existing.note,
                lineTotal: existing.lineTotal + item.lineTotal,
              );
      }
    }
    return grouped.values.toList();
  }
}

class _ReceiptPanel extends StatelessWidget {
  const _ReceiptPanel({
    required this.session,
    required this.items,
    required this.total,
  });

  final DiningSession session;
  final List<OrderItem> items;
  final double total;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return InkFrame(
      backgroundColor: AppTheme.paper,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('SISHU', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 6),
          Text(
            'PHIẾU THANH TOÁN',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppTheme.vermilion),
          ),
          const Divider(height: 32, color: AppTheme.ink),
          _ReceiptMeta(label: 'BÀN', value: session.tableName),
          _ReceiptMeta(label: 'MÃ PHIÊN', value: session.sessionCode),
          if (session.guestCount != null)
            _ReceiptMeta(label: 'SỐ KHÁCH', value: '${session.guestCount}'),
          const Divider(height: 32, color: AppTheme.rice),
          if (items.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Text('Chưa có món nào được gửi bếp.'),
            )
          else
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 42,
                      child: Text(
                        '${item.quantity}×',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(child: Text(item.productName)),
                    const SizedBox(width: 16),
                    Text(currency.format(item.lineTotal)),
                  ],
                ),
              ),
            ),
          const Divider(height: 32, color: AppTheme.ink),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'TỔNG THANH TOÁN',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                currency.format(total),
                style: const TextStyle(
                  color: AppTheme.vermilion,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReceiptMeta extends StatelessWidget {
  const _ReceiptMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelLarge?.copyWith(color: AppTheme.mutedInk),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

class _PaymentPanel extends StatelessWidget {
  const _PaymentPanel({
    required this.paid,
    required this.total,
    required this.selectedMethod,
    required this.isUpdating,
    required this.onMethodSelected,
    required this.onTogglePaid,
    required this.onCloseSession,
  });

  final bool paid;
  final double total;
  final DiningPaymentMethod? selectedMethod;
  final bool isUpdating;
  final ValueChanged<DiningPaymentMethod>? onMethodSelected;
  final VoidCallback? onTogglePaid;
  final VoidCallback? onCloseSession;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    return InkFrame(
      backgroundColor: AppTheme.paper,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'THANH TOÁN',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              _StatusBadge(paid: paid),
            ],
          ),
          const SizedBox(height: 24),
          const Text('CHỌN PHƯƠNG THỨC'),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _PaymentMethodCard(
                  icon: Icons.payments_outlined,
                  label: 'TIỀN MẶT',
                  selected: selectedMethod == DiningPaymentMethod.cash,
                  onTap: onMethodSelected == null
                      ? null
                      : () => onMethodSelected!(DiningPaymentMethod.cash),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PaymentMethodCard(
                  icon: Icons.qr_code_2,
                  label: 'MÃ QR',
                  selected: selectedMethod == DiningPaymentMethod.qr,
                  onTap: onMethodSelected == null
                      ? null
                      : () => onMethodSelected!(DiningPaymentMethod.qr),
                ),
              ),
            ],
          ),
          if (selectedMethod == DiningPaymentMethod.qr && !paid) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              color: AppTheme.eggshell,
              child: Column(
                children: [
                  const Icon(Icons.qr_code_2, size: 132),
                  const SizedBox(height: 8),
                  Text('DEMO QR • ${currency.format(total)}'),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),
          OutlinedButton.icon(
            key: const Key('demo-payment-toggle'),
            onPressed: onTogglePaid,
            icon: Icon(paid ? Icons.undo : Icons.science_outlined),
            label: Text(
              paid
                  ? 'DEMO: CHUYỂN VỀ CHƯA THANH TOÁN'
                  : 'DEMO: ĐÁNH DẤU ĐÃ THANH TOÁN',
            ),
          ),
          const SizedBox(height: 12),
          PrimaryButton(
            label: isUpdating
                ? 'ĐANG XỬ LÝ...'
                : paid
                ? 'ĐÓNG PHIÊN'
                : 'CHƯA THỂ ĐÓNG PHIÊN',
            onPressed: onCloseSession,
          ),
          if (!paid) ...[
            const SizedBox(height: 10),
            const Text(
              'Nút đóng phiên chỉ khả dụng sau khi hóa đơn được ghi nhận đã thanh toán.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.mutedInk, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 104,
        decoration: BoxDecoration(
          color: selected ? AppTheme.ink : AppTheme.eggshell,
          border: Border.all(color: AppTheme.ink),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 32,
              color: selected ? AppTheme.paper : AppTheme.ink,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.paper : AppTheme.ink,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.paid});

  final bool paid;

  @override
  Widget build(BuildContext context) {
    final color = paid ? AppTheme.moss : AppTheme.vermilion;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(border: Border.all(color: color)),
      child: Text(
        paid ? 'ĐÃ THANH TOÁN' : 'CHƯA THANH TOÁN',
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
