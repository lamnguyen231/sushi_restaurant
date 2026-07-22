class DineInOrderPayload {
  const DineInOrderPayload({
    required this.items,
    required this.subtotal,
    required this.itemCount,
  });

  final List<Map<String, dynamic>> items;
  final double subtotal;
  final int itemCount;

  factory DineInOrderPayload.fromItems(List<dynamic> rawItems) {
    if (rawItems.isEmpty) {
      throw StateError('Đơn hàng không có món.');
    }

    final items = <Map<String, dynamic>>[];
    var subtotal = 0.0;
    var itemCount = 0;

    for (final rawItem in rawItems) {
      if (rawItem is! Map<String, dynamic>) {
        throw StateError('Dữ liệu món không hợp lệ.');
      }

      final productId = rawItem['productId'];
      final productName = rawItem['productName'];
      final unitPrice = rawItem['unitPrice'];
      final quantity = rawItem['quantity'];
      final note = rawItem['note'];
      if (productId is! String ||
          productId.trim().isEmpty ||
          productName is! String ||
          productName.trim().isEmpty ||
          unitPrice is! num ||
          !unitPrice.toDouble().isFinite ||
          unitPrice < 0 ||
          quantity is! int ||
          quantity <= 0 ||
          note != null && note is! String) {
        throw StateError('Dữ liệu món không hợp lệ.');
      }

      final lineTotal = unitPrice.toDouble() * quantity;
      items.add({
        'productId': productId,
        'productName': productName,
        'unitPrice': unitPrice.toDouble(),
        'quantity': quantity,
        'note': note,
        'lineTotal': lineTotal,
      });
      subtotal += lineTotal;
      itemCount += quantity;
    }

    return DineInOrderPayload(
      items: items,
      subtotal: subtotal,
      itemCount: itemCount,
    );
  }
}
