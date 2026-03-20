import 'package:frontend_roti/models/store.dart';

class RouteLine {
  final int id;
  final String name;
  final bool isDelete;
  final List<Store> stores;

  RouteLine({
    required this.id,
    required this.name,
    required this.isDelete,
    required this.stores,
  });

  factory RouteLine.fromJson(Map<String, dynamic> json) {
    return RouteLine(
      id: json['id'],
      name: json['name'],
      isDelete: json['is_delete'],
      stores: json['stores'] != null
          ? (json['stores'] as List).map((e) => Store.fromJson(e)).toList()
          : [],
    );
  }
}
