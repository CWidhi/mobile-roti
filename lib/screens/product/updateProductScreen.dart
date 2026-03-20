import 'package:flutter/material.dart';
import 'package:frontend_roti/services/products/productServices.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class UpdateProductScreen extends StatefulWidget {
  final int productId; // ID produk yang mau diupdate
  final String name;
  final String imageId;

  const UpdateProductScreen({
    super.key,
    required this.productId,
    required this.name,
    required this.imageId,
  });

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imageIdController;

  static final String imagePrefix = dotenv.get("IMAGE_PREFIX");

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _imageIdController = TextEditingController(text: widget.imageId);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageIdController.dispose();
    super.dispose();
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

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    String imageInput = _imageIdController.text.trim();

    final payload = {
      "name": _nameController.text.trim(),
      "image": imageInput.startsWith("http")
          ? imageInput 
          : "$imagePrefix$imageInput",
    };

    try {
      await ProductService.updateProduct(widget.productId, payload);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Produk berhasil diperbarui"),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true); // bisa dikembalikan flag success
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Update Product"),
        backgroundColor: const Color(0xFFFF7643),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Product Name
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Product Name",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _nameController,
                    validator: (v) =>
                        v == null || v.isEmpty ? "Nama wajib diisi" : null,
                    decoration: _decoration(hint: "Masukkan nama produk"),
                  ),
                ],
              ),
              const SizedBox(height: 22),

              // Image ID Input
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Product Image (Google Drive)",
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5F6F9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            "https://drive.google.com/uc?export=download&id=",
                            style: TextStyle(
                                fontSize: 12, color: Color(0xFF757575)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _imageIdController,
                          validator: (v) => v == null || v.isEmpty
                              ? "Image ID wajib diisi"
                              : null,
                          decoration: _decoration(hint: "Image ID"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // Save Button
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _updateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7643),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Update Product",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white),
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
