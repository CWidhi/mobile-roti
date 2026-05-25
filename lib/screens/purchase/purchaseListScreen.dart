import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/models/purchase.dart';
import 'package:frontend_roti/services/purchase/purchaseService.dart';
import 'package:frontend_roti/screens/purchase/purchaseDetailScreen.dart';
import 'package:frontend_roti/screens/purchase/purchaseCreateScreen.dart';

class PurchaseListScreen extends StatefulWidget {
  const PurchaseListScreen({super.key});

  @override
  State<PurchaseListScreen> createState() => _PurchaseListScreenState();
}

class _PurchaseListScreenState extends State<PurchaseListScreen> {
  final searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  List<Purchase> purchases = [];
  String? nextPageUrl;

  bool isLoading = false;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    fetchPurchases();

    _scrollController.addListener(() {
      if (!isRefreshing &&
          !isLoading &&
          nextPageUrl != null &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        fetchPurchases(url: nextPageUrl);
      }
    });
  }

  /// ================= FETCH =================

  Future<void> fetchPurchases({String? search, String? url}) async {
    setState(() => isLoading = true);

    try {
      final data =
          await PurchaseService.getPurchases(search: search, url: url);

      nextPageUrl = data['next'];

      final List<Purchase> fetched =
          (data['results'] as List).map((e) => Purchase.fromJson(e)).toList();

      setState(() {
        if (url == null) purchases.clear();
        purchases.addAll(fetched);
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ================= SEARCH =================

  void _onSearch(String value) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchPurchases(search: value, url: null);
    });
  }

  /// ================= REFRESH =================

  Future<void> _onRefresh() async {
    isRefreshing = true;
    nextPageUrl = null;
    await fetchPurchases(
      search: searchController.text,
      url: null,
    );
    isRefreshing = false;
  }

  @override
  void dispose() {
    searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Purchase"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: null,
        backgroundColor: const Color(0xFFFF7643),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PurchaseCreateScreen()),
          );

          if (result == true) {
            fetchPurchases(url: null);
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// SEARCH
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: _onSearch,
                style: const TextStyle(color: Colors.black),
                decoration: InputDecoration(
                  hintText: "Cari supplier / purchase",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFFF5F6F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            /// LIST
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFFF7643),
                onRefresh: _onRefresh,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: purchases.length +
                      ((nextPageUrl != null || isLoading) ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index < purchases.length) {
                      return _purchaseCard(
                        context,
                        purchases[index],
                        currency,
                        dateFormat,
                      );
                    }

                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= CARD =================

  Widget _purchaseCard(
    BuildContext context,
    Purchase purchase,
    NumberFormat currency,
    DateFormat dateFormat,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PurchaseDetailScreen(
              purchaseId: purchase.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SUPPLIER
            Text(
              purchase.supplier.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            const SizedBox(height: 4),

            /// DATE
            Text(
              "Tanggal: ${dateFormat.format(purchase.purchaseDate)}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 8),

            /// ITEM COUNT
            Text(
              "${purchase.items.length} item",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 8),

            /// TOTAL
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currency.format(purchase.total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFF7643),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
