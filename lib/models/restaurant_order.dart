import '../core/enums/app_enums.dart';
import 'order_item.dart';

class RestaurantOrder {
  const RestaurantOrder({
    required this.id,
    required this.source,
    required this.orderType,
    required this.items,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.idempotencyKey,
    this.sessionId,
    this.tableId,
    this.tableName,
    this.createdBy,
    this.deliveryFee = 0,
    this.customerName,
    this.customerPhone,
  });

  final String id;
  final OrderSource source;
  final OrderType orderType;
  final String? sessionId;
  final String? tableId;
  final String? tableName;
  final List<OrderItem> items;
  final double subtotal;
  final double deliveryFee;
  final double discount;
  final double grandTotal;
  final DineInOrderStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdBy;
  final String idempotencyKey;
  final String? customerName;
  final String? customerPhone;
}
