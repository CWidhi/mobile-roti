import 'package:frontend_roti/models/supplier.dart';
import 'package:frontend_roti/models/purchaseItem.dart';

class Purchase {
  final int id;
  final DateTime purchaseDate;
  final int total;
  final String? description;
  final int? cashback;
  final Supplier supplier;
  final List<PurchaseItem> items;

  Purchase({
    required this.id,
    required this.purchaseDate,
    required this.total,
    required this.supplier,
    required this.description,
    required this.cashback,
    required this.items,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'],
      purchaseDate: DateTime.parse(json['purchase_date']),
      total: json['total'],
      description: json['description'],
      cashback: json['cashback'],
      supplier: Supplier.fromJson(json['supplier']),
      items: (json['items'] as List)
          .map((e) => PurchaseItem.fromJson(e))
          .toList(),
    );
  }
}