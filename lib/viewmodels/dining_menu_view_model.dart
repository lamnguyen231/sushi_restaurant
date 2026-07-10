import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../core/providers/firebase_providers.dart';
import '../core/providers/local_providers.dart';
import '../models/sushi_product.dart';
import 'dining_cart_view_model.dart';

part 'dining_menu_view_model.g.dart';

@riverpod
class DiningMenuSearchQuery extends _$DiningMenuSearchQuery {
  @override
  String build() => '';
  void updateQuery(String q) => state = q;
}

@riverpod
class DiningMenuCategory extends _$DiningMenuCategory {
  @override
  String? build() => null;
  void updateCategory(String? cat) => state = cat;
}
@riverpod
class DiningMenuViewModel extends _$DiningMenuViewModel {
  @override
  Stream<List<SushiProduct>> build() {
    return ref.watch(productRepositoryProvider).watchAvailableProducts();
  }

  Future<void> addProductToCart(SushiProduct product) async {
    final session = ref.read(currentDiningSessionProvider);
    if (session == null) return;
    
    await ref.read(diningCartViewModelProvider(session.id).notifier).addItem(product);
  }
}
