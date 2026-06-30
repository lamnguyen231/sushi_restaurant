import '../core/enums/app_enums.dart';
import '../models/sushi_product.dart';
import '../services/firestore_product_service.dart';
import 'product_repository.dart';

class FirestoreProductRepository implements ProductRepository {
  const FirestoreProductRepository(this._productService);

  final FirestoreProductService _productService;

  @override
  Stream<List<SushiProduct>> watchAvailableProducts() {
    return _productService.watchProducts().map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList(),
    );
  }

  @override
  Future<SushiProduct?> getProductById(String productId) async {
    final snapshot = await _productService.getProduct(productId);
    if (!snapshot.exists) return null;
    return _fromDoc(snapshot);
  }

  SushiProduct _fromDoc(dynamic doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SushiProduct(
      id: doc.id as String,
      name: data['name'] as String? ?? '',
      description: data['description'] as String?,
      price: (data['price'] as num? ?? 0).toDouble(),
      categoryId: data['categoryId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      isAvailable: data['isAvailable'] as bool? ?? true,
      preparationArea: _preparationArea(data['preparationArea'] as String?),
    );
  }

  PreparationArea _preparationArea(String? value) {
    return switch (value) {
      'hot_kitchen' => PreparationArea.hotKitchen,
      'drinks' => PreparationArea.drinks,
      _ => PreparationArea.sushiBar,
    };
  }
}
