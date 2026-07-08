import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../layout/layout_gate.dart';
import '../../views/about_screen.dart';
import '../../views/dining_cart_screen.dart';
import '../../views/dining_menu_screen.dart';
import '../../views/info_screen.dart';
import '../../views/kitchen_orders_screen.dart';
import '../../views/login_screen.dart';
import '../../views/pickup_checkout_screen.dart';
import '../../views/profile_screen.dart';
import '../../views/reservation_screen.dart';
import '../../views/session_orders_screen.dart';
import '../../views/table_selection_screen.dart';
import '../../views/web_cart_screen.dart';
import '../../views/web_home_screen.dart';
import '../../views/web_menu_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const LayoutGate.public(
          child: WebHomeScreen(),
        ),
      ),
      GoRoute(
        path: '/about',
        builder: (context, state) => const LayoutGate.public(
          child: AboutScreen(),
        ),
      ),
      GoRoute(
        path: '/info',
        builder: (context, state) => const LayoutGate.public(
          child: InfoScreen(),
        ),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const LayoutGate.public(
          child: ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/staff/tables',
        builder: (context, state) => const LayoutGate.staff(
          child: TableSelectionScreen(),
        ),
      ),
      GoRoute(
        path: '/dining/menu',
        builder: (context, state) => const LayoutGate.staff(
          child: DiningMenuScreen(),
        ),
      ),
      GoRoute(
        path: '/dining/cart',
        builder: (context, state) => const LayoutGate.staff(
          child: DiningCartScreen(),
        ),
      ),
      GoRoute(
        path: '/dining/orders',
        builder: (context, state) => const LayoutGate.staff(
          child: SessionOrdersScreen(),
        ),
      ),
      GoRoute(
        path: '/kitchen/orders',
        builder: (context, state) => const LayoutGate.staff(
          child: KitchenOrdersScreen(),
        ),
      ),
      GoRoute(
        path: '/web/menu',
        builder: (context, state) => const LayoutGate.public(
          child: WebMenuScreen(),
        ),
      ),
      GoRoute(
        path: '/web/cart',
        builder: (context, state) => const LayoutGate.public(
          child: WebCartScreen(),
        ),
      ),
      GoRoute(
        path: '/web/checkout',
        builder: (context, state) => const LayoutGate.public(
          child: PickupCheckoutScreen(),
        ),
      ),
      GoRoute(
        path: '/web/reservation',
        builder: (context, state) => const LayoutGate.public(
          child: ReservationScreen(),
        ),
      ),
    ],
  );
});
