/// Dữ liệu giỏ hàng lưu cục bộ trong SQLite.
///
/// P3-02: unitPrice, name và lineTotal được **snapshot** tại thời điểm
/// khách thêm món vào giỏ. Điều này đảm bảo nếu giá món thay đổi sau đó,
/// đơn hàng vẫn phản ánh đúng giá tại thời điểm đặt.
class LocalCartItem {
  const LocalCartItem({
    required this.productId,
    required this.quantity,
    required this.sessionId,
    required this.name,
    required this.unitPrice,
    this.notes,
  });

  final String productId;

  /// Tên món tại thời điểm thêm vào giỏ (snapshot).
  final String name;

  /// Giá đơn vị tại thời điểm thêm vào giỏ (snapshot).
  final double unitPrice;

  final int quantity;
  final String sessionId;
  final String? notes;

  /// P3-03: lineTotal được tính lại từ unitPrice * quantity,
  /// không trust giá trị từ phía client.
  double get lineTotal => unitPrice * quantity;

  factory LocalCartItem.fromMap(Map<String, dynamic> map) {
    return LocalCartItem(
      productId: map['product_id'] as String,
      name: map['name'] as String? ?? '',
      unitPrice: (map['unit_price'] as num? ?? 0).toDouble(),
      quantity: map['quantity'] as int,
      sessionId: map['session_id'] as String,
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'product_id': productId,
      'name': name,
      'unit_price': unitPrice,
      'quantity': quantity,
      'session_id': sessionId,
      'notes': notes,
    };
  }

  LocalCartItem copyWith({
    String? productId,
    String? name,
    double? unitPrice,
    int? quantity,
    String? sessionId,
    String? notes,
  }) {
    return LocalCartItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      unitPrice: unitPrice ?? this.unitPrice,
      quantity: quantity ?? this.quantity,
      sessionId: sessionId ?? this.sessionId,
      notes: notes ?? this.notes,
    );
  }
}
