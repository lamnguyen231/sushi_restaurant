import '../models/sushi_product.dart';

abstract interface class ProductRepository {
  Stream<List<SushiProduct>> watchAvailableProducts();

  Future<SushiProduct?> getProductById(String productId);
}
