import 'package:flutter/material.dart';
import 'package:frontend_roti/models/rute.dart';
import 'package:frontend_roti/screens/rute/store/storeCreateScreen.dart';
import 'package:frontend_roti/services/rute/ruteService.dart';
import 'package:frontend_roti/screens/rute/store/storeDetailScreen.dart';
import 'package:url_launcher/url_launcher.dart';

class RouteLineDetailScreen extends StatefulWidget {
  final RouteLine route;
  final bool isAdmin;

  const RouteLineDetailScreen({
    Key? key,
    required this.route,
    required this.isAdmin,
  }) : super(key: key);

  @override
  State<RouteLineDetailScreen> createState() => _RouteLineDetailScreenState();
}

class _RouteLineDetailScreenState extends State<RouteLineDetailScreen> {
  late Future<RouteLine> _routeFuture;

  @override
  void initState() {
    super.initState();
    _loadRoute();
  }

  void _loadRoute() {
    _routeFuture = RouteLineService.getRouteLineDetail(widget.route.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.route.name),
      ),

      /// FLOATING ADD STORE (ADMIN ONLY)
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              heroTag: null,
              backgroundColor: const Color(0xFFFF7643),
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateStoreScreen(
                      routeId: widget.route.id,
                    ),
                  ),
                );

                if (result == true) {
                  setState(() {
                    _loadRoute(); // 🔥 REFRESH DETAIL ROUTE
                  });
                }
              },
            )
          : null,

      body: FutureBuilder<RouteLine>(
        future: _routeFuture,
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

          final route = snapshot.data!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// HEADER
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "${route.stores.length} Store",
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              const Divider(),

              /// STORE LIST
              Expanded(
                child: route.stores.isEmpty
                    ? const Center(
                        child: Text(
                          "Belum ada store di rute ini",
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: route.stores.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final store = route.stores[index];
                          return _StoreCard(
                            store: store,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => StoreDetailScreen(
                                    routeId: route.id,
                                    storeId: store.id,
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// ===============================
/// STORE CARD
/// ===============================
class _StoreCard extends StatelessWidget {
  final dynamic store;
  final VoidCallback onTap;

  const _StoreCard({
    required this.store,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.store, color: Color(0xFFFF7643)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      store.name ?? "-",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              Text(
                store.address ?? "",
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 8),

              /// MAP BUTTON (PER ITEM)
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                    icon: const Icon(Icons.map, size: 18),
                    label: const Text("Maps"),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF7643),
                      side: const BorderSide(color: Color(0xFFFF7643)),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    onPressed: () async {
                      final coordinate = store.coordinate;

                      if (coordinate == null || coordinate.isEmpty) {
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
                    }),
              ),
            ],
          ),
        ));
  }
}
