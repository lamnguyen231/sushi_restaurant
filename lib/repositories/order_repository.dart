import '../models/cart_item.dart';
import '../models/order_item.dart';
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

  Future<RestaurantOrder> placeWebPickupOrder({
    required String customerName,
    required String customerPhone,
    required String pickupTime,
    required String? note,
    required List<OrderItem> items,
    String? createdBy,
  });

  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  });
}
