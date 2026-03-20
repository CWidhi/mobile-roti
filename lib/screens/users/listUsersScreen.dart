import 'package:flutter/material.dart';
import 'package:frontend_roti/services/auth/userService.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<dynamic> users = [];
  bool isLoading = true;
  String searchQuery = "";

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    setState(() => isLoading = true);

    try {
      final result = await UserService.getUsers(search: searchQuery);
      setState(() {
        users = result;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void onSearchChanged(String value) {
    searchQuery = value;
    fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("Users Data"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// SEARCH BAR → TERHUBUNG KE API
            UsersSearchBar(
              onChanged: onSearchChanged,
            ),

            const SizedBox(height: 20),

            /// LIST USERS
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : users.isEmpty
                      ? const Center(
                          child: Text("User tidak ditemukan"),
                        )
                      : ListView.separated(
                          itemCount: users.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final user = users[index];

                            return _UserCard(
                              userId: user["id"],
                              name: "${user["first_name"]} ${user["last_name"]}"
                                      .trim()
                                      .isEmpty
                                  ? "-"
                                  : "${user["first_name"]} ${user["last_name"]}",
                              email: user["email"] ?? "-",
                              role: user["is_staff"] == true ? "Admin" : "User",
                              isActive: user["is_active"] == true,
                              onStatusChanged: fetchUsers, // refresh list
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserCard extends StatelessWidget {
  const _UserCard({
    required this.userId,
    required this.name,
    required this.email,
    required this.role,
    required this.isActive,
    required this.onStatusChanged,
  });

  final int userId;
  final String name;
  final String email;
  final String role;
  final bool isActive;
  final VoidCallback onStatusChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: const Color(0xFFFF7643),
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : "?",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(width: 14),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _Badge(
                      text: role,
                      color: role == "Admin"
                          ? Colors.redAccent
                          : Colors.blueAccent,
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        try {
                          if (isActive) {
                            await UserService.deactivateUser(userId);
                          } else {
                            await UserService.activateUser(userId);
                          }

                          onStatusChanged();
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
                      },
                      child: _Badge(
                        text: isActive ? "Active" : "Inactive",
                        color: isActive ? Colors.green : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.text,
    required this.color,
  });

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class UsersSearchBar extends StatelessWidget {
  const UsersSearchBar({
    super.key,
    this.onChanged,
  });

  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: "Search user by name or email",
        hintStyle: const TextStyle(
          color: Color(0xFF757575),
        ),
        prefixIcon: const Icon(
          Icons.search,
          color: Color(0xFF757575),
        ),
        filled: true,
        fillColor: const Color(0xFFF5F6F9),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
