class CartItem {
  const CartItem({
    required this.id,
    required this.sessionId,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    required this.createdAt,
    required this.updatedAt,
    this.note,
  });

  final int? id;
  final String sessionId;
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? note;
  final double lineTotal;
  final DateTime createdAt;
  final DateTime updatedAt;
}
