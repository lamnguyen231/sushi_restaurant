import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  factory WebCartItem.fromJson(Map<String, dynamic> json) {
    return WebCartItem(
      product: SushiProduct.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int? ?? 1,
      note: json['note'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'quantity': quantity,
      'note': note,
    };
  }

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

@Riverpod(keepAlive: true)
class WebCartViewModel extends _$WebCartViewModel {
  static const _storageKey = 'web_cart_items';
  Future<void>? _loadFuture;

  @override
  WebCartState build() {
    _loadFuture = _loadCart();
    return const WebCartState();
  }

  Future<void> _loadCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final List<dynamic> decoded = json.decode(jsonStr);
        final items = decoded
            .map((item) => WebCartItem.fromJson(item as Map<String, dynamic>))
            .toList();
        state = WebCartState(items: items);
      }
    } catch (_) {
      // Keep state as is if load fails
    }
  }

  Future<void> _saveCart() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = json.encode(state.items.map((i) => i.toJson()).toList());
      await prefs.setString(_storageKey, jsonStr);
    } catch (_) {
      // Fail silently
    }
  }

  /// Thêm sản phẩm vào giỏ. Nếu đã có cùng [note] thì tăng số lượng thêm [qty].
  Future<void> addItem(SushiProduct product, {int qty = 1, String? note}) async {
    await _loadFuture;
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
    await _saveCart();
  }

  /// Cập nhật số lượng. Sử dụng index hoặc (productId + note) để tìm đúng item.
  /// Tuy nhiên do UI hiện tại chỉ xoá/cập nhật theo ID, ta sẽ cập nhật tất cả item có cùng productId.
  /// (Tốt nhất là cập nhật theo index hoặc ID duy nhất của cart item)
  Future<void> updateQuantity(String productId, int quantity, {String? note}) async {
    await _loadFuture;
    if (quantity <= 0) {
      await removeItem(productId, note: note);
      return;
    }
    final updated = state.items.map((i) {
      if (i.product.id == productId && i.note == note) {
        return i.copyWith(quantity: quantity);
      }
      return i;
    }).toList();
    state = state.copyWith(items: updated);
    await _saveCart();
  }

  /// Xóa sản phẩm khỏi giỏ.
  Future<void> removeItem(String productId, {String? note}) async {
    await _loadFuture;
    state = state.copyWith(
      items: state.items
          .where((i) => !(i.product.id == productId && i.note == note))
          .toList(),
    );
    await _saveCart();
  }

  /// Xóa toàn bộ giỏ hàng.
  Future<void> clearCart() async {
    await _loadFuture;
    state = const WebCartState();
    await _saveCart();
  }
}
