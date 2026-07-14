import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/enums/app_enums.dart';
import '../models/cart_item.dart';
import '../models/order_item.dart';
import '../models/restaurant_order.dart';
import '../services/firestore_order_service.dart';
import 'order_repository.dart';

class FirestoreOrderRepository implements OrderRepository {
  const FirestoreOrderRepository(this._orderService);

  final FirestoreOrderService _orderService;

  @override
  Stream<List<RestaurantOrder>> watchKitchenOrders() {
    return _orderService.watchKitchenOrders().map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList(),
    );
  }

  @override
  Stream<List<RestaurantOrder>> watchSessionOrders(String sessionId) {
    return _orderService.watchSessionOrders(sessionId).map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList(),
    );
  }

  /// P3-01: Chuyển cart items từ SQLite thành Firestore order.
  /// P3-02: name và unitPrice được snapshot từ CartItem (đã lấy từ SQLite).
  /// P3-03: subtotal và grandTotal được tính lại trong repository,
  ///        không dùng giá trị do client truyền lên.
  /// P3-04: idempotencyKey dùng format sessionId_microseconds để đảm bảo unique.
  @override
  Future<RestaurantOrder> placeDineInOrder({
    required String sessionId,
    required String tableId,
    required String tableName,
    required List<CartItem> cartItems,
  }) async {
    // P3-02: Snapshot tên và giá tại thời điểm đặt từ CartItem (đã snapshot từ SQLite)
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

    // P3-03: Tính lại subtotal từ lineTotal từng item — không trust giá trị client
    final subtotal = orderItems.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );

    // P3-04: idempotencyKey: sessionId + microsecond timestamp → đủ unique trong session
    final idempotencyKey =
        '${sessionId}_${DateTime.now().microsecondsSinceEpoch}';
    final now = DateTime.now();

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
