import '../core/enums/app_enums.dart';
import '../models/sushi_product.dart';

abstract interface class ProductRepository {
  // ── User-facing ───────────────────────────────────────────────────────────
  Stream<List<SushiProduct>> watchAvailableProducts();

  Future<SushiProduct?> getProductById(String productId);

  // ── Admin CRUD ────────────────────────────────────────────────────────────
  Stream<List<SushiProduct>> watchAllProducts();

  Future<void> addProduct({
    required String name,
    required double price,
    required String categoryId,
    required bool isAvailable,
    required PreparationArea preparationArea,
    String? description,
    String? imageUrl,
  });

  Future<void> updateProduct({
    required String id,
    required String name,
    required double price,
    required String categoryId,
    required bool isAvailable,
    required PreparationArea preparationArea,
    String? description,
    String? imageUrl,
  });

  Future<void> deleteProduct(String productId);
}
