import 'package:flutter/material.dart';
import 'package:frontend_roti/services/products/priceService.dart';
import 'package:frontend_roti/constants/helper.dart';

class CreateProductPriceScreen extends StatefulWidget {
  final int productId;

  const CreateProductPriceScreen({super.key, required this.productId});

  @override
  State<CreateProductPriceScreen> createState() =>
      _CreateProductPriceScreenState();
}

class _CreateProductPriceScreenState extends State<CreateProductPriceScreen> {
  final _formKey = GlobalKey<FormState>();

  String? unit;
  String? typePrice;
  final qtyController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = false;

  static const primaryColor = Color(0xFFFF7643);
  static const bgSoft = Color(0xFFF5F6F9);

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.black),
      filled: true,
      fillColor: bgSoft,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      await PriceService.createProductPrice(
        productId: widget.productId,
        unit: unit!,
        quantity: int.parse(qtyController.text),
        price: int.parse(priceController.text),
        typePrice: typePrice!,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harga berhasil ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context, true); // 🔥 trigger refresh
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        title: const Text("Tambah Harga"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /// UNIT
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: unit,
                icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                hint: const Text(
                  "Unit",
                  style: TextStyle(color: Colors.black),
                ),
                decoration: _decoration(""),
                items: PRODUCT_TYPE
                    .map((u) => DropdownMenuItem(value: u, child: Text(u, style: const TextStyle(color: Colors.black))))
                    .toList(),
                onChanged: (v) => unit = v,
                validator: (v) => v == null ? "Unit wajib dipilih" : null,
              ),

              const SizedBox(height: 14),

              /// TYPE PRICE
              DropdownButtonFormField<String>(
                dropdownColor: Colors.white,
                value: typePrice,
                icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                hint: const Text(
                  "Tipe Harga",
                  style: TextStyle(color: Colors.black),
                ),
                decoration: _decoration(""),
                items: PRICE_TYPE
                    .map(
                      (e) => DropdownMenuItem(
                        value: e,
                        child: Text(priceTypeLabel(e), style: const TextStyle(color: Colors.black)), // 👈 label rapi
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => typePrice = v),
                validator: (v) => v == null ? "Tipe harga wajib dipilih" : null,
              ),

              const SizedBox(height: 14),

              /// QTY
              TextFormField(
                controller: qtyController,
                keyboardType: TextInputType.number,
                decoration: _decoration("Quantity"),
                style: const TextStyle(color: Colors.black),
                validator: (v) =>
                    v == null || v.isEmpty ? "Qty wajib diisi" : null,
              ),

              const SizedBox(height: 14),

              /// PRICE
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.black),
                decoration: _decoration("Harga"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Harga wajib diisi" : null,
              ),

              const SizedBox(height: 30),

              /// SUBMIT
              ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        "Simpan Harga",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
