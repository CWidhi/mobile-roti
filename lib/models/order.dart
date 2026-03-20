import 'package:frontend_roti/models/orderItem.dart';
import 'package:frontend_roti/models/userModel.dart';
import 'package:frontend_roti/models/rute.dart';

class OrderPicking {
  final int id;

  /// RELATION
  final UserModel? user;
  final RouteLine? rute;

  /// FALLBACK ID (aman kalau BE belum expand)
  final int userId;
  final int ruteId;

  final DateTime orderDate;
  final int total;
  final bool confirmations;
  final List<OrderPickingItem> items;

  OrderPicking({
    required this.id,
    required this.userId,
    required this.ruteId,
    required this.orderDate,
    required this.total,
    required this.confirmations,
    required this.items,
    this.user,
    this.rute,
  });

  factory OrderPicking.fromJson(Map<String, dynamic> json) {
    return OrderPicking(
      id: json['id'],

      /// USER
      userId: json['user'] is int ? json['user'] : json['user']['id'],
      user: json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,

      /// RUTE
      ruteId: json['rute'] is int ? json['rute'] : json['rute']['id'],
      rute: json['rute'] is Map<String, dynamic>
          ? RouteLine.fromJson(json['rute'])
          : null,

      orderDate: DateTime.parse(json['order_date']),
      total: json['total'],
      confirmations: json['confirmations'],
      items: (json['item'] as List)
          .map((e) => OrderPickingItem.fromJson(e))
          .toList(),
    );
  }
}
