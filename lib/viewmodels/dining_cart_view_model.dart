import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/local_cart_item.dart';
import '../models/sushi_product.dart';
import '../models/restaurant_order.dart';
import '../core/providers/local_providers.dart';
import '../core/providers/firebase_providers.dart';

part 'dining_cart_view_model.g.dart';

/// P3-11: Provider expose danh sách order đã gửi trong session (Firestore realtime).
@riverpod
Stream<List<RestaurantOrder>> sessionPlacedOrders(Ref ref, String sessionId) {
  if (sessionId.isEmpty) return Stream.value([]);
  return ref.watch(orderRepositoryProvider).watchSessionOrders(sessionId);
}

class DiningCartItem {
  const DiningCartItem({required this.localItem});
  final LocalCartItem localItem;

  /// P3-02: Giá và tên đã được snapshot vào LocalCartItem khi thêm vào giỏ.
  String get name => localItem.name;
  double get unitPrice => localItem.unitPrice;

  /// P3-03: lineTotal được tính lại từ unitPrice * quantity — không trust client.
  double get lineTotal => localItem.lineTotal;
}

class DiningCartState {
  const DiningCartState({
    this.sessionId = '',
    this.items = const [],
  });

  final String sessionId;
  final List<DiningCartItem> items;

  /// P3-03: Tổng tiền tính lại từ lineTotal từng item.
  double get totalPrice => items.fold(0, (sum, i) => sum + i.lineTotal);
  int get totalQuantity =>
      items.fold(0, (sum, i) => sum + i.localItem.quantity);

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
    final localItems = await localRepo.getItems(sessionId);
    final cartItems = localItems
        .map((item) => DiningCartItem(localItem: item))
        .toList();
    return DiningCartState(sessionId: sessionId, items: cartItems);
  }

  /// P3-01 + P3-02: addItem nhận đủ thông tin product để snapshot
  /// unitPrice và name vào SQLite ngay lúc thêm món.
  Future<void> addItem(SushiProduct product, {int qty = 1, String? notes}) async {
    final localRepo = ref.read(localCartRepositoryProvider);
    final item = LocalCartItem(
      productId: product.id,
      name: product.name,             // snapshot tên
      unitPrice: product.price,       // snapshot giá
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
