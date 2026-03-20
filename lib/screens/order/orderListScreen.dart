import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/models/order.dart';
import 'package:frontend_roti/services/order/orderService.dart';
import 'package:frontend_roti/screens/order/orderCreateScreen.dart';
import 'package:frontend_roti/screens/order/orderDetailScreen.dart';

class OrderPickingListScreen extends StatefulWidget {
  final bool isAdmin;

  const OrderPickingListScreen({
    super.key,
    required this.isAdmin,
  });

  @override
  State<OrderPickingListScreen> createState() => _OrderPickingListScreenState();
}

class _OrderPickingListScreenState extends State<OrderPickingListScreen> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounce;

  List<OrderPicking> orders = [];
  String? nextPageUrl;

  bool isLoading = false;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    fetchOrders();

    _scrollController.addListener(() {
      if (!isRefreshing &&
          !isLoading &&
          nextPageUrl != null &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        fetchOrders(url: nextPageUrl);
      }
    });
  }

  /// ================= FETCH =================
  Future<void> fetchOrders({String? search, String? url}) async {
    setState(() => isLoading = true);

    try {
      final data = await OrderPickingService.getOrderPickings(
        search: search,
        url: url,
      );

      nextPageUrl = data['next'];

      final List<OrderPicking> fetched = (data['results'] as List)
          .map((e) => OrderPicking.fromJson(e))
          .toList();

      setState(() {
        if (url == null) orders.clear();
        orders.addAll(fetched);
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
      nextPageUrl = null;
      fetchOrders(search: value, url: null);
    });
  }

  /// ================= REFRESH =================
  Future<void> _onRefresh() async {
    isRefreshing = true;
    nextPageUrl = null;

    await fetchOrders(
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
      appBar: AppBar(
        title: const Text("Order Picking"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),

      /// ➕ ADMIN ONLY
      floatingActionButton: widget.isAdmin
          ? FloatingActionButton(
              heroTag: null,
              backgroundColor: const Color(0xFFFF7643),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OrderCreateScreen(),
                  ),
                );

                if (result == true) {
                  fetchOrders(url: null);
                }
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,

      body: SafeArea(
        child: Column(
          children: [
            /// SEARCH
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: searchController,
                onChanged: _onSearch,
                decoration: InputDecoration(
                  hintText: "Cari order / user / rute",
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
                  itemCount: orders.length +
                      ((nextPageUrl != null || isLoading) ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index < orders.length) {
                      return _orderCard(
                        context,
                        orders[index],
                        currency,
                        dateFormat,
                      );
                    }

                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
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

  Widget _statusBadge(bool confirmed) {
    final color = confirmed ? Colors.green : Colors.orange;
    final text = confirmed ? "Confirmed" : "Pending";

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  /// ================= CARD =================
  Widget _orderCard(
    BuildContext context,
    OrderPicking order,
    NumberFormat currency,
    DateFormat dateFormat,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => OrderPickingDetailScreen(
              orderId: order.id,
            ),
          ),
        );

        if (result == true) {
          nextPageUrl = null;
          fetchOrders(
            search: searchController.text,
            url: null,
          );
        }
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
            /// ===== HEADER =====
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.user?.firstName ?? "User #${order.userId}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                _statusBadge(order.confirmations),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              order.rute?.name ?? "Rute #${order.ruteId}",
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "Tanggal: ${dateFormat.format(order.orderDate)}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 8),

            Text(
              "${order.items.length} item",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: Text(
                currency.format(order.total),
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
