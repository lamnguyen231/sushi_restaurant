import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/sushi_product.dart';

part 'web_cart_view_model.g.dart';

// ── Web Cart Item ─────────────────────────────────────────────────────────────

class WebCartItem {
  const WebCartItem({
    required this.product,
    required this.quantity,
  });

  final SushiProduct product;
  final int quantity;

  double get lineTotal => product.price * quantity;

  WebCartItem copyWith({int? quantity}) {
    return WebCartItem(
      product: product,
      quantity: quantity ?? this.quantity,
    );
  }
}

// ── State ─────────────────────────────────────────────────────────────────────

class WebCartState {
  const WebCartState({this.items = const []});

  final List<WebCartItem> items;

  double get subtotal => items.fold(0, (sum, i) => sum + i.lineTotal);

  int get totalQuantity => items.fold(0, (sum, i) => sum + i.quantity);

  bool get isEmpty => items.isEmpty;

  WebCartState copyWith({List<WebCartItem>? items}) {
    return WebCartState(items: items ?? this.items);
  }
}

// ── ViewModel ─────────────────────────────────────────────────────────────────

@riverpod
class WebCartViewModel extends _$WebCartViewModel {
  @override
  WebCartState build() => const WebCartState();

  /// Thêm sản phẩm vào giỏ. Nếu đã có thì tăng số lượng thêm [qty].
  void addItem(SushiProduct product, {int qty = 1}) {
    final existing = state.items.indexWhere(
      (i) => i.product.id == product.id,
    );
    if (existing >= 0) {
      final updated = List<WebCartItem>.from(state.items);
      updated[existing] = updated[existing].copyWith(
        quantity: updated[existing].quantity + qty,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [...state.items, WebCartItem(product: product, quantity: qty)],
      );
    }
  }

  /// Cập nhật số lượng. Nếu [quantity] <= 0 thì xóa sản phẩm.
  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeItem(productId);
      return;
    }
    final updated = state.items.map((i) {
      return i.product.id == productId ? i.copyWith(quantity: quantity) : i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  /// Xóa sản phẩm khỏi giỏ.
  void removeItem(String productId) {
    state = state.copyWith(
      items: state.items.where((i) => i.product.id != productId).toList(),
    );
  }

  /// Xóa toàn bộ giỏ hàng.
  void clearCart() {
    state = const WebCartState();
  }
}
