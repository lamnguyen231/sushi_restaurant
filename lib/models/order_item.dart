class OrderItem {
  const OrderItem({
    required this.productId,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    required this.lineTotal,
    this.note,
  });

  final String productId;
  final String productName;
  final double unitPrice;
  final int quantity;
  final String? note;
  final double lineTotal;
}
