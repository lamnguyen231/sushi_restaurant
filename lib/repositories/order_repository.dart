import '../models/cart_item.dart';
import '../models/restaurant_order.dart';

abstract interface class OrderRepository {
  Stream<List<RestaurantOrder>> watchKitchenOrders();

  Stream<List<RestaurantOrder>> watchSessionOrders(String sessionId);

  Future<RestaurantOrder> placeDineInOrder({
    required String sessionId,
    required String tableId,
    required String tableName,
    required List<CartItem> cartItems,
  });

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
