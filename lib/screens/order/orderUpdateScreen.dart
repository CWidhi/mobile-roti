import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/models/order.dart';
import 'package:frontend_roti/models/product.dart';
import 'package:frontend_roti/services/order/orderService.dart';
import 'package:frontend_roti/services/products/productServices.dart';
import 'package:frontend_roti/constants/helper.dart';

class OrderUpdateScreen extends StatefulWidget {
  final OrderPicking order;

  const OrderUpdateScreen({super.key, required this.order});

  @override
  State<OrderUpdateScreen> createState() => _OrderUpdateScreenState();
}

class _OrderUpdateScreenState extends State<OrderUpdateScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime selectedDate;
  late int selectedRuteId;
  bool isSubmitting = false;

  late List<_OrderItemForm> items;
  List<Product> productList = [];
  bool loadingProducts = true;

  @override
  void initState() {
    super.initState();

    selectedDate = widget.order.orderDate;
    selectedRuteId = widget.order.ruteId;

    items = widget.order.items
        .map(
          (e) => _OrderItemForm(
            productId: e.product.id,
            productName: e.product.name,
            unit: e.unit,
            qty: e.qty,
            marketStore: e.marketStore,
            retail: e.retail,
          ),
        )
        .toList();

    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await ProductService.getProductsDropdown();
      if (!mounted) return;
      setState(() {
        productList = products;
        loadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => loadingProducts = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat produk: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  void _addItem() {
    setState(() {
      items.add(
        _OrderItemForm(
          productId: 0,
          productName: "Pilih Produk",
          unit: PRODUCT_TYPE.first,
          qty: 1,
          marketStore: false,
          retail: false,
        ),
      );
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Minimal 1 item"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (items.any((e) => e.productId == 0)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk belum dipilih"),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      await OrderPickingService.updateOrder(
        orderId: widget.order.id,
        ruteId: selectedRuteId,
        orderDate: selectedDate,
        items: items
            .map(
              (e) => {
                "product_id": e.productId,
                "unit": e.unit,
                "qty": e.qty,
                "market_store": e.marketStore,
                "retail": e.retail,
              },
            )
            .toList(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Order berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd MMM yyyy");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Update Order"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loadingProducts
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // DATE
                  _section(
                    title: "Tanggal Order",
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        dateFormat.format(selectedDate),
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: const Icon(
                        Icons.calendar_today,
                        color: Colors.black,
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2024),
                          lastDate: DateTime(2030),
                        );
                        if (picked != null)
                          setState(() => selectedDate = picked);
                      },
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ITEMS
                  _section(
                    title: "Items",
                    child: Column(
                      children: [
                        ...items.map((item) => _itemCard(item)).toList(),
                        const SizedBox(height: 12),
                        OutlinedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add, color: Colors.indigo),
                          label: const Text(
                            "Tambah Item",
                            style: TextStyle(color: Colors.indigo),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SUBMIT
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: isSubmitting ? null : _submit,
                    child: isSubmitting
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Update Order",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _itemCard(_OrderItemForm item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER + DELETE
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // PILIH PRODUK
              Expanded(
                child: DropdownButtonFormField<int>(
                  dropdownColor: Colors.white,
                  value: item.productId == 0 ? null : item.productId,
                  decoration: const InputDecoration(labelText: "Pilih Produk"),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  items: productList
                      .map(
                        (p) => DropdownMenuItem<int>(
                          value: p.id,
                          child: Text(
                            p.name,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      item.productId = value!;
                      item.productName = productList
                          .firstWhere((p) => p.id == value)
                          .name;
                    });
                  },
                  validator: (v) => v == null ? "Produk wajib" : null,
                ),
              ),
              if (items.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () => setState(() => items.remove(item)),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // QTY & UNIT
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: item.qty.toString(),
                  style: const TextStyle(color: Colors.black),
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: "Qty"),
                  onChanged: (v) => item.qty = int.tryParse(v) ?? 0,
                  validator: (v) =>
                      (int.tryParse(v ?? "0") ?? 0) <= 0 ? "Qty wajib" : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: item.unit,
                  dropdownColor: Colors.white,
                  decoration: const InputDecoration(labelText: "Unit"),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  items: PRODUCT_TYPE
                      .map(
                        (u) => DropdownMenuItem<String>(
                          value: u,
                          child: Text(
                            u,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => item.unit = value!),
                  validator: (v) =>
                      v == null || v.isEmpty ? "Unit wajib" : null,
                ),
              ),
            ],
          ),

          // MARKET STORE SWITCH
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Market Store",
              style: TextStyle(color: Colors.black),
            ),
            value: item.marketStore,
            onChanged: (v) => setState(() => item.marketStore = v),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFFF7643),

            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),

          // RETAIL SWITCH
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              "Retail",
              style: TextStyle(color: Colors.black),
            ),
            value: item.retail,
            onChanged: (v) => setState(() => item.retail = v),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFFF7643),

            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _section({required String title, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

/// ================= FORM MODEL =================
class _OrderItemForm {
  int productId;
  String productName;
  String unit;
  int qty;
  bool marketStore;
  bool retail;

  _OrderItemForm({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.qty,
    required this.marketStore,
    required this.retail,
  });
}
