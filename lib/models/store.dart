class Store {
  final int id;
  final String name;
  final String address;
  final String phone;
  final String coordinate;
  final String storeType;
  final bool isDelete;

  Store({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.coordinate,
    required this.storeType,
    required this.isDelete,
  });

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      name: json['name'],
      address: json['address'],
      phone: json['phone'],
      coordinate: json['coordinate'],
      storeType: json['storeType'],
      isDelete: json['is_delete'],
    );
  }
}
