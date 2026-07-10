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

  @override
  Future<RestaurantOrder> placeDineInOrder({
    required String sessionId,
    required String tableId,
    required String tableName,
    required List<CartItem> cartItems,
  }) async {
    final orderItems = cartItems
        .map(
          (item) => OrderItem(
            productId: item.productId,
            productName: item.name,
            unitPrice: item.unitPrice,
            quantity: item.quantity,
            note: item.note,
            lineTotal: item.lineTotal,
          ),
        )
        .toList();
    final subtotal = orderItems.fold<double>(
      0,
      (total, item) => total + item.lineTotal,
    );
    final idempotencyKey = '${sessionId}_${DateTime.now().microsecondsSinceEpoch}';
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
      'grandTotal': subtotal,
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
    // TODO: Add update method to FirestoreOrderService when kitchen flow starts.
  }

  RestaurantOrder _fromDoc(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
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

    return RestaurantOrder(
      id: doc.id,
      source: OrderSource.tableDevice,
      orderType: OrderType.dineIn,
      sessionId: data['sessionId'] as String?,
      tableId: data['tableId'] as String?,
      tableName: data['tableName'] as String?,
      items: items,
      subtotal: (data['subtotal'] as num? ?? 0).toDouble(),
      deliveryFee: (data['deliveryFee'] as num? ?? 0).toDouble(),
      discount: (data['discount'] as num? ?? 0).toDouble(),
      grandTotal: (data['grandTotal'] as num? ?? 0).toDouble(),
      status: DineInOrderStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
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
