class OrderPickingItem {
  final int id;

  /// RELATION
  final Product product;

  final String unit;
  final int qty;
  final int price;
  final int total;
  final bool marketStore;

  OrderPickingItem({
    required this.id,
    required this.product,
    required this.unit,
    required this.qty,
    required this.price,
    required this.total,
    required this.marketStore,
  });

  factory OrderPickingItem.fromJson(Map<String, dynamic> json) {
    return OrderPickingItem(
      id: json['id'],
      product: Product.fromJson(json['product']),
      unit: json['unit'],
      qty: json['qty'],
      price: json['price'],
      total: json['total'],
      marketStore: json['market_store'],
    );
  }

  int get subtotal => total;
}

class Product {
  final int id;
  final String name;

  Product({
    required this.id,
    required this.name,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }
}
