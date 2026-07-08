import 'package:flutter/material.dart';
import 'package:sushi_restaurant/core/theme/app_theme.dart';
import 'package:sushi_restaurant/models/sushi_product.dart';
import 'package:sushi_restaurant/widgets/ink_frame.dart';
import 'package:sushi_restaurant/widgets/primary_button.dart';

class SushiProductDiningListItem extends StatelessWidget {
  const SushiProductDiningListItem({
    super.key,
    required this.product,
    this.onAddToCart,
  });

  final SushiProduct product;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return InkFrame(
      backgroundColor: AppTheme.paper,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            product.name.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 18),
          Text(
            'GIÁ: ${product.price.toStringAsFixed(0)}đ',
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          if (product.description != null && product.description!.isNotEmpty)
            Text(
              product.description!,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 14),
          PrimaryButton(
            label: 'Cho vào giỏ hàng',
            onPressed: onAddToCart,
          ),
        ],
      ),
    );
  }
}
