import 'package:frontend_roti/models/product.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/models/userModel.dart';
import 'package:frontend_roti/models/rute.dart';
import 'package:frontend_roti/services/order/orderService.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/services/rute/ruteService.dart';
import 'package:frontend_roti/models/orderForm.dart';
import 'package:frontend_roti/services/products/productServices.dart';
import 'package:frontend_roti/constants/helper.dart';

class OrderCreateScreen extends StatefulWidget {
  const OrderCreateScreen({super.key});

  @override
  State<OrderCreateScreen> createState() => _OrderCreateScreenState();
}

class _OrderCreateScreenState extends State<OrderCreateScreen> {
  /// ================= STATE =================
  UserModel? selectedUser;
  RouteLine? selectedRute;
  DateTime orderDate = DateTime.now();

  bool isLoading = false;
  bool loadingUser = true;
  bool loadingRute = false;

  List<UserModel> users = [];
  List<RouteLine> rutes = [];
  List<Product> products = [];
  List<OrderFormItem> items = [OrderFormItem()];

  /// ================= INIT =================
  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadProducts();
  }

  /// ================= LOADERS =================
  Future<void> _loadUsers() async {
    final raw = await UserService.getUsers();
    users = raw.map<UserModel>((e) => UserModel.fromJson(e)).toList();
    setState(() => loadingUser = false);
  }

  Future<void> _loadRutes(int userId) async {
    setState(() => loadingRute = true);

    try {
      rutes = await RouteLineService.getRouteLinesDropdown(userId);
    } catch (e) {
      debugPrint("Load rute error: $e");
      rutes = [];
    } finally {
      if (mounted) setState(() => loadingRute = false);
    }
  }

  Future<void> _loadProducts() async {
    try {
      products = await ProductService.getProductsDropdown();
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Load products error: $e");
      products = [];
    }
  }

  /// ================= SUBMIT =================
  Future<void> _submit() async {
    if (selectedUser == null || selectedRute == null) {
      _error("User dan rute wajib diisi");
      return;
    }

    if (items.any((e) => e.productId == null || e.unit == null)) {
      _error("Lengkapi item order");
      return;
    }

    setState(() => isLoading = true);

    try {
      await OrderPickingService.createOrder(
        userId: selectedUser!.id,
        ruteId: selectedRute!.id,
        orderDate: orderDate,
        items: items.map((e) => e.toJson()).toList(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _error(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _error(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(backgroundColor: Colors.red, content: Text(msg)));
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("dd MMM yyyy");

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Create Order"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            /// USER
            _label("User"),
            loadingUser
                ? const CircularProgressIndicator()
                : _dropdown<UserModel>(
                    value: selectedUser,
                    hint: "Pilih User",
                    items: users,
                    label: (u) => u.email,
                    onChanged: (v) {
                      selectedUser = v;
                      selectedRute = null;
                      rutes.clear();
                      _loadRutes(v!.id);
                      setState(() {});
                    },
                  ),

            const SizedBox(height: 16),

            /// RUTE
            _label("Rute"),
            loadingRute
                ? const CircularProgressIndicator()
                : _dropdown<RouteLine>(
                    value: selectedRute,
                    hint: "Pilih Rute",
                    items: rutes,
                    label: (r) => r.name,
                    onChanged: (v) => setState(() => selectedRute = v),
                  ),

            const SizedBox(height: 16),

            /// DATE
            _label("Tanggal Order"),
            ListTile(
              tileColor: const Color(0xFFF5F6F9),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                dateFormat.format(orderDate),
                style: const TextStyle(color: Colors.black),
              ),
              trailing: const Icon(Icons.calendar_today, color: Colors.black),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: orderDate,
                  firstDate: DateTime(2023),
                  lastDate: DateTime(2030),
                );
                if (picked != null) setState(() => orderDate = picked);
              },
            ),

            const SizedBox(height: 24),

            /// ITEMS
            _label("Items"),
            ...items.asMap().entries.map((entry) {
              final i = entry.key;
              final item = entry.value;

              return _itemCard(item, i);
            }),

            TextButton.icon(
              onPressed: () => setState(() => items.add(OrderFormItem())),
              icon: const Icon(Icons.add, color: Colors.indigo),
              label: const Text(
                "Tambah Item",
                style: TextStyle(color: Colors.indigo),
              ),
            ),

            const SizedBox(height: 24),

            /// SUBMIT
            ElevatedButton(
              onPressed: isLoading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7643),
                minimumSize: const Size(double.infinity, 50),
                shape: const StadiumBorder(),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Simpan Order",
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= ITEM CARD =================
  Widget _itemCard(OrderFormItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Item ${index + 1}",
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              if (items.length > 1)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => setState(() => items.removeAt(index)),
                ),
            ],
          ),

          const SizedBox(height: 8),

          /// PRODUCT DROPDOWN
          _label("Product"),
          _dropdown<Product>(
            value: _findProduct(item.productId),
            hint: "Pilih Product",
            items: products,
            label: (p) => p.name,
            onChanged: (v) => setState(() => item.productId = v?.id),
          ),

          const SizedBox(height: 12),

          /// UNIT DROPDOWN
          _label("Unit"),
          _dropdown<String>(
            value: item.unit,
            hint: "Pilih Unit",
            items: PRODUCT_TYPE,
            label: (u) => u,
            onChanged: (v) => setState(() => item.unit = v),
          ),

          const SizedBox(height: 12),

          /// QTY
          TextField(
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.black),
            decoration: const InputDecoration(
              labelText: "Qty",
              hintStyle: TextStyle(color: Colors.black),
            ),
            onChanged: (v) => item.qty = int.tryParse(v) ?? 1,
          ),

          /// MARKET STORE
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            value: item.marketStore,
            onChanged: (v) => setState(() => item.marketStore = v),
            title: const Text(
              "Market Store",
              style: TextStyle(color: Colors.black),
            ),
            activeColor: Colors.white,
            activeTrackColor: const Color(0xFFFF7643),

            inactiveThumbColor: Colors.white,
            inactiveTrackColor: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Product? _findProduct(int? id) {
    if (id == null) return null;
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// ================= HELPERS =================
Widget _label(String text) => Padding(
  padding: const EdgeInsets.only(bottom: 6),
  child: Text(
    text,
    style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black),
  ),
);

Widget _dropdown<T>({
  required T? value,
  required String hint,
  required List<T> items,
  required String Function(T) label,
  required ValueChanged<T?> onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      color: const Color(0xFFF5F6F9),
      borderRadius: BorderRadius.circular(12),
    ),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<T>(
        dropdownColor: Colors.white,
        isExpanded: true,
        value: value,
        hint: Text(hint, style: const TextStyle(color: Colors.black)),
        icon: const Icon(
          Icons.keyboard_arrow_down_rounded,
          color: Colors.black,
        ),
        items: items
            .map(
              (e) => DropdownMenuItem(
                value: e,
                child: Text(
                  label(e),
                  style: const TextStyle(color: Colors.black),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
      ),
    ),
  );
}
