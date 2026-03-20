class Supplier {
  final int id;
  final String name;
  final String address;
  final String phoneNumber;

  Supplier({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNumber,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      id: json["id"],
      name: json["name"],
      address: json["address"],
      phoneNumber: json["phone_number"],
    );
  }
}
