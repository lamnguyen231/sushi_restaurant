import 'package:flutter/material.dart';

class SushiProductCard extends StatelessWidget {
  const SushiProductCard({
    required this.name,
    required this.priceLabel,
    super.key,
    this.onTap,
  });

  final String name;
  final String priceLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(name),
        subtitle: Text(priceLabel),
        onTap: onTap,
      ),
    );
  }
}
