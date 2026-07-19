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

  factory SushiProduct.fromJson(Map<String, dynamic> json) {
    return SushiProduct(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] as num? ?? 0).toDouble(),
      categoryId: json['categoryId'] as String? ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      preparationArea: PreparationArea.values.firstWhere(
        (e) => e.name == json['preparationArea'],
        orElse: () => PreparationArea.sushiBar,
      ),
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'categoryId': categoryId,
      'isAvailable': isAvailable,
      'preparationArea': preparationArea.name,
      'description': description,
      'imageUrl': imageUrl,
    };
  }
}
