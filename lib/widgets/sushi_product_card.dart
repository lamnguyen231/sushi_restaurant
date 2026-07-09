import 'package:flutter/material.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../models/sushi_product.dart';

/// Card hiển thị sản phẩm dạng lưới cho user/customer.
class SushiProductCard extends StatefulWidget {
  const SushiProductCard({
    required this.product,
    super.key,
    this.onAddToCart,
    this.onViewDetail,
  });

  final SushiProduct product;
  final VoidCallback? onAddToCart;
  final VoidCallback? onViewDetail;

  @override
  State<SushiProductCard> createState() => _SushiProductCardState();
}

class _SushiProductCardState extends State<SushiProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: AppTheme.paper,
          border: Border.all(
            color: _hovered ? AppTheme.vermilion : AppTheme.ink,
            width: _hovered ? 1.5 : 1,
          ),
          boxShadow: _hovered
              ? [
                  BoxShadow(
                    color: AppTheme.ink.withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(imageUrl: product.imageUrl),
                  // Category badge
                  Positioned(
                    top: 10,
                    left: 10,
                    child: _CategoryBadge(categoryId: product.categoryId),
                  ),
                  // Area badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: _AreaBadge(area: product.preparationArea.name),
                  ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      product.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 13,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: 12),

                  // Price
                  Text(
                    '${product.price.toStringAsFixed(0)}đ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.vermilion,
                          fontSize: 18,
                        ),
                  ),
                  const SizedBox(height: 10),

                  // ── Action buttons ────────────────────────────────────────
                  Row(
                    children: [
                      // Chi tiết button
                      Expanded(
                        child: _DetailButton(
                          onPressed: widget.onViewDetail ??
                              () => ProductDetailDialog.show(
                                    context,
                                    product: product,
                                    onAddToCart: widget.onAddToCart,
                                  ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Thêm giỏ hàng button
                      Expanded(
                        child: _AddToCartButton(onPressed: widget.onAddToCart),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Detail Button ─────────────────────────────────────────────────────────────

class _DetailButton extends StatefulWidget {
  const _DetailButton({this.onPressed});
  final VoidCallback? onPressed;

  @override
  State<_DetailButton> createState() => _DetailButtonState();
}

class _DetailButtonState extends State<_DetailButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: _hovered ? AppTheme.rice : Colors.transparent,
            border: Border.all(
              color: _hovered ? AppTheme.mutedInk : AppTheme.rice,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_outline, size: 13, color: AppTheme.mutedInk),
              SizedBox(width: 5),
              Text(
                'CHI TIẾT',
                style: TextStyle(
                  color: AppTheme.mutedInk,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add To Cart Button ────────────────────────────────────────────────────────

class _AddToCartButton extends StatelessWidget {
  const _AddToCartButton({this.onPressed});
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: onPressed != null ? AppTheme.ink : AppTheme.mutedInk,
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_shopping_cart, size: 13, color: AppTheme.paper),
            SizedBox(width: 5),
            Text(
              'THÊM',
              style: TextStyle(
                color: AppTheme.paper,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Product Image ─────────────────────────────────────────────────────────────

class _ProductImage extends StatelessWidget {
  const _ProductImage({this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stack) => const _ImagePlaceholder(),
      );
    }
    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.eggshell,
      child: const Center(
        child: Icon(Icons.restaurant, size: 48, color: AppTheme.rice),
      ),
    );
  }
}

class _CategoryBadge extends StatelessWidget {
  const _CategoryBadge({required this.categoryId});
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    if (categoryId.isEmpty) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: AppTheme.ink.withValues(alpha: 0.75),
      child: Text(
        categoryId.toUpperCase(),
        style: const TextStyle(
          color: AppTheme.paper,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}

class _AreaBadge extends StatelessWidget {
  const _AreaBadge({required this.area});
  final String area;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (area) {
      'hotKitchen' => ('HOT', Colors.orange.shade700),
      'drinks' => ('DRINK', Colors.blue.shade700),
      _ => ('SUSHI', AppTheme.vermilion),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      color: color.withValues(alpha: 0.85),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

// ── Product Detail Dialog ─────────────────────────────────────────────────────

/// Dialog hiển thị chi tiết một sản phẩm.
class ProductDetailDialog extends StatelessWidget {
  const ProductDetailDialog({
    required this.product,
    super.key,
    this.onAddToCart,
  });

  final SushiProduct product;
  final VoidCallback? onAddToCart;

  static Future<void> show(
    BuildContext context, {
    required SushiProduct product,
    VoidCallback? onAddToCart,
  }) {
    return showDialog<void>(
      context: context,
      barrierColor: AppTheme.ink.withValues(alpha: 0.55),
      builder: (_) => ProductDetailDialog(
        product: product,
        onAddToCart: onAddToCart,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (areaLabel, areaColor) = switch (product.preparationArea) {
      PreparationArea.hotKitchen => ('Hot Kitchen', Colors.orange.shade700),
      PreparationArea.drinks => ('Drinks', Colors.blue.shade700),
      PreparationArea.sushiBar => ('Sushi Bar', AppTheme.vermilion),
    };

    return Dialog(
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SizedBox(
        width: 520,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Image ──────────────────────────────────────────────────────
            SizedBox(
              height: 240,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _ProductImage(imageUrl: product.imageUrl),
                  // Gradient overlay bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            AppTheme.ink.withValues(alpha: 0.5),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Close button
                  Positioned(
                    top: 12,
                    right: 12,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 32,
                        height: 32,
                        color: AppTheme.ink.withValues(alpha: 0.7),
                        child: const Icon(
                          Icons.close,
                          size: 16,
                          color: AppTheme.paper,
                        ),
                      ),
                    ),
                  ),
                  // Category badge
                  if (product.categoryId.isNotEmpty)
                    Positioned(
                      bottom: 14,
                      left: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        color: AppTheme.ink.withValues(alpha: 0.8),
                        child: Text(
                          product.categoryId.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.paper,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.6,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ── Info ───────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          letterSpacing: 2,
                          height: 1.2,
                        ),
                  ),
                  const SizedBox(height: 10),

                  // Price
                  Text(
                    '${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}đ',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.vermilion,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: AppTheme.rice, height: 1),
                  const SizedBox(height: 14),

                  // Description
                  if (product.description != null &&
                      product.description!.isNotEmpty) ...[
                    Text(
                      'Mô tả',
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppTheme.mutedInk,
                            letterSpacing: 2,
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      product.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            height: 1.7,
                          ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Tags row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      // Area tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border:
                              Border.all(color: areaColor.withValues(alpha: 0.4)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.kitchen, size: 12, color: areaColor),
                            const SizedBox(width: 5),
                            Text(
                              areaLabel,
                              style: TextStyle(
                                color: areaColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Availability tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: product.isAvailable
                                ? const Color(0xFF2D6A4F).withValues(alpha: 0.4)
                                : AppTheme.rice,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              product.isAvailable
                                  ? Icons.check_circle_outline
                                  : Icons.block,
                              size: 12,
                              color: product.isAvailable
                                  ? const Color(0xFF2D6A4F)
                                  : AppTheme.mutedInk,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              product.isAvailable ? 'Đang phục vụ' : 'Tạm hết',
                              style: TextStyle(
                                color: product.isAvailable
                                    ? const Color(0xFF2D6A4F)
                                    : AppTheme.mutedInk,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ── Action buttons ──────────────────────────────────────
                  Row(
                    children: [
                      // Đóng
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('ĐÓNG'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Thêm vào giỏ hàng
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: product.isAvailable
                              ? () {
                                  Navigator.of(context).pop();
                                  onAddToCart?.call();
                                }
                              : null,
                          icon: const Icon(Icons.add_shopping_cart, size: 16),
                          label: const Text('THÊM VÀO GIỎ HÀNG'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.ink,
                            foregroundColor: AppTheme.paper,
                            disabledBackgroundColor: AppTheme.rice,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            textStyle: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.8,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
