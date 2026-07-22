import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../models/table_info.dart';
import '../viewmodels/admin_table_view_model.dart';
import '../widgets/menu_pagination_bar.dart';
import '../widgets/sushi_nav_bar.dart';
import '../widgets/table_form_dialog.dart';

class AdminTableScreen extends ConsumerWidget {
  const AdminTableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(adminTableViewModelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F11),
      appBar: const SushiNavBar(),
      body: asyncState.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.vermilion),
        ),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 12),
              Text(
                'Lỗi tải dữ liệu: $e',
                style: const TextStyle(color: Colors.redAccent),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        data: (state) => _AdminTableBody(state: state),
      ),
    );
  }
}

// ── Body ─────────────────────────────────────────────────────────────────────

class _AdminTableBody extends ConsumerWidget {
  const _AdminTableBody({required this.state});

  final AdminTableState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final vm = ref.read(adminTableViewModelProvider.notifier);
    final tables = state.pageTables;
    final filtered = state.filteredTables;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Header ────────────────────────────────────────────────────────
        _buildHeader(context, ref, state),

        // ── Filter + Search bar ───────────────────────────────────────────
        _buildFilterBar(context, ref, state, vm),

        // ── Stats row ─────────────────────────────────────────────────────
        _buildStatsRow(state),

        // ── Table header ──────────────────────────────────────────────────
        _buildTableHeader(),

        // ── Table list ────────────────────────────────────────────────────
        Expanded(
          child: tables.isEmpty
              ? _EmptyState(
                  hasFilters: state.searchQuery.isNotEmpty ||
                      state.statusFilter != null,
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 8),
                  itemCount: tables.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFF1E1E26)),
                  itemBuilder: (context, i) {
                    final table = tables[i];
                    return _TableRow(
                      table: table,
                      onEdit: () => _showEditDialog(context, ref, table),
                      onDelete: () => _confirmDelete(context, ref, table),
                    );
                  },
                ),
        ),

        // ── Pagination ────────────────────────────────────────────────────
        if (state.totalPages > 1)
          Container(
            color: const Color(0xFF16161B),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  '${filtered.length} bàn',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const Spacer(),
                MenuPaginationBar(
                  currentPage: state.currentPage,
                  totalPages: state.totalPages,
                  totalItems: filtered.length,
                  pageSize: state.pageSize,
                  onPageChanged: vm.goToPage,
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────────────────

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, AdminTableState state) {
    return Container(
      color: const Color(0xFF16161B),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey, size: 20),
            onPressed: () => context.go('/manager/dashboard'),
            tooltip: 'Quay lại Dashboard',
          ),
          const SizedBox(width: 8),
          const Icon(Icons.table_bar, color: AppTheme.vermilion, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'QUẢN LÝ BÀN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
                Text(
                  '${state.allTables.length} bàn trong hệ thống',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          // Add table button
          ElevatedButton.icon(
            onPressed: () => _showAddDialog(context, ref),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('THÊM BÀN'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.vermilion,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Filter bar ──────────────────────────────────────────────────────────

  Widget _buildFilterBar(
    BuildContext context,
    WidgetRef ref,
    AdminTableState state,
    AdminTableViewModel vm,
  ) {
    return Container(
      color: const Color(0xFF16161B),
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      child: Column(
        children: [
          const Divider(color: Color(0xFF2D2D35)),
          const SizedBox(height: 12),
          Row(
            children: [
              // Search field
              Expanded(
                flex: 3,
                child: TextField(
                  onChanged: vm.search,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm tên bàn...',
                    hintStyle:
                        const TextStyle(color: Color(0xFF4A4A55), fontSize: 14),
                    prefixIcon: const Icon(Icons.search,
                        color: Color(0xFF4A4A55), size: 20),
                    suffixIcon: state.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear,
                                color: Colors.grey, size: 18),
                            onPressed: () => vm.search(''),
                          )
                        : null,
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
                      borderSide: BorderSide(
                          color: AppTheme.vermilion.withOpacity(0.6)),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Status filter dropdown
              Expanded(
                flex: 2,
                child: _StatusFilterDropdown(
                  value: state.statusFilter,
                  onChanged: vm.filterByStatus,
                ),
              ),
              const SizedBox(width: 12),
              // Clear filters
              if (state.searchQuery.isNotEmpty || state.statusFilter != null)
                TextButton.icon(
                  onPressed: vm.clearFilters,
                  icon: const Icon(Icons.filter_list_off,
                      size: 16, color: Colors.grey),
                  label: const Text(
                    'Xóa lọc',
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Stats row ──────────────────────────────────────────────────────────

  Widget _buildStatsRow(AdminTableState state) {
    final all = state.allTables;
    final counts = {
      for (final s in TableStatus.values)
        s: all.where((t) => t.status == s).length,
    };

    const statusConfig = {
      TableStatus.available: ('Trống', Color(0xFF10B981), Icons.check_circle),
      TableStatus.occupied: ('Bận', Color(0xFFF59E0B), Icons.people),
      TableStatus.reserved: ('Đã đặt', Color(0xFF3B82F6), Icons.event),
      TableStatus.cleaning: ('Dọn dẹp', Color(0xFF8B5CF6), Icons.cleaning_services),
      TableStatus.disabled: ('Ngừng dùng', Color(0xFF6B7280), Icons.block),
    };

    return Container(
      color: const Color(0xFF12121A),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            ...TableStatus.values.map((s) {
              final (label, color, icon) = statusConfig[s]!;
              final count = counts[s] ?? 0;
              return Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _StatChip(
                    label: label, count: count, color: color, icon: icon),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Table column header ─────────────────────────────────────────────────

  Widget _buildTableHeader() {
    return Container(
      color: const Color(0xFF0D0D14),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: const Row(
        children: [
          _ColHeader('TÊN BÀN', flex: 3),
          _ColHeader('SỨC CHỨA', flex: 2),
          _ColHeader('TRẠNG THÁI', flex: 2),
          _ColHeader('SESSION', flex: 2),
          _ColHeader('THAO TÁC', flex: 2),
        ],
      ),
    );
  }

  // ── Dialogs ─────────────────────────────────────────────────────────────

  Future<void> _showAddDialog(BuildContext context, WidgetRef ref) async {
    final data = await TableFormDialog.show(context);
    if (data == null) return;

    await ref.read(adminTableViewModelProvider.notifier).addTable(
          name: data.name,
          capacity: data.capacity,
          status: data.status,
          notes: data.notes,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã thêm "${data.name}" thành công!'),
          backgroundColor: const Color(0xFF10B981),
        ),
      );
    }
  }

  Future<void> _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    TableInfo table,
  ) async {
    final data = await TableFormDialog.show(context, table: table);
    if (data == null) return;

    await ref.read(adminTableViewModelProvider.notifier).updateTable(
          id: table.id,
          name: data.name,
          capacity: data.capacity,
          status: data.status,
          notes: data.notes,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã cập nhật thông tin bàn!'),
          backgroundColor: Color(0xFF3B82F6),
        ),
      );
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    TableInfo table,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => _DeleteConfirmDialog(tableName: table.name),
    );

    if (confirmed != true) return;

    await ref.read(adminTableViewModelProvider.notifier).deleteTable(table.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xóa bàn "${table.name}"'),
          backgroundColor: AppTheme.vermilion,
        ),
      );
    }
  }
}

// ── Row widget ────────────────────────────────────────────────────────────────

class _TableRow extends StatefulWidget {
  const _TableRow({
    required this.table,
    required this.onEdit,
    required this.onDelete,
  });

  final TableInfo table;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  State<_TableRow> createState() => _TableRowState();
}

class _TableRowState extends State<_TableRow> {
  bool _hovered = false;

  static const _statusConfig = {
    TableStatus.available: ('Trống', Color(0xFF10B981)),
    TableStatus.occupied: ('Đang dùng', Color(0xFFF59E0B)),
    TableStatus.reserved: ('Đã đặt', Color(0xFF3B82F6)),
    TableStatus.cleaning: ('Đang dọn', Color(0xFF8B5CF6)),
    TableStatus.disabled: ('Ngừng dùng', Color(0xFF6B7280)),
  };

  @override
  Widget build(BuildContext context) {
    final (statusLabel, statusColor) =
        _statusConfig[widget.table.status] ?? ('Unknown', Colors.grey);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        color: _hovered
            ? const Color(0xFF1A1A22)
            : const Color(0xFF16161B),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        child: Row(
          children: [
            // Tên bàn
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.table_bar,
                        color: statusColor, size: 18),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.table.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'ID: ${widget.table.id}',
                          style: const TextStyle(
                            color: Color(0xFF4A4A55),
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Sức chứa
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  const Icon(Icons.people_outline,
                      color: Colors.grey, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    '${widget.table.capacity} người',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),

            // Trạng thái
            Expanded(
              flex: 2,
              child: _StatusBadge(label: statusLabel, color: statusColor),
            ),

            // Session ID
            Expanded(
              flex: 2,
              child: widget.table.activeSessionId != null
                  ? Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF59E0B),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.table.activeSessionId!,
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    )
                  : const Text(
                      '—',
                      style: TextStyle(color: Color(0xFF4A4A55), fontSize: 13),
                    ),
            ),

            // Actions
            Expanded(
              flex: 2,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _ActionBtn(
                    icon: Icons.edit_outlined,
                    tooltip: 'Chỉnh sửa',
                    color: const Color(0xFF3B82F6),
                    onTap: widget.onEdit,
                  ),
                  const SizedBox(width: 8),
                  _ActionBtn(
                    icon: Icons.delete_outline,
                    tooltip: 'Xóa bàn',
                    color: AppTheme.vermilion,
                    onTap: widget.onDelete,
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

// ── Small widgets ─────────────────────────────────────────────────────────────

class _ColHeader extends StatelessWidget {
  const _ColHeader(this.label, {required this.flex});
  final String label;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFF4A4A55),
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.label,
    required this.count,
    required this.color,
    required this.icon,
  });

  final String label;
  final int count;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 6),
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatefulWidget {
  const _ActionBtn({
    required this.icon,
    required this.tooltip,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: _hovered
                  ? widget.color.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: _hovered
                    ? widget.color.withOpacity(0.4)
                    : Colors.transparent,
              ),
            ),
            child: Icon(widget.icon, color: widget.color, size: 18),
          ),
        ),
      ),
    );
  }
}

class _StatusFilterDropdown extends StatelessWidget {
  const _StatusFilterDropdown({required this.value, required this.onChanged});

  final TableStatus? value;
  final ValueChanged<TableStatus?> onChanged;

  static const _labels = {
    TableStatus.available: 'Trống',
    TableStatus.occupied: 'Đang dùng',
    TableStatus.reserved: 'Đã đặt',
    TableStatus.cleaning: 'Đang dọn',
    TableStatus.disabled: 'Ngừng dùng',
  };

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<TableStatus?>(
      value: value,
      onChanged: onChanged,
      dropdownColor: const Color(0xFF1E1E26),
      style: const TextStyle(color: Colors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: 'Lọc theo trạng thái',
        hintStyle: const TextStyle(color: Color(0xFF4A4A55), fontSize: 13),
        prefixIcon: const Icon(Icons.filter_list,
            color: Color(0xFF4A4A55), size: 18),
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
          borderSide:
              BorderSide(color: AppTheme.vermilion.withOpacity(0.6)),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
      items: [
        const DropdownMenuItem(
          value: null,
          child: Text('Tất cả trạng thái',
              style: TextStyle(color: Colors.grey)),
        ),
        ...TableStatus.values.map((s) => DropdownMenuItem(
              value: s,
              child: Text(
                _labels[s]!,
                style: const TextStyle(color: Colors.white),
              ),
            )),
      ],
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasFilters});
  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E26),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              hasFilters ? Icons.search_off : Icons.table_bar_outlined,
              size: 48,
              color: const Color(0xFF4A4A55),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            hasFilters ? 'Không tìm thấy bàn phù hợp' : 'Chưa có bàn nào',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasFilters) ...[
            const SizedBox(height: 6),
            const Text(
              'Thử thay đổi từ khóa hoặc bộ lọc trạng thái',
              style: TextStyle(color: Color(0xFF4A4A55), fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Delete confirmation dialog ────────────────────────────────────────────────

class _DeleteConfirmDialog extends StatelessWidget {
  const _DeleteConfirmDialog({required this.tableName});
  final String tableName;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF16161B),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFF2D2D35)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.vermilion.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                size: 32,
                color: AppTheme.vermilion,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Xác nhận xóa bàn?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bạn có chắc muốn xóa "$tableName"?\nHành động này không thể hoàn tác.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey,
                      side: const BorderSide(color: Color(0xFF2D2D35)),
                      padding: const EdgeInsets.symmetric(vertical: 13),
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
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.vermilion,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'XÓA',
                      style: TextStyle(
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
    );
  }
}
