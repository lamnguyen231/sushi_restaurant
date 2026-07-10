import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/local_cart_item.dart';
import '../models/sushi_product.dart';
import '../models/restaurant_order.dart';
import '../core/providers/local_providers.dart';
import '../core/providers/firebase_providers.dart';

part 'dining_cart_view_model.g.dart';

@riverpod
Stream<List<RestaurantOrder>> sessionPlacedOrders(Ref ref, String sessionId) {
  if (sessionId.isEmpty) return Stream.value([]);
  return ref.watch(orderRepositoryProvider).watchSessionOrders(sessionId);
}

class DiningCartItem {
  const DiningCartItem({required this.localItem, required this.product});
  final LocalCartItem localItem;
  final SushiProduct product;
}

class DiningCartState {
  const DiningCartState({
    this.sessionId = '',
    this.items = const [],
  });

  final String sessionId;
  final List<DiningCartItem> items;

  double get totalPrice => items.fold(0, (sum, i) => sum + (i.product.price * i.localItem.quantity));
  int get totalQuantity => items.fold(0, (sum, i) => sum + i.localItem.quantity);

  DiningCartState copyWith({String? sessionId, List<DiningCartItem>? items}) {
    return DiningCartState(
      sessionId: sessionId ?? this.sessionId,
      items: items ?? this.items,
    );
  }
}

@riverpod
class DiningCartViewModel extends _$DiningCartViewModel {
  @override
  Future<DiningCartState> build(String sessionId) async {
    if (sessionId.isEmpty) return const DiningCartState();
    return _loadCart();
  }

  Future<DiningCartState> _loadCart() async {
    final localRepo = ref.read(localCartRepositoryProvider);
    final productRepo = ref.read(productRepositoryProvider);
    
    final localItems = await localRepo.getItems(sessionId);
    
    List<DiningCartItem> cartItems = [];
    for (final item in localItems) {
      final product = await productRepo.getProductById(item.productId);
      if (product != null) {
        cartItems.add(DiningCartItem(localItem: item, product: product));
      }
    }
    return DiningCartState(sessionId: sessionId, items: cartItems);
  }

  Future<void> addItem(SushiProduct product, {int qty = 1, String? notes}) async {
    final localRepo = ref.read(localCartRepositoryProvider);
    final item = LocalCartItem(
      productId: product.id,
      quantity: qty,
      sessionId: sessionId,
      notes: notes,
    );
    await localRepo.addItem(item);
    ref.invalidateSelf();
  }

  Future<void> updateQuantity(String productId, int newQty) async {
    final localRepo = ref.read(localCartRepositoryProvider);
    await localRepo.updateQuantity(productId, sessionId, newQty);
    ref.invalidateSelf();
  }

  Future<void> removeItem(String productId) async {
    final localRepo = ref.read(localCartRepositoryProvider);
    await localRepo.removeItem(productId, sessionId);
    ref.invalidateSelf();
  }

  Future<void> clearCart() async {
    final localRepo = ref.read(localCartRepositoryProvider);
    await localRepo.clearCart(sessionId);
    ref.invalidateSelf();
  }
}
