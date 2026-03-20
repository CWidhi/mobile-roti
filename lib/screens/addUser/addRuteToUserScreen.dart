import 'package:flutter/material.dart';
import 'package:frontend_roti/models/userModel.dart';
import 'package:frontend_roti/models/rute.dart';
import 'package:frontend_roti/services/rute/ruteService.dart';
import 'package:frontend_roti/services/auth/userService.dart';

class RuteAddUserScreen extends StatefulWidget {
  const RuteAddUserScreen({super.key});

  @override
  State<RuteAddUserScreen> createState() => _RuteAddUserScreenState();
}

class _RuteAddUserScreenState extends State<RuteAddUserScreen> {
  int? selectedRuteId;
  int? selectedUserId;

  bool isLoading = false;
  bool loadingUser = true;
  bool loadingRute = true;

  List<UserModel> users = [];
  List<RouteLine> rutes = [];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadRutes();
  }

  /// ================= LOAD DATA =================

  Future<void> _loadUsers() async {
    try {
      final rawUsers = await UserService.getUsers();

      users = rawUsers.map<UserModel>((e) => UserModel.fromJson(e)).toList();
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => loadingUser = false);
      }
    }
  }

  Future<void> _loadRutes() async {
    try {
      rutes = await RouteLineService.getRouteLines(null, null);
    } finally {
      if (mounted) setState(() => loadingRute = false);
    }
  }

  /// ================= SUBMIT =================

  Future<void> _submit() async {
    if (selectedUserId == null || selectedRuteId == null) {
      _showError("Pilih user dan rute terlebih dahulu");
      return;
    }

    setState(() => isLoading = true);

    try {
      await RouteLineService.addUserToRute(
        userId: selectedUserId!,
        ruteLineId: selectedRuteId!,
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.redAccent,
        content: Text(msg),
      ),
    );
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah User ke Rute"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// RUTE
              const Text("Rute", style: _labelStyle),
              const SizedBox(height: 6),
              loadingRute
                  ? _loadingBox()
                  : _dropdown<int>(
                      value: selectedRuteId,
                      hint: "Pilih Rute",
                      items: rutes
                          .map(
                            (r) => DropdownMenuItem(
                              value: r.id,
                              child: Text(r.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedRuteId = v),
                    ),

              const SizedBox(height: 16),

              /// USER
              const Text("User", style: _labelStyle),
              const SizedBox(height: 6),
              loadingUser
                  ? _loadingBox()
                  : _dropdown<int>(
                      value: selectedUserId,
                      hint: "Pilih User",
                      items: users
                          .map(
                            (u) => DropdownMenuItem(
                              value: u.id,
                              child: Text(u.firstName + " " + u.lastName),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedUserId = v),
                    ),

              const Spacer(),

              /// SUBMIT
              ElevatedButton(
                onPressed: isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7643),
                  minimumSize: const Size(double.infinity, 50),
                  shape: const StadiumBorder(),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Tambahkan ke Rute",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ================= HELPERS =================

const _labelStyle = TextStyle(fontWeight: FontWeight.w600);

Widget _dropdown<T>({
  required T? value,
  required String hint,
  required List<DropdownMenuItem<T>> items,
  required ValueChanged<T?> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F6F9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        value: value,
        hint: Text(hint),
        isExpanded: true,
        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}

Widget _loadingBox() => Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
