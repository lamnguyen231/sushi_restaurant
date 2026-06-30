import 'package:flutter/material.dart';

class CartItemTile extends StatelessWidget {
  const CartItemTile({
    required this.name,
    required this.quantity,
    required this.lineTotalLabel,
    super.key,
  });

  final String name;
  final int quantity;
  final String lineTotalLabel;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(name),
      subtitle: Text('Số lượng: $quantity'),
      trailing: Text(lineTotalLabel),
    );
  }
}
