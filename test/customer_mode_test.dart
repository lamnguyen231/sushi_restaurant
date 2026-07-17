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
import 'package:sushi_restaurant/models/restaurant_order.dart';
import 'package:sushi_restaurant/models/sushi_product.dart';
import 'package:sushi_restaurant/repositories/auth_repository.dart';
import 'package:sushi_restaurant/repositories/dining_session_repository.dart';
import 'package:sushi_restaurant/repositories/order_repository.dart';
import 'package:sushi_restaurant/repositories/product_repository.dart';
import 'package:sushi_restaurant/views/dining_cart_screen.dart';
import 'package:sushi_restaurant/views/dining_menu_screen.dart';
import 'package:sushi_restaurant/views/session_orders_screen.dart';

void main() {
  testWidgets(
    'customer mode navigates only between menu cart and order history',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1280, 800);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

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
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authRepositoryProvider.overrideWithValue(_StaffAuth()),
            productRepositoryProvider.overrideWithValue(_MenuRepo()),
            orderRepositoryProvider.overrideWithValue(_OrderRepo()),
            diningSessionRepositoryProvider.overrideWithValue(_SessionRepo()),
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
      expect(find.text('Đơn đã gọi - Bàn 1'), findsOneWidget);
      expect(find.text('Chưa có món nào được gửi bếp.'), findsOneWidget);

      await tester.tap(find.text('Menu'));
      await tester.pumpAndSettle();
      expect(find.text('SISHU DINING'), findsOneWidget);
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
  tableId: 'table_1',
  tableName: 'Bàn 1',
  status: DiningSessionStatus.active,
  openedBy: 'staff_1',
  startedAt: _startedAt,
  paymentStatus: PaymentStatus.unpaid,
  subtotal: 0,
  discount: 0,
  serviceCharge: 0,
  tax: 0,
  grandTotal: 0,
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
  Future<void> updateOrderStatus({
    required String orderId,
    required String status,
  }) async {}
}

class _SessionRepo implements DiningSessionRepository {
  @override
  Future<DiningSession> startSession({
    required String tableId,
    required String openedBy,
    required int guestCount,
  }) async => _session;

  @override
  Future<void> closeSession(String sessionId) async {}

  @override
  Stream<DiningSession?> watchActiveSession(String tableId) =>
      Stream.value(_session);
}
