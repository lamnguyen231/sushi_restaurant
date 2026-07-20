import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../core/providers/local_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/table_info.dart';
import '../viewmodels/dining_cart_view_model.dart';
import '../viewmodels/table_selection_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import '../widgets/ink_frame.dart';
import '../widgets/loading_view.dart';
import '../widgets/primary_button.dart';
import '../widgets/sushi_nav_bar.dart';

class TableSelectionScreen extends ConsumerWidget {
  const TableSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesState = ref.watch(tableSelectionViewModelProvider);
    final isManager =
        ref.watch(currentUserProvider).value?.role == UserRole.manager;

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
                        'Mở phiên cho bàn trống hoặc tiếp tục phiên của bàn đang phục vụ.',
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
                    mainAxisExtent: 290,
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
                      onResumeSession: table.activeSessionId != null
                          ? () => _resumeSession(context, ref, table)
                          : null,
                      onCancelSession:
                          isManager && table.activeSessionId != null
                          ? () => _cancelSession(context, ref, table)
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
          .startSession(table, guestCount: guestCount);

      if (!context.mounted) return;
      ref.read(currentDiningSessionProvider.notifier).setSession(session);
      await ref
          .read(deviceSessionAssignmentServiceProvider)
          .saveActiveSession(session);
      if (!context.mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đã mở phiên cho ${table.name}.')));
      GoRouter.of(context).go('/dining/menu');
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Không thể mở phiên: $error')));
    }
  }

  Future<void> _resumeSession(
    BuildContext context,
    WidgetRef ref,
    TableInfo table,
  ) async {
    try {
      final session = await ref
          .read(tableSelectionViewModelProvider.notifier)
          .resumeSession(table);

      if (!context.mounted) return;
      ref.read(currentDiningSessionProvider.notifier).setSession(session);
      await ref
          .read(deviceSessionAssignmentServiceProvider)
          .saveActiveSession(session);
      if (!context.mounted) return;

      GoRouter.of(context).go('/dining/menu');
    } catch (error) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể vào phiên: $error')),
      );
    }
  }

  Future<void> _cancelSession(
    BuildContext context,
    WidgetRef ref,
    TableInfo table,
  ) async {
    final sessionId = table.activeSessionId;
    if (sessionId == null) return;

    final pendingRepo = ref.read(localPendingOrderRepositoryProvider);
    final localOrders = await pendingRepo.getOrders(sessionId: sessionId);
    final hasUnsynced = localOrders.any(
      (order) =>
          order.status == SyncStatus.localOnly ||
          order.status == SyncStatus.failed,
    );
    if (!context.mounted) return;

    final confirmed = await _confirmCancelSession(
      context,
      table,
      hasUnsynced: hasUnsynced,
    );
    if (!context.mounted || !confirmed) return;

    try {
      await ref
          .read(tableSelectionViewModelProvider.notifier)
          .cancelSession(sessionId);

      final currentSession = ref.read(currentDiningSessionProvider);
      if (currentSession?.id == sessionId) {
        await ref
            .read(diningCartViewModelProvider(sessionId).notifier)
            .clearCart();
        await ref
            .read(deviceSessionAssignmentServiceProvider)
            .clearActiveSession();
        ref.read(currentDiningSessionProvider.notifier).clear();
      }
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đã hủy phiên của ${table.name}.')),
      );
    } catch (error) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không thể hủy phiên: $error')),
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

  Future<bool> _confirmCancelSession(
    BuildContext context,
    TableInfo table, {
    required bool hasUnsynced,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hủy phiên ${table.name}?'),
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
                          'CẢNH BÁO: Bàn này có đơn chưa đồng bộ. Nếu hủy phiên, các đơn này có thể bị mất vĩnh viễn.',
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
              const Text(
                'Phiên sẽ được đánh dấu đã hủy và bàn sẽ mở lại. Thao tác này chỉ dành cho phiên mở nhầm hoặc bị bỏ dở.',
              ),
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
              child: const Text('Xác nhận hủy phiên'),
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
    required this.onResumeSession,
    required this.onCancelSession,
  });

  final TableInfo table;
  final VoidCallback? onStartSession;
  final VoidCallback? onResumeSession;
  final VoidCallback? onCancelSession;

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
            PrimaryButton(label: 'Mở phiên', onPressed: onStartSession)
          else if (occupied && table.activeSessionId != null) ...[
            PrimaryButton(label: 'Vào phiên', onPressed: onResumeSession),
            if (onCancelSession != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: onCancelSession,
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.vermilion,
                  side: const BorderSide(color: AppTheme.vermilion),
                ),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Hủy phiên'),
              ),
            ],
          ]
          else
            PrimaryButton(label: 'Không khả dụng', onPressed: null),
        ],
      ),
    );
  }
}
