import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/models/order.dart';
import 'package:frontend_roti/services/order/orderService.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/screens/order/orderUpdateScreen.dart';

class OrderPickingDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderPickingDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderPickingDetailScreen> createState() =>
      _OrderPickingDetailScreenState();
}

class _OrderPickingDetailScreenState extends State<OrderPickingDetailScreen> {
  OrderPicking? order;

  bool isAdmin = false;
  bool loadingUser = true;
  bool loadingOrder = true;

  @override
  void initState() {
    super.initState();
    _loadMe();
    _loadOrder();
  }

  /// ================= LOAD USER =================
  Future<void> _loadMe() async {
    final me = await UserService.getMe();

    if (!mounted) return;

    setState(() {
      isAdmin = me?['is_staff'] == true;
      loadingUser = false;
    });
  }

  /// ================= LOAD ORDER =================
  Future<void> _loadOrder() async {
    try {
      final result = await OrderPickingService.getOrderDetail(widget.orderId);

      if (!mounted) return;

      setState(() {
        order = result;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => loadingOrder = false);
      }
    }
  }

  /// ================= REFRESH =================
  Future<void> _refreshOrder() async {
    setState(() {
      order = null;
      loadingOrder = true;
    });

    await _loadOrder();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Detail Order"),
      ),

      /// ================= BODY =================
      body: loadingUser || loadingOrder
          ? const Center(child: CircularProgressIndicator())
          : order == null
              ? const Center(child: Text("Data tidak ditemukan"))
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _sectionCard(
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _infoRow(
                            "Customer",
                            order!.user?.firstName ?? "User #${order!.userId}",
                          ),
                          _infoRow(
                            "Rute",
                            order!.rute?.name ?? "Rute #${order!.ruteId}",
                          ),
                          _infoRow(
                            "Tanggal",
                            dateFormat.format(order!.orderDate),
                          ),
                          _infoRow(
                            "Status",
                            order!.confirmations ? "Confirmed" : "Pending",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Items",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...order!.items.map(
                      (item) => _sectionCard(
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  "${item.qty} x ${currency.format(item.price)}",
                                  style: const TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              currency.format(item.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        "Total: ${currency.format(order!.total)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF7643),
                        ),
                      ),
                    ),
                  ],
                ),

      /// ================= BOTTOM BAR (ADMIN) =================
      bottomNavigationBar: isAdmin && order != null
          ? _BottomBar(
              order: order!,
              onRefresh: _refreshOrder,
            )
          : null,
    );
  }

  Widget _sectionCard(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black)),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final OrderPicking order;
  final VoidCallback onRefresh;

  const _BottomBar({
    required this.order,
    required this.onRefresh,
  });

  static const primaryColor = Color(0xFFFF7643);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            /// UPDATE
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFECDF),
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderUpdateScreen(order: order),
                    ),
                  );

                  if (result == true) {
                    // Navigator.pop(context, true);
                    onRefresh();
                  }
                },
                icon: const Icon(
                  Icons.edit,
                  color: Color(0xFFFF7643),
                ),
                label: const Text(
                  "Update Order",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7643),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            /// CONFIRM
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                ),
                onPressed: order.confirmations
                    ? null
                    : () async {
                        try {
                          await OrderPickingService.confirmOrder(order.id);

                          if (!context.mounted) return;

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Order berhasil dikonfirmasi"),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pop(context, true);
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
                child: Text(
                  order.confirmations ? "Sudah Confirmed" : "Confirm Order",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
