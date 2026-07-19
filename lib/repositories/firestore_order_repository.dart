import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/enums/app_enums.dart';
import '../models/cart_item.dart';
import '../models/order_item.dart';
import '../models/restaurant_order.dart';
import '../models/pending_order.dart';
import '../services/firestore_order_service.dart';
import 'order_repository.dart';
import 'local_pending_order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  const FirestoreOrderRepository(this._orderService, this._localPendingRepo);

  final FirestoreOrderService _orderService;
  final LocalPendingOrderRepository _localPendingRepo;

  @override
  Stream<List<RestaurantOrder>> watchKitchenOrders() {
    return _orderService.watchKitchenOrders().map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );
  }

  @override
  Stream<List<RestaurantOrder>> watchSessionOrders(String sessionId) {
    return _orderService.watchSessionOrders(sessionId).map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt)),
    );
  }

  @override
  Stream<List<RestaurantOrder>> watchAllOrders() {
    return _orderService.watchAllOrders().map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt)), // Newest first
    );
  }

  /// P3-01: Chuyển cart items từ SQLite thành Firestore order.
  /// P3-02: name và unitPrice được snapshot từ CartItem (đã lấy từ SQLite).
  /// P3-03: subtotal và grandTotal được tính lại trong repository,
  ///        không dùng giá trị do client truyền lên.
  /// P3-04: idempotencyKey dùng format sessionId_microseconds để đảm bảo unique.
  /// P3-05: Lưu pending order vào SQLite trước khi đồng bộ.
  /// P3-06: Tự động cập nhật trạng thái lỗi nếu offline để chờ background sync.
  @override
  Future<RestaurantOrder> placeDineInOrder({
    required String sessionId,
    required String tableId,
    required String tableName,
    required List<CartItem> cartItems,
  }) async {
    final localId = 'local_${sessionId}_${DateTime.now().microsecondsSinceEpoch}';
    final idempotencyKey =
        '${sessionId}_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();

    final orderItems = cartItems
        .map(
          (item) => OrderItem(
            productId: item.productId,
            productName: item.name,      // snapshot từ local_cart.name
            unitPrice: item.unitPrice,   // snapshot từ local_cart.unit_price
            quantity: item.quantity,
            note: item.note,
            lineTotal: item.unitPrice * item.quantity, // P3-03: tính lại, không trust client
          ),
        )
        .toList();

    final subtotal = orderItems.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );

    // P3-05: Lưu vào SQLite pending_orders & pending_order_items (CRUD Create)
    final pendingItems = orderItems.map((item) => PendingOrderItem(
      orderId: localId,
      productId: item.productId,
      name: item.productName,
      unitPrice: item.unitPrice,
      quantity: item.quantity,
      note: item.note,
      lineTotal: item.lineTotal,
    )).toList();

    final pendingOrder = PendingOrder(
      localId: localId,
      idempotencyKey: idempotencyKey,
      sessionId: sessionId,
      tableId: tableId,
      status: SyncStatus.localOnly,
      createdAt: now,
      updatedAt: now,
      items: pendingItems,
    );

    await _localPendingRepo.saveOrder(pendingOrder);

    try {
      // Đặt status sang syncing
      await _localPendingRepo.updateStatus(
        localId: localId,
        status: SyncStatus.syncing.name,
      );

      final doc = await _orderService.createOrder({
        'source': OrderSource.tableDevice.name,
        'orderType': OrderType.dineIn.name,
        'sessionId': sessionId,
        'tableId': tableId,
        'tableName': tableName,
        'items': orderItems.map(_orderItemToMap).toList(),
        'subtotal': subtotal,
        'deliveryFee': 0,
        'discount': 0,
        'grandTotal': subtotal, // P3-03: grandTotal = subtotal (no fee for dine-in)
        'status': DineInOrderStatus.pending.name,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'idempotencyKey': idempotencyKey,
      });

      // P3-05: Cập nhật status thành synced (CRUD Update)
      await _localPendingRepo.updateStatus(
        localId: localId,
        status: SyncStatus.synced.name,
        remoteOrderId: doc.id,
        syncedAt: DateTime.now().millisecondsSinceEpoch,
      );

      return RestaurantOrder(
        id: doc.id,
        source: OrderSource.tableDevice,
        orderType: OrderType.dineIn,
        sessionId: sessionId,
        tableId: tableId,
        tableName: tableName,
        items: orderItems,
        subtotal: subtotal,
        discount: 0,
        grandTotal: subtotal,
        status: DineInOrderStatus.pending,
        createdAt: now,
        updatedAt: now,
        idempotencyKey: idempotencyKey,
      );
    } catch (e) {
      // P3-06: Đánh dấu lỗi để hệ thống đồng bộ lại khi có kết nối
      await _localPendingRepo.updateStatus(
        localId: localId,
        status: SyncStatus.failed.name,
        lastError: e.toString(),
      );

      throw 'Mạng yếu. Đơn hàng đã được lưu offline và sẽ tự động gửi khi có mạng!';
    }
  }

  @override
  Future<RestaurantOrder> placeWebPickupOrder({
    required String customerName,
    required String customerPhone,
    required String pickupTime,
    required String? note,
    required List<OrderItem> items,
    String? createdBy,
  }) async {
    final idempotencyKey =
        'web_${customerPhone}_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();

    final subtotal = items.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );

    final doc = await _orderService.createOrder({
      'source': OrderSource.web.name,
      'orderType': OrderType.pickup.name,
      'customer': {
        'name': customerName,
        'phone': customerPhone,
        'pickupTime': pickupTime,
        'note': note,
      },
      'items': items.map(_orderItemToMap).toList(),
      'subtotal': subtotal,
      'deliveryFee': 0.0,
      'discount': 0.0,
      'grandTotal': subtotal,
      'status': DineInOrderStatus.pending.name,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'idempotencyKey': idempotencyKey,
      'createdBy': createdBy,
    });

    return RestaurantOrder(
      id: doc.id,
      source: OrderSource.web,
      orderType: OrderType.pickup,
      items: items,
      subtotal: subtotal,
      discount: 0.0,
      grandTotal: subtotal,
      status: DineInOrderStatus.pending,
      createdAt: now,
      updatedAt: now,
      idempotencyKey: idempotencyKey,
      createdBy: createdBy,
      customerName: customerName,
      customerPhone: customerPhone,
    );
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {
    // P3-09: Implement kitchen status update
    await _orderService.updateOrderStatus(orderId: orderId, status: status);
  }

  RestaurantOrder _fromDoc(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();
    final itemsData = data['items'] as List<dynamic>? ?? const [];
    final items = itemsData
        .whereType<Map<String, dynamic>>()
        .map(
          (item) => OrderItem(
            productId: item['productId'] as String? ?? '',
            productName: item['productName'] as String? ?? '',
            unitPrice: (item['unitPrice'] as num? ?? 0).toDouble(),
            quantity: item['quantity'] as int? ?? 0,
            note: item['note'] as String?,
            lineTotal: (item['lineTotal'] as num? ?? 0).toDouble(),
          ),
        )
        .toList();

    // Parse status từ string Firestore sang enum
    final statusStr = data['status'] as String? ?? 'pending';
    final status = DineInOrderStatus.values.firstWhere(
      (e) => e.name == statusStr,
      orElse: () => DineInOrderStatus.pending,
    );

    // Parse timestamps
    final createdAtTs = data['createdAt'];
    final updatedAtTs = data['updatedAt'];
    final createdAt = createdAtTs is Timestamp
        ? createdAtTs.toDate()
        : DateTime.now();
    final updatedAt = updatedAtTs is Timestamp
        ? updatedAtTs.toDate()
        : DateTime.now();

    final customerData = data['customer'] as Map<String, dynamic>?;
    final customerName = customerData?['name'] as String?;
    final customerPhone = customerData?['phone'] as String?;

    return RestaurantOrder(
      id: doc.id,
      source: OrderSource.values.firstWhere(
        (e) => e.name == (data['source'] as String? ?? 'tableDevice'),
        orElse: () => OrderSource.tableDevice,
      ),
      orderType: OrderType.values.firstWhere(
        (e) => e.name == (data['orderType'] as String? ?? 'dineIn'),
        orElse: () => OrderType.dineIn,
      ),
      sessionId: data['sessionId'] as String?,
      tableId: data['tableId'] as String?,
      tableName: data['tableName'] as String?,
      items: items,
      subtotal: (data['subtotal'] as num? ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] as num? ?? 0).toDouble(),
      discount: (data['discount'] as num? ?? 0).toDouble(),
      grandTotal: (data['grandTotal'] as num? ?? 0).toDouble(),
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: data['createdBy'] as String?,
      idempotencyKey: data['idempotencyKey'] as String? ?? doc.id,
      customerName: customerName,
      customerPhone: customerPhone,
    );
  }

  Map<String, dynamic> _orderItemToMap(OrderItem item) {
    return {
      'productId': item.productId,
      'productName': item.productName,
      'unitPrice': item.unitPrice,
      'quantity': item.quantity,
      'note': item.note,
      'lineTotal': item.lineTotal,
    };
  }
}
