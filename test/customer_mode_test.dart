import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sushi_restaurant/core/enums/app_enums.dart';
import 'package:sushi_restaurant/core/providers/firebase_providers.dart';
import 'package:sushi_restaurant/core/providers/local_providers.dart';
import 'package:sushi_restaurant/models/app_user.dart';
import 'package:sushi_restaurant/models/cart_item.dart';
import 'package:sushi_restaurant/models/dining_session.dart';
import 'package:sushi_restaurant/models/local_cart_item.dart';
import 'package:sushi_restaurant/models/restaurant_order.dart';
import 'package:sushi_restaurant/models/order_item.dart';
import 'package:sushi_restaurant/models/sushi_product.dart';
import 'package:sushi_restaurant/repositories/auth_repository.dart';
import 'package:sushi_restaurant/repositories/dining_session_repository.dart';
import 'package:sushi_restaurant/repositories/local_cart_repository.dart';
import 'package:sushi_restaurant/repositories/order_repository.dart';
import 'package:sushi_restaurant/repositories/product_repository.dart';
import 'package:sushi_restaurant/views/dining_cart_screen.dart';
import 'package:sushi_restaurant/views/dining_menu_screen.dart';
import 'package:sushi_restaurant/views/session_orders_screen.dart';
import 'package:sushi_restaurant/views/session_receipt_screen.dart';
import 'package:sushi_restaurant/services/device_session_assignment_service.dart';
import 'package:sushi_restaurant/services/sqlite_cart_service.dart';

void main() {
  testWidgets(
    'customer mode navigates only between menu cart and order history',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final sessionRepo = _SessionRepo();

      final router = GoRouter(
        initialLocation: '/dining/menu',
        routes: [
          GoRoute(
            path: '/dining/menu',
            builder: (context, state) => const DiningMenuScreen(),
          ),
          GoRoute(
            path: '/dining/cart',
            builder: (context, state) => const DiningCartScreen(),
          ),
          GoRoute(
            path: '/dining/orders',
            builder: (context, state) => const SessionOrdersScreen(),
          ),
          GoRoute(
            path: '/dining/receipt',
            builder: (context, state) =>
                SessionReceiptScreen(unlockedSessionId: state.extra as String?),
          ),
          GoRoute(
            path: '/staff/tables',
            builder: (context, state) =>
                const Scaffold(body: Center(child: Text('STAFF TABLES'))),
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_StaffAuth()),
            productRepositoryProvider.overrideWithValue(_MenuRepo()),
            orderRepositoryProvider.overrideWithValue(_OrderRepo()),
            diningSessionRepositoryProvider.overrideWithValue(sessionRepo),
            localCartRepositoryProvider.overrideWithValue(_CartRepo()),
            deviceSessionAssignmentServiceProvider.overrideWithValue(
              _DeviceSessionService(),
            ),
            currentDiningSessionProvider.overrideWithValue(_session),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SISHU DINING'), findsOneWidget);
      expect(find.text('Bàn 1'), findsOneWidget);
      expect(find.text('Giỏ'), findsOneWidget);
      expect(find.text('Đã gọi'), findsOneWidget);
      expect(find.text('DANH MỤC'), findsNothing);

      await tester.tap(find.text('Danh mục'));
      await tester.pumpAndSettle();
      expect(find.text('DANH MỤC'), findsOneWidget);

      await tester.tap(find.text('Nhân viên'));
      await tester.pumpAndSettle();
      expect(find.text('Mở khóa nhân viên'), findsOneWidget);
      expect(find.text('PIN demo: 1234'), findsOneWidget);
      await tester.tap(find.text('Hủy'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Giỏ'));
      await tester.pumpAndSettle();
      expect(find.text('GIỎ HÀNG TẠM'), findsOneWidget);
      expect(find.text('Menu'), findsOneWidget);

      await tester.tap(find.text('Đã gọi'));
      await tester.pumpAndSettle();
      expect(find.text('ĐƠN ĐÃ GỬI BẾP - BÀN 1'), findsOneWidget);
      expect(find.textContaining('Bàn chưa đặt món ăn nào'), findsOneWidget);
      expect(find.text('GỌI NHÂN VIÊN'), findsNothing);
      expect(find.text('YÊU CẦU THANH TOÁN'), findsNothing);

      await tester.tap(find.text('Nhân viên'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '1234');
      await tester.tap(find.text('Mở khóa'));
      await tester.pumpAndSettle();

      expect(find.text('HÓA ĐƠN - BÀN 1'), findsOneWidget);
      expect(find.text('TIỀN MẶT'), findsOneWidget);
      expect(find.text('MÃ QR'), findsOneWidget);
      expect(find.text('CHƯA THỂ ĐÓNG PHIÊN'), findsOneWidget);

      await tester.tap(find.text('CHƯA THỂ ĐÓNG PHIÊN'));
      await tester.pump();
      expect(sessionRepo.closeCalled, isFalse);

      await tester.tap(find.text('TIỀN MẶT'));
      await tester.tap(find.byKey(const Key('demo-payment-toggle')));
      await tester.pumpAndSettle();
      expect(find.text('ĐÃ THANH TOÁN'), findsOneWidget);
      expect(find.text('ĐÓNG PHIÊN'), findsOneWidget);

      await tester.tap(find.text('ĐÓNG PHIÊN'));
      await tester.pumpAndSettle();
      expect(sessionRepo.closeCalled, isTrue);
      expect(find.text('STAFF TABLES'), findsOneWidget);
    },
  );

  testWidgets('compact tablet menu uses icon actions without overflow', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(768, 518);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(_StaffAuth()),
          productRepositoryProvider.overrideWithValue(_MenuRepo()),
          orderRepositoryProvider.overrideWithValue(_OrderRepo()),
          diningSessionRepositoryProvider.overrideWithValue(_SessionRepo()),
          currentDiningSessionProvider.overrideWithValue(_session),
        ],
        child: const MaterialApp(home: DiningMenuScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('SISHU'), findsOneWidget);
    expect(find.byTooltip('Hiện danh mục'), findsOneWidget);
    expect(find.byTooltip('Giỏ hàng (0 món)'), findsOneWidget);
    expect(find.byTooltip('Món đã gọi'), findsOneWidget);
    expect(find.byTooltip('Nhân viên'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Hiện danh mục'));
    await tester.pumpAndSettle();
    expect(find.text('DANH MỤC'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

final _session = DiningSession(
  id: 'session_1',
  sessionCode: 'BAN1-20260101-TEST',
  tableId: 'table_1',
  tableName: 'Bàn 1',
  status: DiningSessionStatus.active,
  openedBy: 'staff_1',
  startedAt: _startedAt,
  createdAt: _startedAt,
  updatedAt: _startedAt,
  paymentStatus: PaymentStatus.unpaid,
  subtotal: 0,
  discount: 0,
  serviceCharge: 0,
  tax: 0,
  grandTotal: 0,
  orderCount: 0,
  itemCount: 0,
  guestCount: 2,
);

final _startedAt = DateTime(2026, 1, 1);

class _StaffAuth implements AuthRepository {
  @override
  Stream<AppUser?> watchCurrentUser() => Stream.value(
    const AppUser(
      id: 'staff_1',
      email: 'staff@example.com',
      role: UserRole.staff,
    ),
  );

  @override
  Future<AppUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> updateProfile({
    required String uid,
    String? fullName,
    String? phoneNumber,
    String? address,
    String? cccd,
  }) async {}
}

class _MenuRepo implements ProductRepository {
  @override
  Stream<List<SushiProduct>> watchAvailableProducts() => Stream.value([
    const SushiProduct(
      id: 'salmon',
      name: 'Salmon Nigiri',
      price: 45000,
      categoryId: 'sushi',
      isAvailable: true,
      preparationArea: PreparationArea.sushiBar,
    ),
  ]);

  @override
  Future<SushiProduct?> getProductById(String productId) async => null;

  @override
  Stream<List<SushiProduct>> watchAllProducts() => watchAvailableProducts();

  @override
  Future<void> addProduct({
    required String name,
    required double price,
    required String categoryId,
    required bool isAvailable,
    required PreparationArea preparationArea,
    String? description,
    String? imageUrl,
  }) async {}

  @override
  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required String categoryId,
    required bool isAvailable,
    required PreparationArea preparationArea,
    String? description,
    String? imageUrl,
  }) async {}

  @override
  Future<void> deleteProduct(String productId) async {}
}

class _OrderRepo implements OrderRepository {
  @override
  Stream<List<RestaurantOrder>> watchKitchenOrders() => Stream.value(const []);

  @override
  Stream<List<RestaurantOrder>> watchSessionOrders(String sessionId) =>
      Stream.value(const []);

  @override
  Future<RestaurantOrder> placeDineInOrder({
    required String sessionId,
    required String tableId,
    required String tableName,
    required List<CartItem> cartItems,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<RestaurantOrder> placeWebPickupOrder({
    required String customerName,
    required String customerPhone,
    required String pickupTime,
    required String? note,
    required List<OrderItem> items,
    String? createdBy,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {}

  @override
  Stream<List<RestaurantOrder>> watchAllOrders() => Stream.value(const []);
}

class _SessionRepo implements DiningSessionRepository {
  final _changes = StreamController<DiningSession>.broadcast();
  DiningSession _current = _session;
  bool closeCalled = false;

  @override
  Future<DiningSession> startSession({
    required String tableId,
    required String openedBy,
    required String openedByName,
    required String deviceId,
    required int guestCount,
  }) async => _session;

  @override
  Future<void> closeSession(String sessionId) async {
    if (_current.paymentStatus != PaymentStatus.paid) {
      throw StateError('Chưa thanh toán.');
    }
    closeCalled = true;
  }

  @override
  Future<void> cancelSession({
    required String sessionId,
    required String cancelledBy,
  }) async {}

  @override
  Future<void> setPaymentStatus({
    required String sessionId,
    required PaymentStatus status,
    DiningPaymentMethod? method,
    String? paidBy,
  }) async {
    _current = DiningSession(
      id: _current.id,
      sessionCode: _current.sessionCode,
      tableId: _current.tableId,
      tableName: _current.tableName,
      status: _current.status,
      openedBy: _current.openedBy,
      openedByName: _current.openedByName,
      deviceId: _current.deviceId,
      startedAt: _current.startedAt,
      createdAt: _current.createdAt,
      updatedAt: _current.updatedAt,
      paymentStatus: status,
      paymentMethod: status == PaymentStatus.paid ? method : null,
      paidBy: status == PaymentStatus.paid ? paidBy : null,
      paidAt: status == PaymentStatus.paid ? DateTime.now() : null,
      subtotal: _current.subtotal,
      discount: _current.discount,
      serviceCharge: _current.serviceCharge,
      tax: _current.tax,
      grandTotal: _current.grandTotal,
      orderCount: _current.orderCount,
      itemCount: _current.itemCount,
      guestCount: _current.guestCount,
    );
    _changes.add(_current);
  }

  @override
  Stream<DiningSession?> watchActiveSession(String tableId) async* {
    yield _current;
    yield* _changes.stream;
  }
}

class _CartRepo extends LocalCartRepository {
  _CartRepo() : super(SqliteCartService());

  @override
  Future<List<LocalCartItem>> getItems(String sessionId) async => const [];

  @override
  Future<void> clearCart(String sessionId) async {}
}

class _DeviceSessionService extends DeviceSessionAssignmentService {
  @override
  Future<void> clearActiveSession() async {}
}
