import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/enums/app_enums.dart';
import '../core/providers/firebase_providers.dart';
import '../models/table_info.dart';

part 'admin_table_view_model.g.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class AdminTableState {
  const AdminTableState({
    this.allTables = const [],
    this.searchQuery = '',
    this.statusFilter,
    this.currentPage = 0,
    this.pageSize = 10,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final List<TableInfo> allTables;
  final String searchQuery;
  final TableStatus? statusFilter;
  final int currentPage;
  final int pageSize;
  final bool isSubmitting;
  final String? errorMessage;

  // ── Derived ────────────────────────────────────────────────────────────────

  List<TableInfo> get filteredTables {
    var list = allTables;

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list
          .where((t) => t.name.toLowerCase().contains(q))
          .toList();
    }

    if (statusFilter != null) {
      list = list.where((t) => t.status == statusFilter).toList();
    }

    return list;
  }

  List<TableInfo> get pageTables {
    final filtered = filteredTables;
    final start = currentPage * pageSize;
    if (start >= filtered.length) return [];
    final end = (start + pageSize).clamp(0, filtered.length);
    return filtered.sublist(start, end);
  }

  int get totalPages {
    final count = filteredTables.length;
    if (count == 0) return 1;
    return ((count - 1) ~/ pageSize) + 1;
  }

  AdminTableState copyWith({
    List<TableInfo>? allTables,
    String? searchQuery,
    Object? statusFilter = _sentinel,
    int? currentPage,
    int? pageSize,
    bool? isSubmitting,
    Object? errorMessage = _sentinel,
  }) {
    return AdminTableState(
      allTables: allTables ?? this.allTables,
      searchQuery: searchQuery ?? this.searchQuery,
      statusFilter: statusFilter == _sentinel
          ? this.statusFilter
          : statusFilter as TableStatus?,
      currentPage: currentPage ?? this.currentPage,
      pageSize: pageSize ?? this.pageSize,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage == _sentinel
          ? this.errorMessage
          : errorMessage as String?,
    );
  }
}

const _sentinel = Object();

// ── ViewModel ─────────────────────────────────────────────────────────────────

@riverpod
class AdminTableViewModel extends _$AdminTableViewModel {
  @override
  Stream<AdminTableState> build() async* {
    final repo = ref.watch(tableRepositoryProvider);
    yield* repo.watchTables().map(
          (tables) => AdminTableState(allTables: tables),
        );
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _update(AdminTableState Function(AdminTableState s) fn) {
    final current = state.asData?.value ?? const AdminTableState();
    state = AsyncData(fn(current));
  }

  // ── Filter / Search / Pagination ──────────────────────────────────────────

  void search(String query) {
    _update((s) => s.copyWith(searchQuery: query, currentPage: 0));
  }

  void filterByStatus(TableStatus? status) {
    _update((s) => s.copyWith(statusFilter: status, currentPage: 0));
  }

  void goToPage(int page) {
    _update((s) => s.copyWith(currentPage: page));
  }

  void clearFilters() {
    _update(
      (s) => s.copyWith(
        searchQuery: '',
        statusFilter: null,
        currentPage: 0,
      ),
    );
  }

  // ── CRUD ──────────────────────────────────────────────────────────────────

  Future<void> addTable({
    required String name,
    required int capacity,
    required TableStatus status,
    String? notes,
  }) async {
    _update((s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await ref.read(tableRepositoryProvider).addTable(
            name: name,
            capacity: capacity,
            status: status.name,
            notes: notes,
          );
      _update((s) => s.copyWith(isSubmitting: false));
    } catch (e) {
      _update((s) =>
          s.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> updateTable({
    required String id,
    required String name,
    required int capacity,
    required TableStatus status,
    String? notes,
  }) async {
    _update((s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await ref.read(tableRepositoryProvider).updateTable(
            id: id,
            name: name,
            capacity: capacity,
            status: status.name,
            notes: notes,
          );
      _update((s) => s.copyWith(isSubmitting: false));
    } catch (e) {
      _update((s) =>
          s.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }

  Future<void> deleteTable(String tableId) async {
    _update((s) => s.copyWith(isSubmitting: true, errorMessage: null));
    try {
      await ref.read(tableRepositoryProvider).deleteTable(tableId);
      _update((s) => s.copyWith(isSubmitting: false));
    } catch (e) {
      _update((s) =>
          s.copyWith(isSubmitting: false, errorMessage: e.toString()));
    }
  }
}
