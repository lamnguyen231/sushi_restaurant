import 'package:sushi_restaurant/core/enums/app_enums.dart';

class PendingOrderItem {
  const PendingOrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.name,
    required this.unitPrice,
    required this.quantity,
    this.note,
    required this.lineTotal,
  });

  final int? id;
  final String orderId;
  final String productId;
  final String name;
  final double unitPrice;
  final int quantity;
  final String? note;
  final double lineTotal;

  factory PendingOrderItem.fromMap(Map<String, dynamic> map) {
    return PendingOrderItem(
      id: map['id'] as int?,
      orderId: map['order_id'] as String,
      productId: map['product_id'] as String,
      name: map['name'] as String,
      unitPrice: (map['unit_price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      note: map['note'] as String?,
      lineTotal: (map['line_total'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'order_id': orderId,
      'product_id': productId,
      'name': name,
      'unit_price': unitPrice,
      'quantity': quantity,
      'note': note,
      'line_total': lineTotal,
    };
  }
}

class PendingOrder {
  const PendingOrder({
    required this.localId,
    this.remoteOrderId,
    required this.idempotencyKey,
    required this.sessionId,
    required this.tableId,
    required this.status,
    this.retryCount = 0,
    this.lastError,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
    this.items = const [],
  });

  final String localId;
  final String? remoteOrderId;
  final String idempotencyKey;
  final String sessionId;
  final String tableId;
  final SyncStatus status;
  final int retryCount;
  final String? lastError;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;
  final List<PendingOrderItem> items;

  factory PendingOrder.fromMap(Map<String, dynamic> map, {List<PendingOrderItem> items = const []}) {
    return PendingOrder(
      localId: map['local_id'] as String,
      remoteOrderId: map['remote_order_id'] as String?,
      idempotencyKey: map['idempotency_key'] as String,
      sessionId: map['session_id'] as String,
      tableId: map['table_id'] as String,
      status: SyncStatus.values.firstWhere(
        (e) => e.name == map['status'] as String,
        orElse: () => SyncStatus.localOnly,
      ),
      retryCount: map['retry_count'] as int? ?? 0,
      lastError: map['last_error'] as String?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      syncedAt: map['synced_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['synced_at'] as int)
          : null,
      items: items,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'local_id': localId,
      'remote_order_id': remoteOrderId,
      'idempotency_key': idempotencyKey,
      'session_id': sessionId,
      'table_id': tableId,
      'status': status.name,
      'retry_count': retryCount,
      'last_error': lastError,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'synced_at': syncedAt?.millisecondsSinceEpoch,
    };
  }

  PendingOrder copyWith({
    String? localId,
    String? remoteOrderId,
    String? idempotencyKey,
    String? sessionId,
    String? tableId,
    SyncStatus? status,
    int? retryCount,
    String? lastError,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
    List<PendingOrderItem>? items,
  }) {
    return PendingOrder(
      localId: localId ?? this.localId,
      remoteOrderId: remoteOrderId ?? this.remoteOrderId,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      sessionId: sessionId ?? this.sessionId,
      tableId: tableId ?? this.tableId,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastError: lastError ?? this.lastError,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
      items: items ?? this.items,
    );
  }
}
