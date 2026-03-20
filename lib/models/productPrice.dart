class ProductPrice {
  final int id;
  final String unit;
  final int qty;
  final int price;
  final String typePrice;

  ProductPrice({
    required this.id,
    required this.unit,
    required this.qty,
    required this.price,
    required this.typePrice,
  });

  factory ProductPrice.fromJson(Map<String, dynamic> json) {
    return ProductPrice(
      id: json['id'],
      unit: json['unit'],
      qty: json['qty'],
      price: json['price'],
      typePrice: json['typePrice'],
    );
  }
}


