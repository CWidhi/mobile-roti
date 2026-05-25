import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend_roti/models/supplier.dart';
import 'package:frontend_roti/screens/supplier/supplierCreateScreen.dart';
import 'package:frontend_roti/screens/supplier/supplierDetailScreen.dart';
import 'package:frontend_roti/services/supplier/supplierService.dart';

class SupplierListScreen extends StatefulWidget {
  const SupplierListScreen({super.key});

  @override
  State<SupplierListScreen> createState() => _SupplierListScreenState();
}

class _SupplierListScreenState extends State<SupplierListScreen> {
  final TextEditingController searchController = TextEditingController();
  Timer? _debounce;
  ScrollController _scrollController = ScrollController();

  List<Supplier> suppliers = [];
  String? nextPageUrl;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchSuppliers();

    // Listener scroll untuk pagination
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading &&
          nextPageUrl != null) {
        fetchSuppliers(url: nextPageUrl);
      }
    });
  }

  Future<void> fetchSuppliers({String? search, String? url}) async {
    setState(() {
      isLoading = true;
    });

    try {
      final data = await SupplierService.getSuppliers(search: search, url: url);
      // Asumsi data berupa Map dengan keys: count, next, previous, results
      nextPageUrl = data['next'];
      final List<Supplier> newSuppliers = (data['results'] as List)
          .map((e) => Supplier.fromJson(e))
          .toList();
      setState(() {
        if (url == null)
          suppliers.clear(); // kalau search atau initial load, clear dulu
        suppliers.addAll(newSuppliers);
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchSuppliers(search: value, url: null);
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() {
    fetchSuppliers(search: searchController.text, url: null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Supplier"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: const Color(0xFFFF7643),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSupplierScreen()),
          );
          if (result == true) _refresh();
        },
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: TextField(
              controller: searchController,
              onChanged: _onSearch,
              decoration: InputDecoration(
                hintText: "Cari supplier...",
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

          Expanded(
            child: suppliers.isEmpty && isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(20),
                    itemCount: suppliers.length + (nextPageUrl != null ? 1 : 0),
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      if (index < suppliers.length) {
                        final supplier = suppliers[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(14),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    SupplierDetailScreen(supplier: supplier),
                              ),
                            ).then((_) => _refresh());
                          },
                          child: _supplierCard(supplier),
                        );
                      } else {
                        // Loader untuk next page
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _supplierCard(Supplier supplier) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECDF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_shipping, color: Color(0xFFFF7643)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  supplier.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  supplier.address,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  supplier.phoneNumber,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
