import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/constants/helper.dart';
import 'package:frontend_roti/models/supplier.dart';
import 'package:frontend_roti/models/product.dart';
import 'package:frontend_roti/services/supplier/supplierService.dart';
import 'package:frontend_roti/services/products/productServices.dart';
import 'package:frontend_roti/services/purchase/purchaseService.dart';

class PurchaseCreateScreen extends StatefulWidget {
  const PurchaseCreateScreen({super.key});

  @override
  State<PurchaseCreateScreen> createState() => _PurchaseCreateScreenState();
}

class _PurchaseCreateScreenState extends State<PurchaseCreateScreen> {
  int? selectedSupplier;
  DateTime? purchaseDate;
  bool isLoading = false;
  String? description;
  int? cashback;

  final dateFormat = DateFormat('yyyy-MM-dd');

  List<Supplier> suppliers = [];
  List<Product> products = [];

  bool loadingSupplier = true;
  bool loadingProduct = true;

  final List<_PurchaseItemForm> items = [_PurchaseItemForm()];

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
    _loadProducts();
  }

  /// ================= LOAD DATA =================

  Future<void> _loadSuppliers() async {
    try {
      final data = await SupplierService.getSupplierDropdown();
      if (!mounted) return;
      setState(() {
        suppliers = data;
        loadingSupplier = false;
      });
    } catch (_) {
      setState(() => loadingSupplier = false);
    }
  }

  Future<void> _loadProducts() async {
    try {
      final data = await ProductService.getProductsDropdown();
      if (!mounted) return;
      setState(() {
        products = data;
        loadingProduct = false;
      });
    } catch (_) {
      setState(() => loadingProduct = false);
    }
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Purchase"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// SUPPLIER
              const Text("Supplier", style: _labelStyle),
              const SizedBox(height: 6),
              loadingSupplier
                  ? _loadingBox()
                  : _dropdown<int>(
                      value: selectedSupplier,
                      hint: "Pilih Supplier",
                      items: suppliers
                          .map(
                            (s) => DropdownMenuItem<int>(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => setState(() => selectedSupplier = v),
                    ),

              const SizedBox(height: 16),

              /// DATE
              const Text("Tanggal Purchase", style: _labelStyle),
              const SizedBox(height: 6),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: purchaseDate ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() => purchaseDate = picked);
                  }
                },
                child: IgnorePointer(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: "Pilih tanggal",
                      prefixIcon: const Icon(Icons.calendar_today_outlined),
                      filled: true,
                      fillColor: const Color(0xFFF5F6F9),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    controller: TextEditingController(
                      text: purchaseDate == null
                          ? ""
                          : dateFormat.format(purchaseDate!),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// ITEMS
              const Text("Items", style: _labelStyle),
              const SizedBox(height: 12),

              ...items.asMap().entries.map(
                    (e) => _itemCard(e.key, e.value),
                  ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () => setState(() => items.add(_PurchaseItemForm())),
                icon: const Icon(Icons.add),
                label: const Text("Tambah Item"),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFFF7643),
                  side: const BorderSide(color: Color(0xFFFF7643)),
                ),
              ),

              const SizedBox(height: 24),
              const Text("Keterangan", style: _labelStyle),
              const SizedBox(height: 6),
              TextField(
                maxLines: 3,
                onChanged: (v) => description = v,
                decoration: InputDecoration(
                  hintText: "Masukkan keterangan (opsional)",
                  filled: true,
                  fillColor: const Color(0xFFF5F6F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 16),
              const Text("Cashback", style: _labelStyle),
              const SizedBox(height: 6),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (v) => cashback = int.tryParse(v),
                decoration: InputDecoration(
                  hintText: "Jumlah cashback",
                  prefixText: "Rp ",
                  filled: true,
                  fillColor: const Color(0xFFF5F6F9),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 32),

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
                        "Simpan Purchase",
                        style: TextStyle(fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// ================= ITEM CARD =================

  Widget _itemCard(int index, _PurchaseItemForm item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Item ${index + 1}",
                  style: const TextStyle(fontWeight: FontWeight.w600)),
              if (items.length > 1)
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () => setState(() => items.removeAt(index)),
                ),
            ],
          ),
          const SizedBox(height: 12),

          /// PRODUCT
          loadingProduct
              ? _loadingBox()
              : _dropdown<int>(
                  value: item.product,
                  hint: "Pilih Product",
                  items: products
                      .map(
                        (p) => DropdownMenuItem<int>(
                          value: p.id,
                          child: Text(p.name),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => item.product = v),
                ),
          const SizedBox(height: 8),

          /// UNIT
          _dropdown<String>(
            value: item.unit,
            hint: "Pilih Unit",
            items: PRODUCT_TYPE
                .map(
                  (u) => DropdownMenuItem<String>(
                    value: u,
                    child: Text(u),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => item.unit = v),
          ),

          const SizedBox(height: 8),

          /// QTY
          _textField(
            hint: "Qty",
            keyboardType: TextInputType.number,
            onChanged: (v) => item.qty = int.tryParse(v),
          ),
        ],
      ),
    );
  }

  /// ================= SUBMIT =================

  Future<void> _submit() async {
    if (selectedSupplier == null || purchaseDate == null || items.isEmpty) {
      _showError("Lengkapi semua data");
      return;
    }

    for (final i in items) {
      if (i.product == null ||
          i.unit == null ||
          i.unit!.isEmpty ||
          i.qty == null ||
          i.qty! <= 0) {
        _showError("Item tidak valid");
        return;
      }
    }

    setState(() => isLoading = true);

    try {
      await PurchaseService.createPurchase(
        supplierId: selectedSupplier!,
        purchaseDate: dateFormat.format(purchaseDate!),
        description: description,
        cashback: cashback,
        items: items
            .map((e) => {
                  "product": e.product,
                  "unit": e.unit,
                  "qty": e.qty,
                })
            .toList(),
      );

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.redAccent,
        content: Text(msg),
      ),
    );
  }
}

/// ================= HELPERS =================

const _labelStyle = TextStyle(fontWeight: FontWeight.w600);

// Widget _inputContainer({required Widget child}) => Container(
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5F6F9),
//         borderRadius: BorderRadius.circular(12),
//       ),
//       child: child,
//     );

Widget _dropdown<T>({
  required T? value,
  required String hint,
  required List<DropdownMenuItem<T>> items,
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
        value: value,
        hint: Text(hint),
        isExpanded: true,

        /// 🔥 INI KUNCINYA
        menuMaxHeight: 300,

        items: items,
        onChanged: onChanged,
      ),
    ),
  );
}

Widget _textField({
  required String hint,
  TextInputType keyboardType = TextInputType.text,
  required ValueChanged<String> onChanged,
}) =>
    TextField(
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF5F6F9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );

Widget _loadingBox() => Container(
      height: 48,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );

class _PurchaseItemForm {
  int? product;
  String? unit;
  int? qty;
}
