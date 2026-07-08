import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sushi_restaurant/widgets/sushi_product_dining_list_item.dart';

import '../viewmodels/dining_menu_view_model.dart';
import '../widgets/empty_state_view.dart';
import '../widgets/error_view.dart';
import 'package:sushi_restaurant/widgets/loading_view.dart';

class DiningMenuScreen extends ConsumerWidget {
  const DiningMenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuState = ref.watch(diningMenuViewModelProvider);

    // return ScaffoldPlaceholder(
    //   title: 'Menu tại bàn',
    //   description: 'View trong MVVM: khách xem món, mở chi tiết món và thêm vào SQLite cart.',
    //   actions: [
    //     PrimaryButton(
    //       label: 'Xem giỏ hàng',
    //       onPressed: () => context.push('/dining/cart'),
    //     ),
    //     OutlinedButton(
    //       onPressed: () => context.push('/dining/orders'),
    //       child: const Text('Lịch sử gọi món'),
    //     ),
    //   ],
    // );

    // Container(
    //   alignment: Alignment.center,
    //   child: Stack(
    //     children: [
    //       Text('View menu'),
    //
    //       Text('Example list of items in menu would be here'),
    //       ListView.builder(),
    //       //(
    //       //thêm item vào giỏ hàng, this should be on each item
    //       PrimaryButton(label: 'Thêm vào giỏ hàng', onPressed: () => null),
    //       //)
    //
    //       //order right away without thinking
    //       PrimaryButton(label: 'Đặt đồ', onPressed: () => context.push('/kitchen/orders')),
    //
    //       //for checking if we want to order anything.
    //       PrimaryButton(
    //           label: 'Xem giỏ hàng',
    //           onPressed: () => context.push('/dining/cart')
    //       ),
    //       //idea: have a popup/scrollup widget that display the list & amount of items that has been added to cart.
    //       // then instead of a cart screen just has a history screen only??
    //       // or have cart and history on same screen but can be switch between
    //     ],
    //   ),
    // ),

    return Scaffold(
      body: menuState.when(
        loading: () => const LoadingView(message: 'Đang tải danh sách menu'),
          error: (error, stackTrace) =>
              ErrorView(message: 'Không tải được danh sách sản phẩm: $error'),
        data: (menu) {
          if (menu.isEmpty) {
            return const EmptyStateView(
              message: 'Chưa có sản phẩm nào. Hãy seed Firestore trước.',
            );
          }

          return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                    child: Column(
                      children: [
                        Text(
                          'MENU',
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Danh sách các món ăn',
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),

                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
                  sliver: SliverList.builder(
                    itemCount: menu.length,
                    itemBuilder: (context, index) {
                      final product = menu[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: SushiProductDiningListItem(
                          product: product,
                          onAddToCart: () => ref
                              .read(diningMenuViewModelProvider.notifier)
                              .addProductToCart(product),
                        ),
                      );
                    },
                  ),
                ),
              ]
          );
        }
      )
    );
  }
}
