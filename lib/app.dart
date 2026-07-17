import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';
import 'services/pending_order_sync_service.dart';

class SushiRestaurantApp extends ConsumerWidget {
  const SushiRestaurantApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Khoi chay he thong dong bo pending orders tu dong
    ref.read(pendingOrderSyncProvider);
    
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: 'Sishu - スィシュ',
      theme: AppTheme.light,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
