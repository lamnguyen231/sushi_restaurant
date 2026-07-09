import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/sushi_product.dart';

part 'web_cart_view_model.g.dart';

// ── Web Cart Item ─────────────────────────────────────────────────────────────

class WebCartItem {
  const WebCartItem({
    required this.product,
    required this.quantity,
    this.note,
  });

  final SushiProduct product;
  final int quantity;
  final String? note;

  double get lineTotal => product.price * quantity;

  WebCartItem copyWith({int? quantity, String? note}) {
    return WebCartItem(
      product: product,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
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

  /// Thêm sản phẩm vào giỏ. Nếu đã có cùng [note] thì tăng số lượng thêm [qty].
  void addItem(SushiProduct product, {int qty = 1, String? note}) {
    final existing = state.items.indexWhere(
      (i) => i.product.id == product.id && i.note == note,
    );
    if (existing >= 0) {
      final updated = List<WebCartItem>.from(state.items);
      updated[existing] = updated[existing].copyWith(
        quantity: updated[existing].quantity + qty,
      );
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(
        items: [...state.items, WebCartItem(product: product, quantity: qty, note: note)],
      );
    }
  }

  /// Cập nhật số lượng. Sử dụng index hoặc (productId + note) để tìm đúng item.
  /// Tuy nhiên do UI hiện tại chỉ xoá/cập nhật theo ID, ta sẽ cập nhật tất cả item có cùng productId.
  /// (Tốt nhất là cập nhật theo index hoặc ID duy nhất của cart item)
  void updateQuantity(String productId, int quantity, {String? note}) {
    if (quantity <= 0) {
      removeItem(productId, note: note);
      return;
    }
    final updated = state.items.map((i) {
      if (i.product.id == productId && i.note == note) {
        return i.copyWith(quantity: quantity);
      }
      return i;
    }).toList();
    state = state.copyWith(items: updated);
  }

  /// Xóa sản phẩm khỏi giỏ.
  void removeItem(String productId, {String? note}) {
    state = state.copyWith(
      items: state.items
          .where((i) => !(i.product.id == productId && i.note == note))
          .toList(),
    );
  }

  /// Xóa toàn bộ giỏ hàng.
  void clearCart() {
    state = const WebCartState();
  }
}
