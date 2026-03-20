import 'package:frontend_roti/models/userModel.dart';
import 'package:frontend_roti/models/supplier.dart';
import 'package:frontend_roti/models/orderItem.dart';

class StockMovement {
  final Product product;
  final String unit;
  final int qty;
  final String movementType;
  final String notes;

  /// RELATION
  final Supplier? supplier;
  final UserModel? user;

  /// FALLBACK ID
  final int? supplierId;
  final int? userId;

  StockMovement({
    required this.product,
    required this.unit,
    required this.qty,
    required this.movementType,
    required this.notes,
    this.supplier,
    this.user,
    this.supplierId,
    this.userId,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      product: Product.fromJson(json['product']),
      unit: json['unit'],
      qty: json['qty'],
      movementType: json['movement_type'],
      notes: json['notes'],

      /// SUPPLIER
      supplierId: json['supplier'] is int
          ? json['supplier']
          : json['supplier']?['id'],
      supplier: json['supplier'] is Map<String, dynamic>
          ? Supplier.fromJson(json['supplier'])
          : null,

      /// USER
      userId:
          json['user'] is int ? json['user'] : json['user']?['id'],
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,
    );
  }
}