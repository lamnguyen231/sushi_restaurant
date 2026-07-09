import '../core/enums/app_enums.dart';
import '../models/sushi_product.dart';
import '../services/firestore_product_service.dart';
import 'product_repository.dart';

class FirestoreProductRepository implements ProductRepository {
  const FirestoreProductRepository(this._productService);

  final FirestoreProductService _productService;

  // ── Read ──────────────────────────────────────────────────────────────────

  @override
  Stream<List<SushiProduct>> watchAvailableProducts() {
    return _productService.watchProducts().map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList(),
    );
  }

  @override
  Stream<List<SushiProduct>> watchAllProducts() {
    return _productService.watchAllProducts().map(
      (snapshot) => snapshot.docs.map(_fromDoc).toList(),
    );
  }

  @override
  Future<SushiProduct?> getProductById(String productId) async {
    final snapshot = await _productService.getProduct(productId);
    if (!snapshot.exists) return null;
    return _fromDoc(snapshot);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  @override
  Future<void> addProduct({
    required String name,
    required double price,
    required String categoryId,
    required bool isAvailable,
    required PreparationArea preparationArea,
    String? description,
    String? imageUrl,
  }) {
    return _productService.addProduct({
      'name': name,
      'price': price,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'preparationArea': preparationArea.wireName,
      if (description != null) 'description': description,
      if (imageUrl != null) 'imageUrl': imageUrl,
    });
  }

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
  }) {
    return _productService.updateProduct(id, {
      'name': name,
      'price': price,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'preparationArea': preparationArea.wireName,
      'description': description,
      'imageUrl': imageUrl,
    });
  }

  @override
  Future<void> deleteProduct(String productId) {
    return _productService.deleteProduct(productId);
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

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
