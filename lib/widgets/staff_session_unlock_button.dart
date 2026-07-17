import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../core/providers/local_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/app_user.dart';
import '../models/dining_session.dart';
import '../models/order_item.dart';
import '../models/restaurant_order.dart';
import '../viewmodels/dining_cart_view_model.dart';
import '../viewmodels/table_selection_view_model.dart';

class StaffSessionUnlockButton extends ConsumerWidget {
  const StaffSessionUnlockButton({
    super.key,
    required this.session,
    this.iconOnly = false,
  });

  final DiningSession session;
  final bool iconOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(currentUserProvider);
    final onPressed = userState.hasValue
        ? () => _unlockAndCloseSession(context, ref, userState.value)
        : null;

    if (iconOnly) {
      return IconButton(
        tooltip: userState.isLoading ? 'Đang xác thực nhân viên' : 'Nhân viên',
        color: AppTheme.paper,
        onPressed: onPressed,
        icon: userState.isLoading
            ? const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.lock_open),
      );
    }

    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.lock_open),
      label: Text(userState.isLoading ? 'Đang xác thực' : 'Nhân viên'),
      style: TextButton.styleFrom(foregroundColor: AppTheme.paper),
    );
  }

  Future<void> _unlockAndCloseSession(
    BuildContext context,
    WidgetRef ref,
    AppUser? user,
  ) async {
    final canUnlock =
        user?.role == UserRole.manager || user?.id == session.openedBy;
    if (!canUnlock) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Chỉ nhân viên mở phiên hoặc quản lý được mở khóa.'),
        ),
      );
      return;
    }

    final unlocked = await _askPin(context);
    if (!context.mounted || !unlocked) return;

    final closeConfirmed = await _showReceiptAndConfirmClose(context, ref);
    if (!context.mounted || !closeConfirmed) return;

    await ref
        .read(tableSelectionViewModelProvider.notifier)
        .closeSession(session.id);
    await ref
        .read(diningCartViewModelProvider(session.id).notifier)
        .clearCart();
    await ref.read(deviceSessionAssignmentServiceProvider).clearActiveSession();
    ref.read(currentDiningSessionProvider.notifier).clear();

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã kết thúc phiên ${session.tableName}.')),
    );
    context.go('/staff/tables');
  }

  Future<bool> _askPin(BuildContext context) async {
    final controller = TextEditingController();
    var attempts = 0;
    var locked = false;
    String? errorText;

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Mở khóa nhân viên'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nhập PIN nhân viên để kiểm tra hóa đơn và đóng phiên.',
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    enabled: !locked,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'PIN',
                      helperText: 'PIN demo: 1234',
                      errorText: errorText,
                    ),
                    onSubmitted: (_) => _trySubmitPin(
                      context,
                      setDialogState,
                      controller,
                      () => attempts,
                      (value) => attempts = value,
                      () => locked,
                      (value) => locked = value,
                      (value) => errorText = value,
                    ),
                  ),
                  if (locked) ...[
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () {
                        setDialogState(() {
                          attempts = 0;
                          locked = false;
                          errorText = null;
                          controller.clear();
                        });
                      },
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset số lần thử'),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: locked
                      ? null
                      : () => _trySubmitPin(
                          context,
                          setDialogState,
                          controller,
                          () => attempts,
                          (value) => attempts = value,
                          () => locked,
                          (value) => locked = value,
                          (value) => errorText = value,
                        ),
                  child: const Text('Mở khóa'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result ?? false;
  }

  void _trySubmitPin(
    BuildContext context,
    StateSetter setDialogState,
    TextEditingController controller,
    int Function() getAttempts,
    void Function(int value) setAttempts,
    bool Function() getLocked,
    void Function(bool value) setLocked,
    void Function(String? value) setErrorText,
  ) {
    if (getLocked()) return;

    if (controller.text.trim() == '1234') {
      Navigator.of(context).pop(true);
      return;
    }

    final nextAttempts = getAttempts() + 1;
    setDialogState(() {
      setAttempts(nextAttempts);
      controller.clear();
      if (nextAttempts >= 3) {
        setLocked(true);
        setErrorText('Sai PIN 3 lần. Bấm reset để thử lại khi demo.');
      } else {
        setErrorText('Sai PIN. Còn ${3 - nextAttempts} lần thử.');
      }
    });
  }

  Future<bool> _showReceiptAndConfirmClose(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final cartState = await ref.read(
      diningCartViewModelProvider(session.id).future,
    );
    final orders = await ref.read(
      sessionPlacedOrdersProvider(session.id).future,
    );
    if (!context.mounted) return false;

    final unsentCount = cartState.totalQuantity;
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _SessionReceiptDialog(
        session: session,
        orders: orders,
        unsentCount: unsentCount,
        unsentTotal: cartState.totalPrice,
      ),
    );

    return result ?? false;
  }
}

class _SessionReceiptDialog extends StatelessWidget {
  const _SessionReceiptDialog({
    required this.session,
    required this.orders,
    required this.unsentCount,
    required this.unsentTotal,
  });

  final DiningSession session;
  final List<RestaurantOrder> orders;
  final int unsentCount;
  final double unsentTotal;

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
    final items = _groupItems(orders);
    final total = orders.fold<double>(
      0,
      (sum, order) => sum + order.grandTotal,
    );

    return AlertDialog(
      title: Text('Hóa đơn ${session.tableName}'),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Phiên: #${session.id.substring(0, 6)}'),
              if (session.guestCount != null)
                Text('Số khách: ${session.guestCount}'),
              const Divider(height: 28),
              if (items.isEmpty)
                const Text('Chưa có order nào đã gửi bếp.')
              else
                ...items.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text('${item.productName} x${item.quantity}'),
                        ),
                        Text(currency.format(item.lineTotal)),
                      ],
                    ),
                  ),
                ),
              const Divider(height: 28),
              Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Tổng đã gửi',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Text(
                    currency.format(total),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              if (unsentCount > 0) ...[
                const SizedBox(height: 16),
                Text(
                  'Còn $unsentCount món chưa gửi (${currency.format(unsentTotal)}). Xác nhận đóng phiên sẽ xóa giỏ tạm; nhân viên có thể ghi nhận mang về thủ công nếu cần.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Quay lại'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Xác nhận thanh toán & đóng phiên'),
        ),
      ],
    );
  }

  List<OrderItem> _groupItems(List<RestaurantOrder> orders) {
    final grouped = <String, OrderItem>{};
    for (final order in orders) {
      for (final item in order.items) {
        final existing = grouped[item.productId];
        if (existing == null) {
          grouped[item.productId] = item;
        } else {
          grouped[item.productId] = OrderItem(
            productId: existing.productId,
            productName: existing.productName,
            unitPrice: existing.unitPrice,
            quantity: existing.quantity + item.quantity,
            note: existing.note,
            lineTotal: existing.lineTotal + item.lineTotal,
          );
        }
      }
    }
    return grouped.values.toList();
  }
}
