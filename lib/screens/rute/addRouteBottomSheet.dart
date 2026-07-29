import 'package:flutter/material.dart';
import 'package:frontend_roti/models/rute.dart';
import 'package:frontend_roti/services/rute/ruteService.dart';

class AddRouteBottomSheet extends StatefulWidget {
  final int userId;
  final List<RouteLine> currentRoutes;

  const AddRouteBottomSheet({
    super.key,
    required this.userId,
    required this.currentRoutes,
  });

  @override
  State<AddRouteBottomSheet> createState() =>
      _AddRouteBottomSheetState();
}

class _AddRouteBottomSheetState
    extends State<AddRouteBottomSheet> {
  final TextEditingController _searchController =
      TextEditingController();

  bool _loading = true;
  bool _saving = false;

  List<RouteLine> _allRoutes = [];
  List<RouteLine> _filteredRoutes = [];

  RouteLine? _selectedRoute;

  @override
  void initState() {
    super.initState();
    _loadRoutes();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadRoutes() async {
    try {
      final routes =
          await RouteLineService.getRouteLines(null, null);

      final currentIds =
          widget.currentRoutes.map((e) => e.id).toSet();

      _allRoutes = routes
          .where((e) => !currentIds.contains(e.id))
          .toList();

      _allRoutes.sort(
        (a, b) => a.name.compareTo(b.name),
      );

      _filteredRoutes = List.from(_allRoutes);
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  void _search(String value) {
    if (value.isEmpty) {
      setState(() {
        _filteredRoutes = List.from(_allRoutes);
      });
      return;
    }

    final keyword = value.toLowerCase();

    setState(() {
      _filteredRoutes = _allRoutes.where((route) {
        return route.name
            .toLowerCase()
            .contains(keyword);
      }).toList();
    });
  }

  Future<void> _save() async {
    if (_selectedRoute == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Silakan pilih route."),
        ),
      );
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await RouteLineService.addUserToRute(
        userId: widget.userId,
        ruteLineId: _selectedRoute!.id,
      );

      if (!mounted) return;

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        _saving = false;
      });
    }
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _search,
        decoration: InputDecoration(
          hintText: "Cari route...",
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_filteredRoutes.isEmpty) {
      return const Center(
        child: Text(
          "Semua route sudah dimiliki.",
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredRoutes.length,
      separatorBuilder: (_, __) =>
          const Divider(height: 1),
      itemBuilder: (_, index) {
        final route = _filteredRoutes[index];

        return RadioListTile<RouteLine>(
          value: route,
          groupValue: _selectedRoute,
          activeColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              _selectedRoute = value;
            });
          },
          title: Text(
            route.name,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
            ),
          ),
          secondary: const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xfffff4ea),
            child: Icon(
              Icons.route,
              color: Colors.orange,
              size: 18,
            ),
          ),
        );
      },
    );
  }

  Widget _buildButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child:
                      CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check),
          label: Text(
            _saving
                ? "Menyimpan..."
                : "Tambahkan Route",
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height:
            MediaQuery.of(context).size.height *
                0.80,
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius:
                    BorderRadius.circular(50),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Tambah Route",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),

            const SizedBox(height: 20),

            _buildSearch(),

            Expanded(
              child: _buildList(),
            ),

            _buildButton(),
          ],
        ),
      ),
    );
  }
}