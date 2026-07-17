import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers/firebase_providers.dart';
import '../models/order_item.dart';
import '../models/restaurant_order.dart';
import 'web_cart_view_model.dart';

part 'pickup_checkout_view_model.g.dart';

@riverpod
class PickupCheckoutViewModel extends _$PickupCheckoutViewModel {
  @override
  AsyncValue<RestaurantOrder?> build() {
    return const AsyncValue.data(null);
  }

  Future<void> submitOrder({
    required String name,
    required String phone,
    required String pickupTime,
    String? note,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final cart = ref.read(webCartViewModelProvider);
      if (cart.items.isEmpty) {
        throw Exception('Giỏ hàng trống! Vui lòng chọn món ăn trước.');
      }

      final orderItems = cart.items.map((cartItem) {
        return OrderItem(
          productId: cartItem.product.id,
          productName: cartItem.product.name,
          unitPrice: cartItem.product.price,
          quantity: cartItem.quantity,
          lineTotal: cartItem.lineTotal,
          note: cartItem.note,
        );
      }).toList();

      final currentUser = ref.read(currentUserProvider).value;
      final orderRepo = ref.read(orderRepositoryProvider);

      final order = await orderRepo.placeWebPickupOrder(
        customerName: name,
        customerPhone: phone,
        pickupTime: pickupTime,
        note: note,
        items: orderItems,
        createdBy: currentUser?.id,
      );

      // Xoá giỏ hàng sau khi đặt thành công
      await ref.read(webCartViewModelProvider.notifier).clearCart();

      return order;
    });
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}
