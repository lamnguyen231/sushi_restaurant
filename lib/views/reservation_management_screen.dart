import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../models/reservation.dart';
import '../models/table_info.dart';
import '../viewmodels/reservation_management_view_model.dart';
import '../viewmodels/table_selection_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/ink_frame.dart';
import '../widgets/loading_view.dart';
import '../widgets/sushi_nav_bar.dart';

class ReservationManagementScreen extends ConsumerStatefulWidget {
  const ReservationManagementScreen({super.key});

  @override
  ConsumerState<ReservationManagementScreen> createState() =>
      _ReservationManagementScreenState();
}

class _ReservationManagementScreenState
    extends ConsumerState<ReservationManagementScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  ReservationStatus? _selectedStatusFilter;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reservationsState = ref.watch(reservationManagementViewModelProvider);

    return Scaffold(
      appBar: const SushiNavBar(),
      backgroundColor: AppTheme.eggshell,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Header Bar ────────────────────────────────────────────────────
          Container(
            color: AppTheme.paper,
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 20),
                  onPressed: () => context.go('/staff/tables'),
                  tooltip: 'Về quản lý bàn',
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'QUẢN LÝ ĐẶT BÀN',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Confirm, assign tables, complete, or cancel reservations',
                        style: TextStyle(color: AppTheme.mutedInk, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppTheme.rice),

          // ── Main Content / States ─────────────────────────────────────────
          Expanded(
            child: reservationsState.when(
              loading: () =>
                  const LoadingView(message: 'Đang tải danh sách đặt bàn...'),
              error: (error, stack) =>
                  ErrorView(message: 'Lỗi tải đặt bàn: $error'),
              data: (reservations) {
                // Calculate Alerts
                final pendingList = reservations
                    .where((r) => r.status == ReservationStatus.pending)
                    .toList();
                final today = DateTime.now();
                final todayList = reservations.where((r) {
                  return r.status == ReservationStatus.confirmed &&
                      r.reservationDateTime.year == today.year &&
                      r.reservationDateTime.month == today.month &&
                      r.reservationDateTime.day == today.day;
                }).toList();

                // Apply Filters
                var filteredList = reservations;
                if (_selectedStatusFilter != null) {
                  filteredList = filteredList
                      .where((r) => r.status == _selectedStatusFilter)
                      .toList();
                }
                if (_searchQuery.isNotEmpty) {
                  filteredList = filteredList.where((r) {
                    final query = _searchQuery.toLowerCase();
                    return r.customerName.toLowerCase().contains(query) ||
                        r.phone.contains(query);
                  }).toList();
                }

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Alerts Section
                    if (pendingList.isNotEmpty || todayList.isNotEmpty)
                      _buildAlertsSection(pendingList, todayList),

                    // Filter and Search Header
                    _buildFilterAndSearchSection(),

                    // List of Reservations
                    Expanded(
                      child: filteredList.isEmpty
                          ? const EmptyStateView(
                              message: 'Không tìm thấy đặt bàn nào.',
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.all(24),
                              itemCount: filteredList.length,
                              itemBuilder: (context, index) {
                                return _buildReservationCard(
                                    filteredList[index]);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Alerts Section ────────────────────────────────────────────────────────
  Widget _buildAlertsSection(
    List<Reservation> pending,
    List<Reservation> todayList,
  ) {
    return Container(
      color: AppTheme.paper,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        children: [
          if (pending.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.vermilion.withValues(alpha: 0.08),
                border: const Border(
                  left: BorderSide(color: AppTheme.vermilion, width: 4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: AppTheme.vermilion, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Có ${pending.length} yêu cầu đặt bàn đang CHỜ XÁC NHẬN. Vui lòng xác nhận hoặc từ chối.',
                      style: const TextStyle(
                        color: AppTheme.vermilion,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (todayList.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.moss.withValues(alpha: 0.08),
                border: const Border(
                  left: BorderSide(color: AppTheme.moss, width: 4),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline,
                      color: AppTheme.moss, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Có ${todayList.length} lượt đặt bàn ĐÃ XÁC NHẬN trong ngày hôm nay. Chuẩn bị xếp chỗ cho khách.',
                      style: const TextStyle(
                        color: AppTheme.moss,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Search & Filter Section ───────────────────────────────────────────────
  Widget _buildFilterAndSearchSection() {
    return Container(
      color: AppTheme.paper,
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: Column(
        children: [
          // Search Box
          TextField(
            controller: _searchController,
            onChanged: (val) => setState(() => _searchQuery = val.trim()),
            style: const TextStyle(fontSize: 14, fontFamily: 'Georgia'),
            decoration: InputDecoration(
              hintText: 'Tìm theo tên hoặc số điện thoại khách hàng...',
              prefixIcon: const Icon(Icons.search, size: 20, color: AppTheme.mutedInk),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 12),
          // Filter Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(null, 'Tất cả'),
                const SizedBox(width: 8),
                _buildFilterChip(ReservationStatus.pending, 'Chờ xác nhận'),
                const SizedBox(width: 8),
                _buildFilterChip(ReservationStatus.confirmed, 'Đã xác nhận'),
                const SizedBox(width: 8),
                _buildFilterChip(ReservationStatus.seated, 'Đang ngồi bàn'),
                const SizedBox(width: 8),
                _buildFilterChip(ReservationStatus.completed, 'Hoàn thành'),
                const SizedBox(width: 8),
                _buildFilterChip(ReservationStatus.cancelled, 'Đã hủy'),
                const SizedBox(width: 8),
                _buildFilterChip(ReservationStatus.noShow, 'Vắng mặt'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(ReservationStatus? status, String label) {
    final isSelected = _selectedStatusFilter == status;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : AppTheme.ink,
        ),
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() => _selectedStatusFilter = status);
        }
      },
      selectedColor: AppTheme.ink,
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
        side: BorderSide(color: AppTheme.ink),
      ),
      checkmarkColor: Colors.white,
    );
  }

  // ── Reservation Card Widget ───────────────────────────────────────────────
  Widget _buildReservationCard(Reservation r) {
    final dateStr = DateFormat('dd/MM/yyyy').format(r.reservationDateTime);
    final timeStr = DateFormat('HH:mm').format(r.reservationDateTime);
    final createdStr = DateFormat('dd/MM HH:mm').format(r.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: InkFrame(
        backgroundColor: AppTheme.paper,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Row: Name and Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    r.customerName.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                _buildStatusBadge(r.status),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: AppTheme.rice, height: 1),
            const SizedBox(height: 12),

            // Middle Block: Booking details
            Wrap(
              spacing: 24,
              runSpacing: 10,
              children: [
                _buildDetailItem(Icons.phone_outlined, r.phone),
                _buildDetailItem(Icons.calendar_today_outlined, '$dateStr - $timeStr'),
                _buildDetailItem(Icons.people_outline, '${r.guestCount} khách'),
                if (r.assignedTableId != null)
                  _buildDetailItem(
                    Icons.table_bar,
                    'Bàn: ${r.assignedTableId}',
                    highlighted: true,
                  )
                else
                  _buildDetailItem(
                    Icons.table_bar_outlined,
                    'Chưa gán bàn',
                    dimmed: true,
                  ),
              ],
            ),

            if (r.note != null && r.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                color: AppTheme.eggshell,
                child: Text(
                  'Ghi chú: ${r.note}',
                  style: const TextStyle(fontSize: 13, color: AppTheme.mutedInk),
                ),
              ),
            ],

            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'Yêu cầu gửi lúc: $createdStr',
                style: const TextStyle(fontSize: 11, color: AppTheme.mutedInk),
              ),
            ),

            // Action Buttons Row
            const SizedBox(height: 16),
            _buildActionButtons(r),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(IconData icon, String text,
      {bool highlighted = false, bool dimmed = false}) {
    Color color = AppTheme.ink;
    if (highlighted) color = AppTheme.vermilion;
    if (dimmed) color = AppTheme.mutedInk;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            fontWeight: highlighted ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(ReservationStatus status) {
    Color bg = AppTheme.eggshell;
    Color fg = AppTheme.ink;

    switch (status) {
      case ReservationStatus.pending:
        bg = Colors.amber.shade100;
        fg = Colors.amber.shade900;
        break;
      case ReservationStatus.confirmed:
        bg = AppTheme.moss.withValues(alpha: 0.12);
        fg = AppTheme.moss;
        break;
      case ReservationStatus.arrived:
      case ReservationStatus.seated:
        bg = Colors.blue.shade100;
        fg = Colors.blue.shade900;
        break;
      case ReservationStatus.completed:
        bg = AppTheme.ink.withValues(alpha: 0.08);
        fg = AppTheme.ink;
        break;
      case ReservationStatus.cancelled:
        bg = AppTheme.vermilion.withValues(alpha: 0.12);
        fg = AppTheme.vermilion;
        break;
      case ReservationStatus.noShow:
        bg = Colors.grey.shade300;
        fg = Colors.grey.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.zero,
        border: Border.all(color: fg.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: fg,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── Action Buttons Logic ──────────────────────────────────────────────────
  Widget _buildActionButtons(Reservation r) {
    if (r.status == ReservationStatus.pending) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => _updateStatus(r.id, ReservationStatus.cancelled),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.vermilion,
              side: const BorderSide(color: AppTheme.vermilion),
            ),
            child: const Text('TỪ CHỐI / HỦY'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _showAssignTableDialog(r),
            child: const Text('GÁN BÀN'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _updateStatus(r.id, ReservationStatus.confirmed),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.moss,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('XÁC NHẬN'),
          ),
        ],
      );
    }

    if (r.status == ReservationStatus.confirmed) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: () => _updateStatus(r.id, ReservationStatus.noShow),
            child: const Text('VẮNG MẶT'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _updateStatus(r.id, ReservationStatus.cancelled),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.vermilion,
              side: const BorderSide(color: AppTheme.vermilion),
            ),
            child: const Text('HỦY ĐẶT'),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => _showAssignTableDialog(r),
            child: const Text('ĐỔI BÀN'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () => _updateStatus(r.id, ReservationStatus.seated),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.moss,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('XẾP CHỖ (SEATED)'),
          ),
        ],
      );
    }

    if (r.status == ReservationStatus.seated) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton(
            onPressed: () => _updateStatus(r.id, ReservationStatus.completed),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.ink,
              foregroundColor: Colors.white,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            ),
            child: const Text('HOÀN THÀNH'),
          ),
        ],
      );
    }

    // Completed, Cancelled, or No Show
    return const SizedBox.shrink();
  }

  Future<void> _updateStatus(String id, ReservationStatus status) async {
    try {
      await ref
          .read(reservationManagementViewModelProvider.notifier)
          .updateStatus(id, status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đã cập nhật trạng thái sang ${status.name}.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  // ── Table Assignment Dialog ───────────────────────────────────────────────
  void _showAssignTableDialog(Reservation r) {
    showDialog(
      context: context,
      builder: (context) {
        return _AssignTableDialog(
          reservation: r,
          onAssigned: (tableId) async {
            try {
              await ref
                  .read(reservationManagementViewModelProvider.notifier)
                  .assignTable(r.id, tableId);
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      tableId != null
                          ? 'Đã gán bàn $tableId cho khách.'
                          : 'Đã hủy gán bàn.',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi gán bàn: $e')),
                );
              }
            }
          },
        );
      },
    );
  }
}

// ── Supporting Widget: Assign Table Dialog ──────────────────────────────────
class _AssignTableDialog extends ConsumerWidget {
  const _AssignTableDialog({
    required this.reservation,
    required this.onAssigned,
  });

  final Reservation reservation;
  final ValueChanged<String?> onAssigned;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesState = ref.watch(tableSelectionViewModelProvider);

    return Dialog(
      backgroundColor: AppTheme.paper,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
        padding: const EdgeInsets.all(28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'GÁN BÀN CHO KHÁCH',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Khách hàng: ${reservation.customerName} (${reservation.guestCount} khách)',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppTheme.mutedInk, fontSize: 13),
            ),
            const SizedBox(height: 20),
            const Divider(color: AppTheme.rice),
            const SizedBox(height: 10),

            // Tables list
            Expanded(
              child: tablesState.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Lỗi tải danh sách bàn: $e')),
                data: (tables) {
                  if (tables.isEmpty) {
                    return const Center(child: Text('Không tìm thấy bàn nào.'));
                  }

                  // Sort tables so available are first, and capacity matches best
                  final sortedTables = List<TableInfo>.from(tables)
                    ..sort((a, b) {
                      // available first
                      final aAvail = a.status == TableStatus.available ? 0 : 1;
                      final bAvail = b.status == TableStatus.available ? 0 : 1;
                      if (aAvail != bAvail) return aAvail.compareTo(bAvail);
                      return a.capacity.compareTo(b.capacity);
                    });

                  return ListView.builder(
                    itemCount: sortedTables.length,
                    itemBuilder: (context, idx) {
                      final t = sortedTables[idx];
                      final isCurrent = reservation.assignedTableId == t.id;
                      final isAvailable = t.status == TableStatus.available;
                      final isSuitable = t.capacity >= reservation.guestCount;

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                        title: Row(
                          children: [
                            Text(
                              t.name.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: isCurrent ? AppTheme.vermilion : AppTheme.ink,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              color: isSuitable
                                  ? AppTheme.eggshell
                                  : AppTheme.vermilion.withValues(alpha: 0.1),
                              child: Text(
                                '${t.capacity} chỗ',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isSuitable
                                      ? AppTheme.mutedInk
                                      : AppTheme.vermilion,
                                  fontWeight: isSuitable
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          t.status.name.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color: isAvailable
                                ? AppTheme.moss
                                : AppTheme.vermilion,
                          ),
                        ),
                        trailing: Icon(
                          isCurrent
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          color: isCurrent ? AppTheme.vermilion : AppTheme.mutedInk,
                        ),
                        enabled: isAvailable || isCurrent,
                        onTap: () => onAssigned(t.id),
                      );
                    },
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            const Divider(color: AppTheme.rice),
            const SizedBox(height: 16),
            Row(
              children: [
                if (reservation.assignedTableId != null) ...[
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => onAssigned(null),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.vermilion,
                        side: const BorderSide(color: AppTheme.vermilion),
                      ),
                      child: const Text('BỎ GÁN BÀN'),
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('HỦY'),
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
