import 'package:flutter/material.dart';
import 'package:frontend_roti/services/products/priceService.dart';
import 'package:frontend_roti/constants/helper.dart';

class UpdateProductPriceScreen extends StatefulWidget {
  final int productId;
  final int priceId;

  const UpdateProductPriceScreen({
    super.key,
    required this.productId,
    required this.priceId,
  });

  @override
  State<UpdateProductPriceScreen> createState() =>
      _UpdateProductPriceScreenState();
}

class _UpdateProductPriceScreenState extends State<UpdateProductPriceScreen> {
  final _formKey = GlobalKey<FormState>();

  String? unit;
  String? typePrice;
  final qtyController = TextEditingController();
  final priceController = TextEditingController();

  bool loading = true;
  bool submitting = false;

  static const primaryColor = Color(0xFFFF7643);
  static const bgSoft = Color(0xFFF5F6F9);

  @override
  void initState() {
    super.initState();
    _loadDetail();
  }

  Future<void> _loadDetail() async {
    try {
      final price = await PriceService.getPriceDetail(
        widget.productId,
        widget.priceId,
      );

      if (!mounted) return;

      setState(() {
        unit = price.unit;
        typePrice = price.typePrice;
        qtyController.text = price.qty.toString();
        priceController.text = price.price.toString();
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.redAccent,
        ),
      );
      Navigator.pop(context);
    }
  }

  InputDecoration _decoration(String hint) {
    return InputDecoration(
      hintText: hint,
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

    setState(() => submitting = true);

    try {
      await PriceService.updatePrice(widget.productId, widget.priceId, {
        "unit": unit,
        "qty": int.parse(qtyController.text),
        "price": int.parse(priceController.text),
        "typePrice": typePrice,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Harga berhasil diperbarui"),
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
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgSoft,
      appBar: AppBar(
        title: const Text("Daftar Harga"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// UNIT
                    DropdownButtonFormField<String>(
                      value: unit,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.black,
                      ),
                      items: PRODUCT_TYPE
                          .map(
                            (u) => DropdownMenuItem(
                              value: u,
                              child: Text(
                                u,
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => unit = v,
                      decoration: _decoration("Unit"),
                      validator: (v) => v == null ? "Unit wajib dipilih" : null,
                    ),

                    const SizedBox(height: 14),

                    /// TYPE PRICE
                    DropdownButtonFormField<String>(
                      value: typePrice,
                      dropdownColor: Colors.white,
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Colors.black,
                      ),
                      items: PRICE_TYPE
                          .map(
                            (t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                priceTypeLabel(t),
                                style: const TextStyle(color: Colors.black),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (v) => typePrice = v,
                      decoration: _decoration("Tipe Harga"),
                      validator: (v) =>
                          v == null ? "Tipe harga wajib dipilih" : null,
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
                      decoration: _decoration("Harga"),
                      style: const TextStyle(color: Colors.black),
                      validator: (v) =>
                          v == null || v.isEmpty ? "Harga wajib diisi" : null,
                    ),

                    const SizedBox(height: 30),

                    /// SUBMIT
                    ElevatedButton(
                      onPressed: submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: submitting
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Update Harga",
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
