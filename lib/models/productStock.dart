class ProductStock {
  final int id;
  final int product;
  final int stock;

  ProductStock({
    required this.id,
    required this.product,
    required this.stock,
  });

  factory ProductStock.fromJson(Map<String, dynamic> json) {
    return ProductStock(
      id: json['id'],
      product: json['product'],
      stock: json['stock'],
    );
  }
}
