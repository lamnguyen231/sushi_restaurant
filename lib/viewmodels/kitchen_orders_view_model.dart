import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../models/restaurant_order.dart';

part 'kitchen_orders_view_model.g.dart';

@riverpod
class KitchenOrdersViewModel extends _$KitchenOrdersViewModel {
  @override
  Stream<List<RestaurantOrder>> build() {
    // P3-08: Lắng nghe Firestore realtime cho các đơn hàng của bếp (pending/accepted/preparing)
    return ref.watch(orderRepositoryProvider).watchKitchenOrders();
  }

  /// P3-09: Cập nhật trạng thái đơn hàng (ví dụ: pending -> accepted -> preparing -> ready -> served)
  Future<void> updateStatus(String orderId, DineInOrderStatus status) async {
    await ref.read(orderRepositoryProvider).updateOrderStatus(
      orderId: orderId,
      status: status.name,
    );
  }
}
