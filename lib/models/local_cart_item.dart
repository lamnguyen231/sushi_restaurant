import 'sushi_product.dart';

class LocalCartItem {
  const LocalCartItem({
    required this.productId,
    required this.quantity,
    required this.sessionId,
    this.notes,
  });

  final String productId;
  final int quantity;
  final String sessionId;
  final String? notes;

  factory LocalCartItem.fromMap(Map<String, dynamic> map) {
    return LocalCartItem(
      productId: map['product_id'] as String,
      quantity: map['quantity'] as int,
      sessionId: map['session_id'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'quantity': quantity,
      'session_id': sessionId,
      'notes': notes,
    };
  }

  LocalCartItem copyWith({
    String? productId,
    int? quantity,
    String? sessionId,
    String? notes,
  }) {
    return LocalCartItem(
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      sessionId: sessionId ?? this.sessionId,
      notes: notes ?? this.notes,
    );
  }
}
