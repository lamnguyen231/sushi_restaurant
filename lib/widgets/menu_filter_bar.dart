import 'package:flutter/material.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';

/// Thanh filter/search tái sử dụng cho cả admin và user menu.
class MenuFilterBar extends StatefulWidget {
  const MenuFilterBar({
    super.key,
    this.categories = const [],
    this.selectedCategory = '',
    this.selectedArea,
    this.searchQuery = '',
    this.onSearch,
    this.onCategoryChanged,
    this.onAreaChanged,
    this.onClear,
    this.showAreaFilter = false,
    this.hint = 'Tìm kiếm...',
  });

  final List<String> categories;
  final String selectedCategory;
  final PreparationArea? selectedArea;
  final String searchQuery;
  final ValueChanged<String>? onSearch;
  final ValueChanged<String>? onCategoryChanged;
  final ValueChanged<PreparationArea?>? onAreaChanged;
  final VoidCallback? onClear;
  final bool showAreaFilter;
  final String hint;

  @override
  State<MenuFilterBar> createState() => _MenuFilterBarState();
}

class _MenuFilterBarState extends State<MenuFilterBar> {
  late final TextEditingController _searchCtrl;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(MenuFilterBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery &&
        _searchCtrl.text != widget.searchQuery) {
      _searchCtrl.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  bool get _hasActiveFilter =>
      widget.searchQuery.isNotEmpty ||
      widget.selectedCategory.isNotEmpty ||
      widget.selectedArea != null;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Search row ────────────────────────────────────────────────────
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 44,
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: widget.onSearch,
                  decoration: InputDecoration(
                    hintText: widget.hint,
                    hintStyle: const TextStyle(
                      color: AppTheme.mutedInk,
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 18,
                      color: AppTheme.mutedInk,
                    ),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                ),
              ),
            ),
            if (_hasActiveFilter) ...[
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: () {
                  _searchCtrl.clear();
                  widget.onClear?.call();
                },
                icon: const Icon(Icons.clear, size: 14),
                label: const Text('XÓA BỘ LỌC'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                  ),
                ),
              ),
            ],
          ],
        ),

        // ── Category chips ───────────────────────────────────────────────
        if (widget.categories.isNotEmpty) ...[
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // All chip
                _FilterChip(
                  label: 'TẤT CẢ',
                  isSelected: widget.selectedCategory.isEmpty,
                  onTap: () => widget.onCategoryChanged?.call(''),
                  color: AppTheme.ink,
                ),
                const SizedBox(width: 6),
                ...widget.categories.map(
                  (cat) => Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: cat.toUpperCase(),
                      isSelected: widget.selectedCategory == cat,
                      onTap: () => widget.onCategoryChanged?.call(cat),
                      color: AppTheme.ink,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // ── Area filter (admin only) ──────────────────────────────────────
        if (widget.showAreaFilter) ...[
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'ALL AREAS',
                  isSelected: widget.selectedArea == null,
                  onTap: () => widget.onAreaChanged?.call(null),
                  color: AppTheme.mutedInk,
                ),
                const SizedBox(width: 6),
                ...PreparationArea.values.map((area) {
                  final (label, color) = switch (area) {
                    PreparationArea.sushiBar =>
                      ('SUSHI BAR', AppTheme.vermilion),
                    PreparationArea.hotKitchen =>
                      ('HOT KITCHEN', Colors.orange.shade700),
                    PreparationArea.drinks => ('DRINKS', Colors.blue.shade700),
                  };
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: _FilterChip(
                      label: label,
                      isSelected: widget.selectedArea == area,
                      onTap: () => widget.onAreaChanged?.call(area),
                      color: color,
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.color,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : AppTheme.rice,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: isSelected ? Colors.white : AppTheme.mutedInk,
          ),
        ),
      ),
    );
  }
}
