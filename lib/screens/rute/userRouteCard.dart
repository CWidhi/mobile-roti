import 'package:flutter/material.dart';
import 'package:frontend_roti/models/rute.dart';
import 'package:frontend_roti/models/userModel.dart';
import 'package:frontend_roti/services/rute/ruteService.dart';
import 'package:frontend_roti/screens/rute/addRouteBottomSheet.dart';

class UserRouteCard extends StatefulWidget {
  final UserModel user;

  const UserRouteCard({
    super.key,
    required this.user,
  });

  @override
  State<UserRouteCard> createState() => _UserRouteCardState();
}

class _UserRouteCardState extends State<UserRouteCard> {
  bool _expanded = false;
  bool _loading = false;
  bool _loaded = false;

  List<RouteLine> _routes = [];

  Future<void> _loadRoutes() async {
    if (_loaded) return;

    setState(() {
      _loading = true;
    });

    try {
      _routes = await RouteLineService.getRouteByUser(
        widget.user.email,
      );

      _loaded = true;
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }

    if (mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> _refreshRoutes() async {
    try {
      final routes = await RouteLineService.getRouteByUser(
        widget.user.email,
      );

      if (!mounted) return;

      setState(() {
        _routes = routes;
        _loaded = true;
      });
    } catch (_) {}
  }

  Future<void> _showAddRoute() async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (_) {
        return AddRouteBottomSheet(
          userId: widget.user.id,
          currentRoutes: _routes,
        );
      },
    );

    if (result == true) {
      await _refreshRoutes();
    }
  }

  Future<void> _deleteRoute(RouteLine route) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text("Hapus Route"),
          content: Text(
            "Hapus '${route.name}' dari ${widget.user.firstName} ${widget.user.lastName} ?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Batal"),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Hapus"),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await RouteLineService.removeUserToRute(
        userId: widget.user.id,
        ruteLineId: route.id,
      );

      _routes.removeWhere((e) => e.id == route.id);

      if (!mounted) return;

      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Route berhasil dihapus"),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
        ),
      );
    }
  }

  Widget _buildHeader() {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 6,
      ),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFFFE3D5),
        child: Text(
          widget.user.firstName.isEmpty
              ? "?"
              : widget.user.firstName[0].toUpperCase(),
          style: const TextStyle(
            color: const Color(0xFFFF7643),
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      title: Text(
        "${widget.user.firstName} ${widget.user.lastName}",
        style: const TextStyle(
          color: Color(0xFF222222),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        widget.user.email,
        style: const TextStyle(
          color: Color(0xFF757575),
        ),
      ),
      trailing: Icon(
        _expanded
            ? Icons.keyboard_arrow_up_rounded
            : Icons.keyboard_arrow_down_rounded,
        color: const Color(0xFFFF7643),
      ),
    );
  }

  Widget _buildRouteItem(RouteLine route) {
    return Dismissible(
      key: ValueKey(route.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        await _deleteRoute(route);
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      child: ListTile(
        dense: true,
        leading: const CircleAvatar(
          radius: 17,
          backgroundColor: Color(0xfffff4ea),
          child: Icon(
            Icons.route,
            size: 18,
            color: Colors.orange,
          ),
        ),
        title: Text(
          route.name,
          style: const TextStyle(
            color: Color(0xFF333333),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Column(
      children: [
        if (_routes.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Belum mempunyai route.",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ),

        ..._routes.map(_buildRouteItem),

        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 46,
            child: FilledButton.icon(
              icon: const Icon(Icons.add),
              label: const Text("Tambah Route"),
              onPressed: _showAddRoute,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black12,
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          showTrailingIcon: false,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          initiallyExpanded: false,
          onExpansionChanged: (value) {
            _expanded = value;

            if (_expanded) {
              _loadRoutes();
            }

            setState(() {});
          },
          title: _buildHeader(),
          children: [
            const Divider(height: 1),
            _buildContent(),
          ],
        ),
      ),
    );
  }
}