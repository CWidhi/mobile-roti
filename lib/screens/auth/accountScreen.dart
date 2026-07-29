import 'package:flutter/material.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/screens/auth/chengePasswordScreen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  String _formatDate(String isoDate) {
    final date = DateTime.parse(isoDate);
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text("My Account", style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: UserService.getMe(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Failed to load data"));
          }

          final data = snapshot.data!;

          final name =
              "${data['first_name']} ${data['last_name']}".trim().isEmpty
                  ? "-"
                  : "${data['first_name']} ${data['last_name']}";

          final role = data['is_staff'] == true ? "Admin" : "Sales";

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AccountField(
                  label: "Name",
                  value: name,
                ),
                const SizedBox(height: 16),
                _AccountField(
                  label: "Email",
                  value: data['email'],
                ),
                const SizedBox(height: 16),
                _AccountField(
                  label: "Role",
                  value: role,
                ),
                const SizedBox(height: 16),
                _AccountField(
                  label: "Date Joined",
                  value: _formatDate(data['date_joined']),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                       Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => const ChangePasswordScreen(),
    ),
  );
                    },
                    child: const Text(
                      "Change Password",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}


class _AccountField extends StatelessWidget {
  const _AccountField({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
