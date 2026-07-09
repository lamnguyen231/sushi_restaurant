import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../models/sushi_product.dart';

/// Dialog thêm / chỉnh sửa sản phẩm.
class ProductFormDialog extends StatefulWidget {
  const ProductFormDialog({super.key, this.product});

  /// Nếu null → chế độ thêm mới, ngược lại → chế độ chỉnh sửa.
  final SushiProduct? product;

  /// Mở dialog và trả về dữ liệu form nếu user nhấn Lưu.
  static Future<ProductFormData?> show(
    BuildContext context, {
    SushiProduct? product,
  }) {
    return showDialog<ProductFormData>(
      context: context,
      barrierColor: AppTheme.ink.withValues(alpha: 0.5),
      builder: (_) => ProductFormDialog(product: product),
    );
  }

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _imageUrlCtrl;

  late PreparationArea _area;
  late bool _isAvailable;

  bool get _isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl =
        TextEditingController(text: p != null ? p.price.toStringAsFixed(0) : '');
    _categoryCtrl = TextEditingController(text: p?.categoryId ?? '');
    _descCtrl = TextEditingController(text: p?.description ?? '');
    _imageUrlCtrl = TextEditingController(text: p?.imageUrl ?? '');
    _area = p?.preparationArea ?? PreparationArea.sushiBar;
    _isAvailable = p?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _categoryCtrl.dispose();
    _descCtrl.dispose();
    _imageUrlCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      ProductFormData(
        id: widget.product?.id,
        name: _nameCtrl.text.trim(),
        price: double.parse(_priceCtrl.text.trim()),
        categoryId: _categoryCtrl.text.trim(),
        description:
            _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        imageUrl:
            _imageUrlCtrl.text.trim().isEmpty ? null : _imageUrlCtrl.text.trim(),
        isAvailable: _isAvailable,
        preparationArea: _area,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: SizedBox(
        width: 560,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _isEditing ? 'CHỈNH SỬA SẢN PHẨM' : 'THÊM SẢN PHẨM',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: AppTheme.rice, height: 1),
                const SizedBox(height: 24),

                // Name
                _FieldLabel('Tên sản phẩm *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(hintText: 'VD: Salmon Sashimi'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Bắt buộc nhập tên' : null,
                ),
                const SizedBox(height: 16),

                // Price
                _FieldLabel('Giá (VNĐ) *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(hintText: 'VD: 85000'),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Bắt buộc nhập giá';
                    final n = double.tryParse(v);
                    if (n == null || n <= 0) return 'Giá phải > 0';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Category
                _FieldLabel('Category *'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _categoryCtrl,
                  decoration:
                      const InputDecoration(hintText: 'VD: sashimi, rolls, drinks'),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Bắt buộc nhập category'
                      : null,
                ),
                const SizedBox(height: 16),

                // Preparation Area
                _FieldLabel('Khu vực chế biến *'),
                const SizedBox(height: 8),
                _AreaSelector(
                  selected: _area,
                  onChanged: (a) => setState(() => _area = a),
                ),
                const SizedBox(height: 16),

                // Description
                _FieldLabel('Mô tả (tuỳ chọn)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'Mô tả ngắn về món ăn...',
                    alignLabelWithHint: true,
                  ),
                ),
                const SizedBox(height: 16),

                // Image URL
                _FieldLabel('URL hình ảnh (tuỳ chọn)'),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _imageUrlCtrl,
                  decoration:
                      const InputDecoration(hintText: 'https://...'),
                ),
                const SizedBox(height: 20),

                // Availability switch
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.rice),
                  ),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Hiển thị cho khách hàng',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      Switch(
                        value: _isAvailable,
                        activeThumbColor: AppTheme.vermilion,
                        onChanged: (v) => setState(() => _isAvailable = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('HỦY'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ink,
                          foregroundColor: AppTheme.paper,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                          ),
                        ),
                        child: Text(_isEditing ? 'LƯU THAY ĐỔI' : 'THÊM MÓN'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Sub widgets ───────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.6,
        color: AppTheme.mutedInk,
      ),
    );
  }
}

class _AreaSelector extends StatelessWidget {
  const _AreaSelector({required this.selected, required this.onChanged});
  final PreparationArea selected;
  final ValueChanged<PreparationArea> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: PreparationArea.values.map((area) {
        final isSelected = area == selected;
        final (label, color) = switch (area) {
          PreparationArea.sushiBar => ('Sushi Bar', AppTheme.vermilion),
          PreparationArea.hotKitchen => ('Hot Kitchen', Colors.orange.shade700),
          PreparationArea.drinks => ('Drinks', Colors.blue.shade700),
        };
        return Expanded(
          child: GestureDetector(
            onTap: () => onChanged(area),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.transparent,
                border: Border.all(
                  color: isSelected ? color : AppTheme.rice,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: isSelected ? Colors.white : AppTheme.mutedInk,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── Data class ────────────────────────────────────────────────────────────────

class ProductFormData {
  const ProductFormData({
    required this.name,
    required this.price,
    required this.categoryId,
    required this.isAvailable,
    required this.preparationArea,
    this.id,
    this.description,
    this.imageUrl,
  });

  final String? id;
  final String name;
  final double price;
  final String categoryId;
  final bool isAvailable;
  final PreparationArea preparationArea;
  final String? description;
  final String? imageUrl;
}
