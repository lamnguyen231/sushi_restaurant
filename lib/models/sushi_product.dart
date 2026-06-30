import '../core/enums/app_enums.dart';

class SushiProduct {
  const SushiProduct({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.isAvailable,
    required this.preparationArea,
    this.description,
    this.imageUrl,
  });

  final String id;
  final String name;
  final String? description;
  final double price;
  final String categoryId;
  final String? imageUrl;
  final bool isAvailable;
  final PreparationArea preparationArea;
}
