import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers/firebase_providers.dart';
import '../models/sushi_product.dart';

part 'dining_menu_view_model.g.dart';

@riverpod
class DiningMenuViewModel extends _$DiningMenuViewModel {
  // TODO: Inject ProductRepository and expose product list state for DiningMenuScreen.
  @override
  Stream<List<SushiProduct>> build() {
    return ref.watch(productRepositoryProvider).watchAvailableProducts();
  }

  void addProductToCart(
    SushiProduct product,
  ) {
    //expect to create an instance of sqlite db then add an item to pending_cart/cart
  }
}
