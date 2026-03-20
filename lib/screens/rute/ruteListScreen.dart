import 'package:flutter/material.dart';
import 'package:frontend_roti/models/rute.dart';
import 'package:frontend_roti/services/rute/ruteService.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/screens/rute/rutePopUp.dart';
import 'package:frontend_roti/screens/rute/ruteDetailScreen.dart';

class RouteLineListScreen extends StatefulWidget {
  const RouteLineListScreen({Key? key}) : super(key: key);

  @override
  State<RouteLineListScreen> createState() => _RouteLineListScreenState();
}

class _RouteLineListScreenState extends State<RouteLineListScreen> {
  bool isAdmin = false;
  bool isLoadingUser = true;

  final searchController = TextEditingController();
  late Future<List<RouteLine>> _futureRoutes;

  @override
  void initState() {
    super.initState();
    fetchUserRole();
    _loadRoutes();
  }

  void _loadRoutes({String? search}) {
    _futureRoutes = RouteLineService.getRouteLines(search, null);
  }

  void _onSearch() {
    setState(() {
      _loadRoutes(search: searchController.text);
    });
  }

  Future<void> _refresh() async {
    _onSearch();
  }

  Future<void> fetchUserRole() async {
    try {
      final user = await UserService.getMe();
      setState(() {
        isAdmin = user?["is_staff"] == true;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoadingUser = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tracking Line"),
      ),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              heroTag: null,
              backgroundColor: const Color(0xFFFF7643),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(20)),
                  ),
                  builder: (_) => const RouteLineFormModal(),
                );

                if (result == true) _refresh();
              },
            )
          : null,
      body: Column(
        children: [
          /// SEARCH
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: searchController,
              onSubmitted: (_) => _onSearch(),
              decoration: InputDecoration(
                hintText: "Cari rute...",
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF5F6F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          /// LIST
          Expanded(
            child: FutureBuilder<List<RouteLine>>(
              future: _futureRoutes,
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

                final routes = snapshot.data!;

                if (routes.isEmpty) {
                  return const Center(
                    child: Text(
                      "Data rute tidak ditemukan",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: routes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final route = routes[index];
                      return _RouteCard(
                        route: route,
                        isAdmin: isAdmin,
                        onUpdated: _refresh,
                        onDeleted: _refresh,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteCard extends StatelessWidget {
  final RouteLine route;
  final bool isAdmin;
  final VoidCallback onUpdated;
  final VoidCallback onDeleted;

  const _RouteCard({
    required this.route,
    required this.isAdmin,
    required this.onUpdated,
    required this.onDeleted,
  });
  static const primaryColor = Color(0xFFFF7643);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => RouteLineDetailScreen(route: route, isAdmin: isAdmin),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /// LEFT
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "${route.stores.length} store",
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            /// RIGHT (admin only)
            if (isAdmin)
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    color: primaryColor,
                    onPressed: () async {
                      final result = await showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        builder: (_) => RouteLineFormModal(route: route),
                      );

                      if (result == true) onUpdated();
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, size: 18),
                    color: Colors.redAccent,
                    onPressed: () => _confirmDelete(context),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text("Hapus Rute"),
        content: const Text(
          "Rute akan dihapus permanen.\nTindakan ini tidak dapat dibatalkan.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () async {
              Navigator.pop(context);

              try {
                await RouteLineService.deleteRouteLine(route.id);

                if (!context.mounted) return;

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Rute berhasil dihapus"),
                    backgroundColor: Colors.green,
                  ),
                );

                onDeleted();
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    backgroundColor: Colors.redAccent,
                  ),
                );
              }
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }
}
