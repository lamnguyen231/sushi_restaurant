import 'package:flutter/foundation.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../core/enums/app_enums.dart';
import '../data/local/app_database.dart';
import '../models/pending_order.dart';

class SqlitePendingOrderService {
  // In-memory fallback for Web debugging
  final List<PendingOrder> _webMemoryDb = [];

  Future<Database> get _db async {
    if (kIsWeb) {
      throw UnsupportedError('Cannot use SQLite on Web. Using memory fallback.');
    }
    return AppDatabase.instance;
  }

  Future<void> insertPendingOrder(PendingOrder order) async {
    if (kIsWeb) {
      _webMemoryDb.add(order);
      return;
    }

    final dbClient = await _db;
    await dbClient.transaction((txn) async {
      // 1. Insert order
      await txn.insert(
        'pending_orders',
        order.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // 2. Delete old items if any (just in case)
      await txn.delete(
        'pending_order_items',
        where: 'order_id = ?',
        whereArgs: [order.localId],
      );

      // 3. Insert items
      for (final item in order.items) {
        await txn.insert(
          'pending_order_items',
          item.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }

  Future<List<PendingOrder>> getPendingOrders({String? sessionId}) async {
    if (kIsWeb) {
      if (sessionId != null) {
        return _webMemoryDb.where((e) => e.sessionId == sessionId).toList();
      }
      return List.from(_webMemoryDb);
    }

    final dbClient = await _db;
    
    final List<Map<String, dynamic>> orderMaps = await dbClient.query(
      'pending_orders',
      where: sessionId != null ? 'session_id = ?' : null,
      whereArgs: sessionId != null ? [sessionId] : null,
    );

    final List<PendingOrder> orders = [];
    for (final orderMap in orderMaps) {
      final localId = orderMap['local_id'] as String;
      final List<Map<String, dynamic>> itemMaps = await dbClient.query(
        'pending_order_items',
        where: 'order_id = ?',
        whereArgs: [localId],
      );
      final items = itemMaps.map((e) => PendingOrderItem.fromMap(e)).toList();
      orders.add(PendingOrder.fromMap(orderMap, items: items));
    }
    return orders;
  }

  Future<void> updatePendingOrderStatus({
    required String localId,
    required String status,
    String? remoteOrderId,
    String? lastError,
    int? retryCount,
    int? syncedAt,
  }) async {
    if (kIsWeb) {
      final index = _webMemoryDb.indexWhere((e) => e.localId == localId);
      if (index >= 0) {
        final existing = _webMemoryDb[index];
        _webMemoryDb[index] = existing.copyWith(
          status: SyncStatus.values.firstWhere((e) => e.name == status, orElse: () => SyncStatus.localOnly),
          remoteOrderId: remoteOrderId ?? existing.remoteOrderId,
          lastError: lastError ?? existing.lastError,
          retryCount: retryCount ?? existing.retryCount,
          syncedAt: syncedAt != null ? DateTime.fromMillisecondsSinceEpoch(syncedAt) : existing.syncedAt,
          updatedAt: DateTime.now(),
        );
      }
      return;
    }

    final dbClient = await _db;
    final Map<String, dynamic> values = {
      'status': status,
      'updated_at': DateTime.now().millisecondsSinceEpoch,
    };
    if (remoteOrderId != null) values['remote_order_id'] = remoteOrderId;
    if (lastError != null) values['last_error'] = lastError;
    if (retryCount != null) values['retry_count'] = retryCount;
    if (syncedAt != null) values['synced_at'] = syncedAt;

    await dbClient.update(
      'pending_orders',
      values,
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  Future<void> deletePendingOrder(String localId) async {
    if (kIsWeb) {
      _webMemoryDb.removeWhere((e) => e.localId == localId);
      return;
    }

    final dbClient = await _db;
    await dbClient.transaction((txn) async {
      await txn.delete(
        'pending_order_items',
        where: 'order_id = ?',
        whereArgs: [localId],
      );
      await txn.delete(
        'pending_orders',
        where: 'local_id = ?',
        whereArgs: [localId],
      );
    });
  }

  Future<void> clearSyncedOrders(String sessionId) async {
    if (kIsWeb) {
      _webMemoryDb.removeWhere((e) => e.sessionId == sessionId && e.status == SyncStatus.synced);
      return;
    }

    final dbClient = await _db;
    // Find all synced local_ids for the session
    final List<Map<String, dynamic>> maps = await dbClient.query(
      'pending_orders',
      columns: ['local_id'],
      where: 'session_id = ? AND status = ?',
      whereArgs: [sessionId, SyncStatus.synced.name],
    );

    if (maps.isEmpty) return;

    final localIds = maps.map((e) => e['local_id'] as String).toList();
    await dbClient.transaction((txn) async {
      for (final id in localIds) {
        await txn.delete(
          'pending_order_items',
          where: 'order_id = ?',
          whereArgs: [id],
        );
        await txn.delete(
          'pending_orders',
          where: 'local_id = ?',
          whereArgs: [id],
        );
      }
    });
  }
}
