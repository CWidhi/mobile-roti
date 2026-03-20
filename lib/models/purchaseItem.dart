
class PurchaseItem {
  final Product product;
  final String unit;
  final int qty;
  final int buyPrice;
  final int totalPrice;

  PurchaseItem({
    required this.product,
    required this.unit,
    required this.qty,
    required this.buyPrice,
    required this.totalPrice,
  });

  factory PurchaseItem.fromJson(Map<String, dynamic> json) {
    return PurchaseItem(
      product: Product.fromJson(json['product']),
      unit: json['unit'],
      qty: json['qty'],
      buyPrice: json['buy_price'],
      totalPrice: json['total_price'],
    );
  }
}

class Product {
  final int id;
  final String name;

  Product({required this.id, required this.name});

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
    );
  }
}
