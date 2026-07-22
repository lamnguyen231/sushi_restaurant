import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../models/table_info.dart';

/// Kết quả form bàn.
class TableFormData {
  const TableFormData({
    required this.name,
    required this.capacity,
    required this.status,
    this.notes,
  });

  final String name;
  final int capacity;
  final TableStatus status;
  final String? notes;
}

/// Dialog thêm / sửa bàn ăn.
class TableFormDialog extends StatefulWidget {
  const TableFormDialog({super.key, this.table});

  final TableInfo? table;

  static Future<TableFormData?> show(
    BuildContext context, {
    TableInfo? table,
  }) {
    return showDialog<TableFormData>(
      context: context,
      barrierDismissible: false,
      builder: (_) => TableFormDialog(table: table),
    );
  }

  @override
  State<TableFormDialog> createState() => _TableFormDialogState();
}

class _TableFormDialogState extends State<TableFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _capacityCtrl;
  late final TextEditingController _notesCtrl;
  late TableStatus _status;

  bool get _isEditing => widget.table != null;

  @override
  void initState() {
    super.initState();
    final t = widget.table;
    _nameCtrl = TextEditingController(text: t?.name ?? '');
    _capacityCtrl = TextEditingController(
        text: t != null ? t.capacity.toString() : '');
    _notesCtrl = TextEditingController();
    _status = t?.status ?? TableStatus.available;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _capacityCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(
      TableFormData(
        name: _nameCtrl.text.trim(),
        capacity: int.parse(_capacityCtrl.text.trim()),
        status: _status,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF16161B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2D2D35)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.vermilion.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        _isEditing ? Icons.edit_rounded : Icons.table_bar_rounded,
                        color: AppTheme.vermilion,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isEditing ? 'CHỈNH SỬA BÀN' : 'THÊM BÀN MỚI',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.5,
                            ),
                          ),
                          if (_isEditing)
                            Text(
                              'ID: ${widget.table!.id}',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 11,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Divider(color: Color(0xFF2D2D35)),
                const SizedBox(height: 20),

                // Tên bàn
                _FormLabel('Tên bàn *'),
                const SizedBox(height: 6),
                _DarkTextField(
                  controller: _nameCtrl,
                  hint: 'VD: Bàn 01, Bàn VIP 1...',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Tên bàn không được để trống';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Sức chứa
                _FormLabel('Sức chứa (người) *'),
                const SizedBox(height: 6),
                _DarkTextField(
                  controller: _capacityCtrl,
                  hint: 'VD: 4',
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Vui lòng nhập sức chứa';
                    }
                    final n = int.tryParse(v.trim());
                    if (n == null || n < 1) {
                      return 'Sức chứa tối thiểu là 1';
                    }
                    if (n > 50) return 'Sức chứa tối đa là 50';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Trạng thái
                _FormLabel('Trạng thái'),
                const SizedBox(height: 6),
                _StatusDropdown(
                  value: _status,
                  onChanged: (v) => setState(() => _status = v!),
                ),
                const SizedBox(height: 16),

                // Ghi chú
                _FormLabel('Ghi chú (tuỳ chọn)'),
                const SizedBox(height: 6),
                _DarkTextField(
                  controller: _notesCtrl,
                  hint: 'Thêm ghi chú về bàn...',
                  maxLines: 3,
                ),
                const SizedBox(height: 28),

                // Actions
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          side: const BorderSide(color: Color(0xFF2D2D35)),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'HỦY',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.vermilion,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isEditing ? 'CẬP NHẬT' : 'THÊM BÀN',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.5,
                          ),
                        ),
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

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _FormLabel extends StatelessWidget {
  const _FormLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _DarkTextField extends StatelessWidget {
  const _DarkTextField({
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.inputFormatters,
    this.maxLines = 1,
  });

  final TextEditingController controller;
  final String hint;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF4A4A55), fontSize: 14),
        filled: true,
        fillColor: const Color(0xFF1E1E26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D2D35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D2D35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.vermilion.withOpacity(0.6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  const _StatusDropdown({required this.value, required this.onChanged});

  final TableStatus value;
  final ValueChanged<TableStatus?> onChanged;

  static const _labels = {
    TableStatus.available: ('Trống', Color(0xFF10B981)),
    TableStatus.occupied: ('Đang dùng', Color(0xFFF59E0B)),
    TableStatus.reserved: ('Đã đặt', Color(0xFF3B82F6)),
    TableStatus.cleaning: ('Đang dọn', Color(0xFF8B5CF6)),
    TableStatus.disabled: ('Ngừng dùng', Color(0xFF6B7280)),
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TableStatus>(
      value: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF1E1E26),
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFF1E1E26),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D2D35)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2D2D35)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: AppTheme.vermilion.withOpacity(0.6)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: TableStatus.values.map((s) {
        final (label, color) = _labels[s]!;
        return DropdownMenuItem(
          value: s,
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        );
      }).toList(),
    );
  }
}
