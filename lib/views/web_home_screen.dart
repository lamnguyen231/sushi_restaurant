import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/providers/firebase_providers.dart';
import '../core/theme/app_theme.dart';
import '../models/sushi_product.dart';
import '../viewmodels/web_cart_view_model.dart';
import '../viewmodels/web_menu_view_model.dart';
import '../widgets/sushi_nav_bar.dart';
import '../widgets/sushi_product_card.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const SushiNavBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: const [
            _HomeHeroImage(),
            _FeaturedDishesSection(),
          ],
        ),
      ),
    );
  }
}

class _HomeHeroImage extends StatelessWidget {
  const _HomeHeroImage();

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final heroHeight = screenHeight - const SushiNavBar().preferredSize.height;

    return SizedBox(
      height: heroHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_screen.jpg',
            fit: BoxFit.cover,
            alignment: Alignment.center,
          ),

          Container(
            color: Colors.black.withValues(alpha: 0.25),
          ),

          Positioned.fill(
            child: Align(
              alignment: const Alignment(0, 0.4),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'ス\nィ\nシ\nュ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 72,
                          fontWeight: FontWeight.w700,
                          height: 1.5,
                          letterSpacing: 6,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Sishu',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          letterSpacing: 4,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class _FeaturedDishesSection extends ConsumerWidget {
  const _FeaturedDishesSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncState = ref.watch(webMenuViewModelProvider);

    return ColoredBox(
      color: AppTheme.eggshell,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section Title
            Center(
              child: Column(
                children: [
                  Text(
                    'MÓN ĂN TIÊU BIỂU',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.ink,
                          letterSpacing: 4,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: 60,
                    height: 2,
                    color: AppTheme.vermilion,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Khám phá hương vị sushi truyền thống và hiện đại của chúng tôi',
                    style: TextStyle(
                      color: AppTheme.mutedInk,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Products list
            asyncState.when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Text(
                    'Không thể tải món ăn tiêu biểu: $e',
                    style: const TextStyle(color: AppTheme.mutedInk),
                  ),
                ),
              ),
              data: (state) {
                final products = state.allProducts.where((p) => p.isAvailable).take(4).toList();
                if (products.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: Text(
                        'Thực đơn đang được cập nhật.',
                        style: TextStyle(color: AppTheme.mutedInk),
                      ),
                    ),
                  );
                }

                final width = MediaQuery.sizeOf(context).width;
                final crossAxisCount = switch (width) {
                  >= 1200 => 4,
                  >= 900 => 3,
                  >= 600 => 2,
                  _ => 1,
                };

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, i) {
                    final product = products[i];
                    return SushiProductCard(
                      product: product,
                      onAddToCart: () => _addToCart(context, ref, product),
                    );
                  },
                );
              },
            ),

            // View all button
            const SizedBox(height: 32),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => context.go('/web/menu'),
                icon: const Icon(Icons.restaurant_menu, size: 16),
                label: const Text('XEM TẤT CẢ THỰC ĐƠN'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  side: const BorderSide(color: AppTheme.ink),
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                  textStyle: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.8,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addToCart(BuildContext context, WidgetRef ref, SushiProduct product) {
    final user = ref.read(currentUserProvider).value;

    if (user == null) {
      context.go('/login');
      return;
    }

    ref.read(webCartViewModelProvider.notifier).addItem(product);

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Đã thêm "${product.name}" vào giỏ hàng!\nVui lòng vào giỏ hàng để thêm số lượng và thanh toán.',
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 4),
        backgroundColor: const Color(0xFF1B4332),
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        action: SnackBarAction(
          label: 'GIỎ HÀNG',
          textColor: Colors.white70,
          onPressed: () => context.go('/web/cart'),
        ),
      ),
    );
  }
}
