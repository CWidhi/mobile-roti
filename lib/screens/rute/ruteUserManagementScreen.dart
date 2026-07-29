import 'package:flutter/material.dart';
import 'package:frontend_roti/models/userModel.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/screens/rute/userRouteCard.dart';

class RuteUserManagementScreen extends StatefulWidget {
  const RuteUserManagementScreen({super.key});

  @override
  State<RuteUserManagementScreen> createState() =>
      _RuteUserManagementScreenState();
}

class _RuteUserManagementScreenState
    extends State<RuteUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();

  bool _loading = true;

  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _loading = true;
    });

    try {
      final response = await UserService.getUsers();

      final users = response
          .map<UserModel>((e) => UserModel.fromJson(e))
          .toList();

      users.sort((a, b) => a.firstName.compareTo(b.firstName));

      if (!mounted) return;

      setState(() {
        _users = users;
        _filteredUsers = users;
      });
    } catch (e) {
      debugPrint(e.toString());

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _search(String keyword) {
    if (keyword.isEmpty) {
      setState(() {
        _filteredUsers = _users;
      });
      return;
    }

    final value = keyword.toLowerCase();

    setState(() {
      _filteredUsers = _users.where((user) {
        final fullname =
            "${user.firstName} ${user.lastName}".toLowerCase();

        return fullname.contains(value) ||
            user.email.toLowerCase().contains(value);
      }).toList();
    });
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: TextField(
        controller: _searchController,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: "Cari sales...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _searchController.clear();
                    _search("");
                  },
                ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      child: Text(
        "${_filteredUsers.length} Sales",
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredUsers.isEmpty) {
      return const Center(
        child: Text(
          "Data sales tidak ditemukan",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUsers,
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 20),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];

          return UserRouteCard(
            key: ValueKey(user.id),
            user: user,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        surfaceTintColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Manajemen Rute Sales",
        ),
      ),

      body: Column(
        children: [
          _buildSearchBox(),
          _buildHeader(),
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
    );
  }
}