import 'package:flutter/material.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    required this.quantity,
    required this.onDecrease,
    required this.onIncrease,
    super.key,
  });

  final int quantity;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(onPressed: onDecrease, icon: const Icon(Icons.remove)),
        Text('$quantity'),
        IconButton(onPressed: onIncrease, icon: const Icon(Icons.add)),
      ],
    );
  }
}
