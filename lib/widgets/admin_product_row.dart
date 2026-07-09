import 'package:flutter/material.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../models/sushi_product.dart';

/// Một hàng sản phẩm trong bảng quản lý admin.
class AdminProductRow extends StatelessWidget {
  const AdminProductRow({
    required this.product,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  final SushiProduct product;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.isAvailable;

    return Container(
      decoration: BoxDecoration(
        color: isAvailable ? AppTheme.paper : AppTheme.eggshell,
        border: const Border(
          bottom: BorderSide(color: AppTheme.rice),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Image thumbnail
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.rice),
                color: AppTheme.eggshell,
              ),
              child: product.imageUrl != null && product.imageUrl!.isNotEmpty
                  ? Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) =>
                          const Icon(Icons.restaurant, color: AppTheme.rice),
                    )
                  : const Icon(Icons.restaurant, color: AppTheme.rice),
            ),
            const SizedBox(width: 14),

            // Name + description
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontSize: 14,
                        ),
                  ),
                  if (product.description != null &&
                      product.description!.isNotEmpty)
                    Text(
                      product.description!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 12,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),

            // Category
            Expanded(
              flex: 2,
              child: _InfoChip(
                label: product.categoryId.isEmpty ? '—' : product.categoryId,
                color: AppTheme.ink,
              ),
            ),

            // Area
            Expanded(
              flex: 2,
              child: _AreaChip(area: product.preparationArea),
            ),

            // Price
            SizedBox(
              width: 90,
              child: Text(
                '${product.price.toStringAsFixed(0)}đ',
                textAlign: TextAlign.right,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontSize: 14,
                      color: AppTheme.vermilion,
                    ),
              ),
            ),
            const SizedBox(width: 16),

            // Status badge
            SizedBox(
              width: 82,
              child: _StatusBadge(isAvailable: isAvailable),
            ),
            const SizedBox(width: 12),

            // Actions
            _ActionButtons(onEdit: onEdit, onDelete: onDelete),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _AreaChip extends StatelessWidget {
  const _AreaChip({required this.area});
  final PreparationArea area;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (area) {
      PreparationArea.hotKitchen => ('Hot Kitchen', Colors.orange.shade700),
      PreparationArea.drinks => ('Drinks', Colors.blue.shade700),
      PreparationArea.sushiBar => ('Sushi Bar', AppTheme.vermilion),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: color,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isAvailable});
  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: isAvailable
          ? const Color(0xFF2D6A4F).withValues(alpha: 0.12)
          : AppTheme.rice.withValues(alpha: 0.5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.circle : Icons.circle_outlined,
            size: 8,
            color: isAvailable
                ? const Color(0xFF2D6A4F)
                : AppTheme.mutedInk,
          ),
          const SizedBox(width: 5),
          Text(
            isAvailable ? 'Có sẵn' : 'Ẩn',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              color: isAvailable
                  ? const Color(0xFF2D6A4F)
                  : AppTheme.mutedInk,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.onEdit, required this.onDelete});
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          tooltip: 'Chỉnh sửa',
          icon: const Icon(Icons.edit_outlined, size: 18),
          color: AppTheme.ink,
          onPressed: onEdit,
        ),
        IconButton(
          tooltip: 'Xóa',
          icon: const Icon(Icons.delete_outline, size: 18),
          color: AppTheme.vermilion,
          onPressed: onDelete,
        ),
      ],
    );
  }
}
