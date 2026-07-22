import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../views/about_screen.dart';
import '../../views/admin_menu_screen.dart';
import '../../views/dining_cart_screen.dart';
import '../../views/dining_menu_screen.dart';
import '../../views/info_screen.dart';
import '../../views/kitchen_orders_screen.dart';
import '../../views/login_screen.dart';
import '../../views/signup_screen.dart';
import '../../views/pickup_checkout_screen.dart';
import '../../views/profile_screen.dart';
import '../../views/reservation_screen.dart';
import '../../views/session_orders_screen.dart';
import '../../views/session_receipt_screen.dart';
import '../../views/table_selection_screen.dart';
import '../../views/web_cart_screen.dart';
import '../../views/web_home_screen.dart';
import '../../views/reservation_management_screen.dart';
import '../../views/web_menu_screen.dart';
import '../../views/manager_dashboard_screen.dart';
import '../../views/manager_orders_screen.dart';
import '../../views/revenue_analytics_screen.dart';
import '../../views/reports_export_screen.dart';
import '../../views/profit_analytics_screen.dart';


final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const WebHomeScreen()),
      GoRoute(path: '/about', builder: (context, state) => const AboutScreen()),
      GoRoute(path: '/info', builder: (context, state) => const InfoScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignUpScreen()),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/staff/tables',
        builder: (context, state) => const TableSelectionScreen(),
      ),
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
        path: '/kitchen/orders',
        builder: (context, state) => const KitchenOrdersScreen(),
      ),
      GoRoute(
        path: '/web/menu',
        builder: (context, state) => const WebMenuScreen(),
      ),
      GoRoute(
        path: '/web/cart',
        builder: (context, state) => const WebCartScreen(),
      ),
      GoRoute(
        path: '/web/checkout',
        builder: (context, state) => const PickupCheckoutScreen(),
      ),
      GoRoute(
        path: '/web/reservation',
        builder: (context, state) => const ReservationScreen(),
      ),
      GoRoute(
        path: '/staff/reservations',
        builder: (context, state) => const ReservationManagementScreen(),
      ),
      // ── Admin routes ────────────────────────────────────────────────────
      GoRoute(
        path: '/admin/menu',
        builder: (context, state) => const AdminMenuScreen(),
      ),
      // ── Manager routes ──────────────────────────────────────────────────
      GoRoute(
        path: '/manager/dashboard',
        builder: (context, state) => const ManagerDashboardScreen(),
      ),
      GoRoute(
        path: '/manager/orders',
        builder: (context, state) => const ManagerOrdersScreen(),
      ),
      GoRoute(
        path: '/manager/analytics/revenue',
        builder: (context, state) => const RevenueAnalyticsScreen(),
      ),
      GoRoute(
        path: '/manager/reports',
        builder: (context, state) => const ReportsExportScreen(),
      ),
      GoRoute(
        path: '/manager/analytics/profit',
        builder: (context, state) => const ProfitAnalyticsScreen(),
      ),
    ],
  );
});
