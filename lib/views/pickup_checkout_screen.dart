import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_theme.dart';
import '../models/restaurant_order.dart';
import '../viewmodels/pickup_checkout_view_model.dart';
import '../viewmodels/web_cart_view_model.dart';
import '../core/providers/firebase_providers.dart';
import '../widgets/sushi_nav_bar.dart';

class PickupCheckoutScreen extends ConsumerStatefulWidget {
  const PickupCheckoutScreen({super.key});

  @override
  ConsumerState<PickupCheckoutScreen> createState() => _PickupCheckoutScreenState();
}

class _PickupCheckoutScreenState extends ConsumerState<PickupCheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _noteCtrl = TextEditingController();
  String _selectedPickupTime = 'Ngay bây giờ (15-20 phút)';

  final List<String> _timeSlots = [
    'Ngay bây giờ (15-20 phút)',
    'Trong 30 phút nữa',
    'Trong 45 phút nữa',
    'Trong 1 giờ nữa',
    'Trong 2 giờ nữa',
  ];

  @override
  void initState() {
    super.initState();
    // Prefill user details if logged in
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = ref.read(currentUserProvider).value;
      if (user != null) {
        if (user.displayName != null && user.displayName!.isNotEmpty) {
          _nameCtrl.text = user.displayName!;
        }
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty) {
          _phoneCtrl.text = user.phoneNumber!;
        }
      }
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutState = ref.watch(pickupCheckoutViewModelProvider);
    final cart = ref.watch(webCartViewModelProvider);

    // If checkout was successful, show the success screen
    if (checkoutState is AsyncData && checkoutState.value != null) {
      return _CheckoutSuccessScreen(order: checkoutState.value!);
    }

    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: checkoutState.when(
        loading: () => const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppTheme.vermilion),
              SizedBox(height: 16),
              Text(
                'Đang gửi đơn hàng của bạn...',
                style: TextStyle(fontFamily: 'Georgia', fontSize: 16, color: AppTheme.ink),
              ),
            ],
          ),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: AppTheme.vermilion),
                const SizedBox(height: 12),
                Text('Có lỗi xảy ra: $e', style: const TextStyle(color: AppTheme.mutedInk)),
                const SizedBox(height: 16),
                OutlinedButton(
                  onPressed: () => ref.read(pickupCheckoutViewModelProvider.notifier).reset(),
                  child: const Text('THỬ LẠI'),
                ),
              ],
            ),
          ),
        ),
        data: (_) {
          if (cart.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_cart_outlined, size: 72, color: AppTheme.rice),
                  const SizedBox(height: 16),
                  const Text('Giỏ hàng của bạn đang trống', style: TextStyle(fontSize: 16)),
                  const SizedBox(height: 20),
                  OutlinedButton(
                    onPressed: () => context.go('/web/menu'),
                    child: const Text('XEM THỰC ĐƠN'),
                  ),
                ],
              ),
            );
          }

          final isWide = MediaQuery.sizeOf(context).width >= 900;
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: _buildFormSection(),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              flex: 2,
                              child: _buildSummarySection(cart),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildSummarySection(cart),
                            const SizedBox(height: 24),
                            _buildFormSection(),
                          ],
                        ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppTheme.ink),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'THÔNG TIN NHẬN MÓN (PICKUP)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 50,
                height: 2,
                color: AppTheme.vermilion,
              ),
              const SizedBox(height: 24),

              // Name field
              Text(
                'HỌ VÀ TÊN *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameCtrl,
                keyboardType: TextInputType.name,
                style: const TextStyle(fontSize: 14, fontFamily: 'Georgia'),
                decoration: const InputDecoration(
                  hintText: 'Nhập họ và tên của bạn',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Phone field
              Text(
                'SỐ ĐIỆN THOẠI CHỮA CHÁY *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                style: const TextStyle(fontSize: 14, fontFamily: 'Georgia'),
                decoration: const InputDecoration(
                  hintText: 'Nhập số điện thoại liên lạc',
                ),
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Vui lòng nhập số điện thoại';
                  }
                  if (!RegExp(r'^[0-9+]{9,11}$').hasMatch(val.trim())) {
                    return 'Vui lòng nhập số điện thoại hợp lệ (9-11 chữ số)';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Pickup Time dropdown
              Text(
                'THỜI GIAN NHẬN MÓN *',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPickupTime,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'Georgia',
                  color: AppTheme.ink,
                ),
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                ),
                items: _timeSlots.map((slot) {
                  return DropdownMenuItem<String>(
                    value: slot,
                    child: Text(slot),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() => _selectedPickupTime = val);
                  }
                },
              ),
              const SizedBox(height: 20),

              // Note field
              Text(
                'GHI CHÚ (TÙY CHỌN)',
                style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 11),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _noteCtrl,
                maxLines: 3,
                style: const TextStyle(fontSize: 14, fontFamily: 'Georgia'),
                decoration: const InputDecoration(
                  hintText: 'Ghi chú thêm cho nhà bếp (vd: không lấy wasabi...)',
                ),
              ),
              const SizedBox(height: 32),

              // Checkout Button
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/web/cart'),
                      child: const Text('QUAY LẠI GIỎ HÀNG'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _submitOrder,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.vermilion,
                        foregroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 2,
                        ),
                      ),
                      child: const Text('XÁC NHẬN ĐẶT HÀNG'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(WebCartState cart) {
    return Card(
      elevation: 0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppTheme.ink),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppTheme.eggshell,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Text(
              'TÓM TẮT ĐƠN HÀNG',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: cart.items.length,
                  itemBuilder: (ctx, i) {
                    final item = cart.items[i];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: AppTheme.ink,
                                  ),
                                ),
                                if (item.note != null && item.note!.isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Ghi chú: ${item.note}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppTheme.mutedInk,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'x${item.quantity}',
                            style: const TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '${item.lineTotal.toStringAsFixed(0)}đ',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: AppTheme.ink,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const Divider(color: AppTheme.rice, height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tạm tính',
                      style: TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                    ),
                    Text(
                      '${cart.subtotal.toStringAsFixed(0)}đ',
                      style: const TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'Phí dịch vụ nhận tại quầy (Pickup)',
                      style: TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                    ),
                    Text(
                      '0đ',
                      style: TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Divider(color: AppTheme.rice, height: 1),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'THÀNH TIỀN',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      '${cart.subtotal.toStringAsFixed(0)}đ',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.vermilion,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
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
  }

  void _submitOrder() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(pickupCheckoutViewModelProvider.notifier).submitOrder(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            pickupTime: _selectedPickupTime,
            note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
          );
    }
  }
}

// ── Checkout Success Screen ──────────────────────────────────────────────────

class _CheckoutSuccessScreen extends ConsumerWidget {
  const _CheckoutSuccessScreen({required this.order});

  final RestaurantOrder order;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppTheme.eggshell,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 540),
            child: Card(
              elevation: 0,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
                side: BorderSide(color: AppTheme.ink),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.check_circle_outline,
                      color: AppTheme.moss,
                      size: 64,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'ĐẶT HÀNG THÀNH CÔNG!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: AppTheme.moss,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cảm ơn bạn đã lựa chọn Sishu. Đơn hàng của bạn đã được chuyển tới nhà bếp của chúng tôi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                    ),
                    const SizedBox(height: 24),
                    const Divider(color: AppTheme.rice),
                    const SizedBox(height: 16),

                    // Order Info List
                    _buildInfoRow('Mã đơn hàng:', order.id),
                    const SizedBox(height: 8),
                    _buildInfoRow('Khách hàng:', order.customerName ?? ''),
                    const SizedBox(height: 8),
                    _buildInfoRow('Số điện thoại:', order.customerPhone ?? ''),
                    const SizedBox(height: 8),
                    _buildInfoRow('Phương thức:', 'Tự đến nhận (Pickup)'),
                    const SizedBox(height: 8),
                    _buildInfoRow('Tổng tiền:', '${order.grandTotal.toStringAsFixed(0)}đ'),
                    const SizedBox(height: 16),
                    const Divider(color: AppTheme.rice),
                    const SizedBox(height: 24),

                    ElevatedButton(
                      onPressed: () {
                        ref.read(pickupCheckoutViewModelProvider.notifier).reset();
                        context.go('/web/menu');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.ink,
                        foregroundColor: AppTheme.paper,
                        minimumSize: const Size.fromHeight(48),
                        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                      ),
                      child: const Text(
                        'QUAY LẠI THỰC ĐƠN',
                        style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.6),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {
                        ref.read(pickupCheckoutViewModelProvider.notifier).reset();
                        context.go('/');
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(48),
                      ),
                      child: const Text('TRANG CHỦ'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.mutedInk),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: AppTheme.ink,
          ),
        ),
      ],
    );
  }
}
