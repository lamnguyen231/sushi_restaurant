import 'package:flutter/material.dart';

class KitchenOrderCard extends StatelessWidget {
  const KitchenOrderCard({
    required this.title,
    required this.status,
    super.key,
    this.onTap,
  });

  final String title;
  final String status;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(status),
        onTap: onTap,
      ),
    );
  }
}
