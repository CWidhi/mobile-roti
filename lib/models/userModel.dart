import 'package:frontend_roti/constants/helper.dart';


class UserModel {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;
  final bool isStaff;
  final DateTime dateJoined;
  final UserRole role;

  UserModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
    required this.isStaff,
    required this.dateJoined,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final isStaff = json['is_staff'] as bool;

    return UserModel(
      id: json['id'],
      email: json['email'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      isActive: json['is_active'],
      isStaff: isStaff,
      dateJoined: DateTime.parse(json['date_joined']),
      role: isStaff ? UserRole.admin : UserRole.salles,
    );
  }
}
