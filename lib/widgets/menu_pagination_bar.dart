import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';

/// Thanh phân trang tái sử dụng.
class MenuPaginationBar extends StatelessWidget {
  const MenuPaginationBar({
    required this.currentPage,
    required this.totalPages,
    required this.onPageChanged,
    super.key,
    this.totalItems,
    this.pageSize,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int? totalItems;
  final int? pageSize;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

    final start = totalItems != null && pageSize != null
        ? currentPage * pageSize! + 1
        : null;
    final end = totalItems != null && pageSize != null
        ? ((currentPage + 1) * pageSize!).clamp(0, totalItems!)
        : null;

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Info text
        if (start != null && end != null) ...[
          Text(
            '$start–$end / $totalItems',
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.mutedInk,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 20),
        ],

        // Prev button
        _PageBtn(
          icon: Icons.chevron_left,
          enabled: currentPage > 0,
          onTap: () => onPageChanged(currentPage - 1),
          tooltip: 'Trang trước',
        ),
        const SizedBox(width: 4),

        // Page buttons
        ...List.generate(totalPages, (i) {
          final isSelected = i == currentPage;

          // Show: first, last, current ± 1, dots elsewhere
          if (i == 0 ||
              i == totalPages - 1 ||
              (i >= currentPage - 1 && i <= currentPage + 1)) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: _PageBtn(
                label: '${i + 1}',
                enabled: !isSelected,
                isSelected: isSelected,
                onTap: () => onPageChanged(i),
                tooltip: 'Trang ${i + 1}',
              ),
            );
          }

          // Dots (only show once between gaps)
          if (i == currentPage - 2 || i == currentPage + 2) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                '…',
                style: TextStyle(color: AppTheme.mutedInk),
              ),
            );
          }

          return const SizedBox.shrink();
        }),

        const SizedBox(width: 4),

        // Next button
        _PageBtn(
          icon: Icons.chevron_right,
          enabled: currentPage < totalPages - 1,
          onTap: () => onPageChanged(currentPage + 1),
          tooltip: 'Trang tiếp',
        ),
      ],
    );
  }
}

class _PageBtn extends StatefulWidget {
  const _PageBtn({
    required this.enabled,
    required this.onTap,
    required this.tooltip,
    this.icon,
    this.label,
    this.isSelected = false,
  }) : assert(icon != null || label != null);

  final IconData? icon;
  final String? label;
  final bool enabled;
  final bool isSelected;
  final VoidCallback onTap;
  final String tooltip;

  @override
  State<_PageBtn> createState() => _PageBtnState();
}

class _PageBtnState extends State<_PageBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.isSelected
        ? AppTheme.ink
        : _hovered && widget.enabled
            ? AppTheme.rice
            : Colors.transparent;

    final fgColor = widget.isSelected
        ? AppTheme.paper
        : widget.enabled
            ? AppTheme.ink
            : AppTheme.rice;

    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        child: GestureDetector(
          onTap: widget.enabled ? widget.onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(
                color: widget.isSelected ? AppTheme.ink : AppTheme.rice,
              ),
            ),
            child: Center(
              child: widget.icon != null
                  ? Icon(widget.icon, size: 16, color: fgColor)
                  : Text(
                      widget.label!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: fgColor,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
