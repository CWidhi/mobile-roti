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
  State<AddRouteBottomSheet> createState() => _AddRouteBottomSheetState();
}

class _AddRouteBottomSheetState extends State<AddRouteBottomSheet> {
  final TextEditingController _searchController = TextEditingController();

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
      final routes = await RouteLineService.getRouteLines(null, null);

      final currentIds = widget.currentRoutes.map((e) => e.id).toSet();

      _allRoutes = routes.where((e) => !currentIds.contains(e.id)).toList();

      _allRoutes.sort((a, b) => a.name.compareTo(b.name));

      _filteredRoutes = List.from(_allRoutes);
    } catch (e) {
      debugPrint(e.toString());

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(e.toString())));
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
        return route.name.toLowerCase().contains(keyword);
      }).toList();
    });
  }

  Future<void> _save() async {
    if (_selectedRoute == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Silakan pilih route.")));
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

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }

    if (mounted) {
      setState(() {
        _saving = false;
      });
    }
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: TextField(
        controller: _searchController,
        onChanged: _search,
        cursorColor: const Color(0xFFFF7643),
        style: const TextStyle(color: Color(0xFF333333), fontSize: 15),
        decoration: InputDecoration(
          hintText: "Cari route...",
          hintStyle: const TextStyle(color: Color(0xFF9E9E9E)),
          prefixIcon: const Icon(Icons.search, color: Color(0xFFFF7643)),
          filled: true,
          fillColor: const Color(0xFFFFF4EE),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: Color(0xFFFF7643), width: 1.5),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_filteredRoutes.isEmpty) {
      return const Center(
        child: Text(
          "Semua route sudah dimiliki",
          style: TextStyle(
            color: Color(0xFF757575),
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
    }

    return ListView.separated(
      itemCount: _filteredRoutes.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, index) {
        final route = _filteredRoutes[index];

        return RadioListTile<RouteLine>(
          value: route,
          groupValue: _selectedRoute,
          activeColor: const Color(0xFFFF7643),
          onChanged: (value) {
            setState(() {
              _selectedRoute = value;
            });
          },
          title: Text(
            route.name,
            style: const TextStyle(
              color: Color(0xFF333333),
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          secondary: const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFFFFF2EC),
            child: Icon(Icons.route, color: Color(0xFFFF7643), size: 18),
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
        height: 52,
        child: FilledButton.icon(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFFFF7643),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Icon(Icons.check_circle_outline),
          label: Text(
            _saving ? "Menyimpan..." : "Tambahkan Route",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.80,
        child: Column(
          children: [
            const SizedBox(height: 12),

            Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(50),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Tambah Route",
              style: TextStyle(
                color: Color(0xFF222222),
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            const SizedBox(height: 20),

            _buildSearch(),

            Expanded(child: _buildList()),

            _buildButton(),
          ],
        ),
      ),
    );
  }
}
