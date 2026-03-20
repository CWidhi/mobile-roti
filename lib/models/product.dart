import 'productPrice.dart';
import 'productStock.dart';

class Product {
  final int id;
  final String name;
  final String image;
  final ProductStock productStock;
  final String productType;
  final List<ProductPrice> prices;

  Product({
    required this.id,
    required this.name,
    required this.image,
    required this.productStock,
    required this.productType,
    required this.prices,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      productStock: ProductStock.fromJson(json['product_stock']),
      productType: json['productType'],
      prices: (json['prices'] as List)
          .map((e) => ProductPrice.fromJson(e))
          .toList(),
    );
  }

  /// Ambil harga utama (misal pabrik)
  int get mainPrice => prices.first.price;
}
