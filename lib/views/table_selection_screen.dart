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
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);

    try {
      await ref
          .read(tableSelectionViewModelProvider.notifier)
          .startSession(table);
      messenger.showSnackBar(
        SnackBar(content: Text('Đã mở phiên cho ${table.name}.')),
      );
      router.go('/dining/menu');
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Không thể mở phiên: $error')),
      );
    }
  }
}

class _TableCard extends StatelessWidget {
  const _TableCard({required this.table, required this.onStartSession});

  final TableInfo table;
  final VoidCallback? onStartSession;

  @override
  Widget build(BuildContext context) {
    final available = table.status == TableStatus.available;

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
          PrimaryButton(
            label: 'Mở phiên',
            onPressed: onStartSession,
          ),
        ],
      ),
    );
  }
}
