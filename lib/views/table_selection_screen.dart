import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/enums/app_enums.dart';
import '../core/theme/app_theme.dart';
import '../models/table_info.dart';
import '../viewmodels/table_selection_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/ink_frame.dart';
import '../widgets/loading_view.dart';
import '../widgets/primary_button.dart';
import '../widgets/sushi_nav_bar.dart';
import '../core/providers/local_providers.dart';

class TableSelectionScreen extends ConsumerWidget {
  const TableSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesState = ref.watch(tableSelectionViewModelProvider);

    return Scaffold(
      appBar: const SushiNavBar(),
      body: tablesState.when(
        loading: () => const LoadingView(message: 'Đang tải danh sách bàn...'),
        error: (error, stackTrace) =>
            ErrorView(message: 'Không tải được danh sách bàn: $error'),
        data: (tables) {
          if (tables.isEmpty) {
            return const EmptyStateView(
              message: 'Chưa có bàn nào. Hãy seed Firestore trước.',
            );
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                  child: Column(
                    children: [
                      Text(
                        'CHỌN BÀN',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Mở phiên dùng bữa cho bàn trống. Bàn đang bận sẽ khóa thao tác.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                sliver: SliverGrid.builder(
                  itemCount: tables.length,
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 280,
                    mainAxisExtent: 250,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                  ),
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    return _TableCard(
                      table: table,
                      onStartSession: table.status == TableStatus.available
                          ? () => _startSession(context, ref, table)
                          : null,
                      onCloseSession: table.activeSessionId != null
                          ? () => _closeSession(context, ref, table)
                          : null,
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _startSession(
    BuildContext context,
    WidgetRef ref,
    TableInfo table,
  ) async {
    final guestCount = await _askGuestCount(context, table);
    if (!context.mounted) return;

    if (guestCount == null) {
      return;
    }

    try {
      final session = await ref
          .read(tableSelectionViewModelProvider.notifier)
          .startSession(
            table,
            guestCount: guestCount,
          );

      if (!context.mounted) return;
      ref.read(currentDiningSessionProvider.notifier).setSession(session);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã mở phiên cho ${table.name}.')),
      );
      GoRouter.of(context).go('/dining/menu');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể mở phiên: $error')),
      );
    }
  }

  Future<void> _closeSession(
    BuildContext context,
    WidgetRef ref,
    TableInfo table,
  ) async {
    final sessionId = table.activeSessionId;

    if (sessionId == null) {
      return;
    }

    // P3-12: Check if there are any unsynced pending orders for this session
    final pendingRepo = ref.read(localPendingOrderRepositoryProvider);
    final localOrders = await pendingRepo.getOrders(sessionId: sessionId);
    final hasUnsynced = localOrders.any(
      (o) => o.status == SyncStatus.localOnly || o.status == SyncStatus.failed,
    );

    if (!context.mounted) return;

    final confirmed = await _confirmCloseSession(
      context,
      table,
      hasUnsynced: hasUnsynced,
    );
    if (!context.mounted) return;

    if (!confirmed) {
      return;
    }

    try {
      await ref
          .read(tableSelectionViewModelProvider.notifier)
          .closeSession(sessionId);

      if (!context.mounted) return;
      ref.read(currentDiningSessionProvider.notifier).clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã kết thúc phiên của ${table.name}.')),
      );
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể kết thúc phiên: $error')),
      );
    }
  }

  Future<int?> _askGuestCount(BuildContext context, TableInfo table) async {
    final controller = TextEditingController(text: '1');
    String? errorText;

    final result = await showDialog<int>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Mở phiên cho ${table.name}'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Số khách',
                  helperText: 'Nhập số khách thực tế đang ngồi tại bàn.',
                  errorText: errorText,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Hủy'),
                ),
                FilledButton(
                  onPressed: () {
                    final guestCount = int.tryParse(controller.text.trim());

                    if (guestCount == null) {
                      setDialogState(() {
                        errorText = 'Vui lòng nhập số khách hợp lệ.';
                      });
                      return;
                    }

                    if (guestCount <= 0) {
                      setDialogState(() {
                        errorText = 'Số khách phải lớn hơn 0.';
                      });
                      return;
                    }

                    if (guestCount > table.capacity) {
                      setDialogState(() {
                        errorText =
                            'Số khách không được vượt quá sức chứa ${table.capacity}.';
                      });
                      return;
                    }

                    Navigator.of(context).pop(guestCount);
                  },
                  child: const Text('Xác nhận mở phiên'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
    return result;
  }

  Future<bool> _confirmCloseSession(
    BuildContext context,
    TableInfo table, {
    required bool hasUnsynced,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Kết thúc phiên ${table.name}?'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasUnsynced) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade900.withOpacity(0.2),
                    border: Border.all(color: Colors.red),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'CẢNH BÁO: Bàn này hiện đang có đơn đặt món chưa đồng bộ lên hệ thống do mất kết nối. Nếu đóng phiên, các đơn hàng này có thể sẽ bị mất vĩnh viễn!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Text('Sau khi kết thúc, bàn sẽ mở lại cho phiên mới.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              style: hasUnsynced
                  ? FilledButton.styleFrom(backgroundColor: Colors.red)
                  : null,
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xác nhận kết thúc'),
            ),
          ],
        );
      },
    );

    return result ?? false;
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({
    required this.table,
    required this.onStartSession,
    required this.onCloseSession,
  });

  final TableInfo table;
  final VoidCallback? onStartSession;
  final VoidCallback? onCloseSession;

  @override
  Widget build(BuildContext context) {
    final available = table.status == TableStatus.available;
    final occupied = table.status == TableStatus.occupied;

    return InkFrame(
      backgroundColor: available ? AppTheme.paper : AppTheme.rice,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            table.name.toUpperCase(),
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          Text(
            'SỨC CHỨA',
            style: Theme.of(context).textTheme.labelLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          Text(
            '${table.capacity} khách',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          Text(
            available ? 'TRỐNG' : table.status.name.toUpperCase(),
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: available ? AppTheme.ink : AppTheme.vermilion,
                ),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          if (available)
            PrimaryButton(
              label: 'Mở phiên',
              onPressed: onStartSession,
            )
          else if (occupied && table.activeSessionId != null)
            PrimaryButton(
              label: 'Đóng phiên',
              onPressed: onCloseSession,
            )
          else
            PrimaryButton(
              label: 'Không khả dụng',
              onPressed: null,
            ),
        ],
      ),
    );
  }
}

