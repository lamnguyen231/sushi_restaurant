import '../models/local_cart_item.dart';
import '../services/sqlite_cart_service.dart';

class LocalCartRepository {
  const LocalCartRepository(this._service);
  
  final SqliteCartService _service;

  Future<List<LocalCartItem>> getItems(String sessionId) => _service.getItemsForSession(sessionId);
  Future<void> addItem(LocalCartItem item) => _service.upsertItem(item);
  Future<void> updateQuantity(String productId, String sessionId, int qty) => _service.updateItemQuantity(productId, sessionId, qty);
  Future<void> removeItem(String productId, String sessionId) => _service.removeItem(productId, sessionId);
  Future<void> clearCart(String sessionId) => _service.clearSessionCart(sessionId);
}
