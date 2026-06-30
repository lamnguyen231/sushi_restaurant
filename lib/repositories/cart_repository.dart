import '../models/cart_item.dart';

abstract interface class CartRepository {
  Future<List<CartItem>> getItems(String sessionId);

  Future<void> addItem(CartItem item);

  Future<void> updateQuantity({
    required int itemId,
    required int quantity,
  });

  Future<void> removeItem(int itemId);

  Future<void> clearSessionCart(String sessionId);
}
