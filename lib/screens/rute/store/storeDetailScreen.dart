import 'package:flutter/material.dart';
import 'package:frontend_roti/services/rute/storeService.dart';
import 'package:frontend_roti/screens/rute/store/storeUpdateScreen.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:url_launcher/url_launcher.dart';

class StoreDetailScreen extends StatefulWidget {
  final int routeId;
  final int storeId;

  const StoreDetailScreen({
    Key? key,
    required this.routeId,
    required this.storeId,
  }) : super(key: key);

  @override
  State<StoreDetailScreen> createState() => _StoreDetailScreenState();
}

class _StoreDetailScreenState extends State<StoreDetailScreen> {
  late Future<Map<String, dynamic>> _futureStore;
  late Future<bool> _isAdminFuture;

  static const primaryColor = Color(0xFFFF7643);

  @override
  void initState() {
    super.initState();

    _futureStore = StoreService.getStoreDetail(
      routeId: widget.routeId,
      storeId: widget.storeId,
    );

    _isAdminFuture = UserService.isAdmin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Store"),
      ),
      bottomNavigationBar: FutureBuilder<bool>(
        future: _isAdminFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(); // jangan tampilkan apa-apa
          }

          if (snapshot.data != true) {
            return const SizedBox(); // bukan admin
          }

          // ADMIN ONLY
          return Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Update Store"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () async {
                  final updated = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => UpdateStoreScreen(
                        routeId: widget.routeId,
                        storeId: widget.storeId,
                      ),
                    ),
                  );

                  if (updated == true) {
                    setState(() {
                      _futureStore = StoreService.getStoreDetail(
                        routeId: widget.routeId,
                        storeId: widget.storeId,
                      );
                    });
                  }
                },
              ),
            ),
          );
        },
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _futureStore,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          final store = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// HEADER
                Text(
                  store["name"] ?? "-",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  store["storeType"] ?? "-",
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),

                const SizedBox(height: 20),

                /// INFO CARD
                _InfoCard(
                  icon: Icons.location_on,
                  label: "Alamat",
                  value: store["address"] ?? "-",
                ),
                _InfoCard(
                  icon: Icons.phone,
                  label: "Telepon",
                  value: store["phone"] ?? "-",
                ),
                _InfoCard(
                  icon: Icons.map,
                  label: "Koordinat",
                  value: store["coordinate"] ?? "-",
                ),

                const SizedBox(height: 24),

                /// MAP BUTTON
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map),
                    label: const Text("Buka di Maps"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () async {
                      final coordinate = store["coordinate"];

                      if (coordinate == null || coordinate.toString().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Koordinat tidak tersedia")),
                        );
                        return;
                      }

                      final url = Uri.parse("geo:$coordinate?q=$coordinate");

                      try {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text("Gagal membuka Google Maps")),
                        );
                      }
                    },
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

class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFFFF7643)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
