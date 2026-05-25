import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/constants/helper.dart';
import 'package:frontend_roti/services/products/productServices.dart';

const double vSpace = 14;
const double sectionSpace = 22;

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();

  static final String imagePrefix = dotenv.get("IMAGE_PREFIX");

  final nameController = TextEditingController();
  final imageIdController = TextEditingController();
  final stockQtyController = TextEditingController();

  String? productType;
  String? stockUnit;

  List<Map<String, dynamic>> unitList = [];
  List<Map<String, dynamic>> priceList = [];

  @override
  void initState() {
    super.initState();
    _addUnitField();
    _addPriceField();
  }

  void _addUnitField() {
    unitList.add({"unit": null, "multiplier": TextEditingController()});
    setState(() {});
  }

  void _addPriceField() {
    priceList.add({
      "unit": null,
      "qty": TextEditingController(),
      "price": TextEditingController(),
      "typePrice": null,
    });
    setState(() {});
  }

  void _removeUnit(int i) {
    unitList[i]["multiplier"].dispose();
    unitList.removeAt(i);
    setState(() {});
  }

  void _removePrice(int i) {
    priceList[i]["qty"].dispose();
    priceList[i]["price"].dispose();
    priceList.removeAt(i);
    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final payload = {
      "name": nameController.text,
      "image": "$imagePrefix${imageIdController.text}",
      "productType": productType,
      "units": unitList
          .map(
            (u) => {
              "unit": u["unit"],
              "multiplier": int.parse(u["multiplier"].text),
            },
          )
          .toList(),
      "initial_stock": {
        "qty": int.parse(stockQtyController.text),
        "unit": stockUnit,
      },
      "prices": priceList
          .map(
            (p) => {
              "unit": p["unit"],
              "qty": int.parse(p["qty"].text),
              "price": int.parse(p["price"].text),
              "typePrice": p["typePrice"],
            },
          )
          .toList(),
    };

    try {
      await ProductService.createProduct(payload);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk berhasil ditambahkan"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    imageIdController.dispose();
    stockQtyController.dispose();
    for (var u in unitList) {
      u["multiplier"].dispose();
    }
    for (var p in priceList) {
      p["qty"].dispose();
      p["price"].dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Add Product"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                _input(
                  "Product Name",
                  nameController,
                  hint: "Masukkan nama produk",
                ),
                const SizedBox(height: vSpace),
                DropdownButtonFormField<String>(
                  value: productType,
                  dropdownColor: Colors.white,
                  hint: const Text(
                    "Tipe Produk",
                    style: TextStyle(color: Colors.black),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  decoration: _decoration(hint: "Pilih tipe produk"),
                  items: PRODUCT_TYPE
                      .map(
                        (e) => DropdownMenuItem<String>(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => productType = v),
                  validator: (v) => v == null ? "Pilih product type" : null,
                ),
                const SizedBox(height: sectionSpace),
                _imageInput(),
                const SizedBox(height: sectionSpace),
                _sectionHeader("Units", _addUnitField),
                const SizedBox(height: 8),
                ...List.generate(unitList.length, _unitCard),
                const SizedBox(height: sectionSpace),
                _input(
                  "Initial Stock Qty",
                  stockQtyController,
                  keyboardType: TextInputType.number,
                  hint: "Contoh: 100",
                ),
                const SizedBox(height: vSpace),
                DropdownButtonFormField<String>(
                  value: stockUnit,
                  dropdownColor: Colors.white,
                  hint: const Text(
                    "Unit Stock",
                    style: TextStyle(color: Colors.black),
                  ),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  decoration: _decoration(hint: "Pilih unit stock"),
                  items: unitList
                      .where((u) => u["unit"] != null)
                      .map(
                        (u) => DropdownMenuItem<String>(
                          value: u["unit"],
                          child: Text(
                            u["unit"],
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => stockUnit = v),
                  validator: (v) => v == null ? "Pilih unit stock" : null,
                ),
                const SizedBox(height: sectionSpace),
                _sectionHeader("Product Prices", _addPriceField),
                const SizedBox(height: 8),
                ...List.generate(priceList.length, _priceCard),
                const SizedBox(height: 30),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Simpan",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= UI COMPONENT =================

  Widget _sectionHeader(String title, VoidCallback onAdd) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        TextButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add, color: Colors.indigo),
          label: const Text("Add", style: TextStyle(color: Colors.indigo)),
        ),
      ],
    );
  }

  Widget _unitCard(int index) {
    return _card(
      Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: unitList[index]["unit"],
              dropdownColor: Colors.white,
              hint: const Text("Unit", style: TextStyle(color: Colors.black)),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.black,
              ),
              decoration: _decoration(hint: "Unit"),
              items: PRODUCT_TYPE
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => unitList[index]["unit"] = v),
              validator: (v) => v == null ? "Pilih unit" : null,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _input(
              "Multiplier",
              unitList[index]["multiplier"],
              keyboardType: TextInputType.number,
              hint: "Contoh: 12",
            ),
          ),
          if (unitList.length > 1)
            IconButton(
              onPressed: () => _removeUnit(index),
              icon: const Icon(Icons.delete, color: Colors.red),
            ),
        ],
      ),
    );
  }

  Widget _priceCard(int index) {
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// UNIT
          DropdownButtonFormField<String>(
            value: priceList[index]["unit"],
            dropdownColor: Colors.white,
            decoration: _decoration(hint: "Unit"),
            hint: const Text("Unit", style: TextStyle(color: Colors.black)),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black,
            ),
            items: unitList
                .where((u) => u["unit"] != null)
                .map(
                  (u) => DropdownMenuItem<String>(
                    value: u["unit"],
                    child: Text(
                      u["unit"],
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => priceList[index]["unit"] = v),
            validator: (v) => v == null ? "Pilih unit" : null,
          ),

          const SizedBox(height: vSpace),

          /// QTY
          _input(
            "Qty",
            priceList[index]["qty"],
            keyboardType: TextInputType.number,
            hint: "Minimal pembelian",
          ),

          const SizedBox(height: vSpace),

          /// PRICE
          _input(
            "Price",
            priceList[index]["price"],
            keyboardType: TextInputType.number,
            hint: "Harga",
          ),

          const SizedBox(height: vSpace),

          /// TYPE PRICE (INI YANG HILANG)
          DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: priceList[index]["typePrice"],
            hint: const Text(
              "Type Price",
              style: TextStyle(color: Colors.black),
            ),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.black,
            ),
            decoration: _decoration(hint: "Type Price"),
            items: PRICE_TYPE
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e, style: const TextStyle(color: Colors.black))))
                .toList(),
            onChanged: (v) => setState(() => priceList[index]["typePrice"] = v),
            validator: (v) => v == null ? "Pilih type price" : null,
          ),

          if (priceList.length > 1)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _removePrice(index),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  "Remove",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _card(Widget child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _input(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          style: const TextStyle(color: Colors.black),
          controller: controller,
          keyboardType: keyboardType,
          validator: (v) =>
              v == null || v.isEmpty ? "$label wajib diisi" : null,
          decoration: _decoration(hint: hint ?? label),
        ),
      ],
    );
  }

  Widget _imageInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Image (Google Drive)",
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  "https://drive.google.com/uc?export=download&id=",
                  style: TextStyle(fontSize: 12, color: Color(0xFF757575)),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 2,
              child: TextFormField(
                style: const TextStyle(color: Colors.black),
                controller: imageIdController,
                validator: (v) =>
                    v == null || v.isEmpty ? "Image ID wajib diisi" : null,
                decoration: _decoration(hint: "Image ID"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  InputDecoration _decoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F6F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}
