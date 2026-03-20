import 'package:flutter/material.dart';
import 'package:frontend_roti/services/rute/storeService.dart';

class CreateStoreScreen extends StatefulWidget {
  final int routeId;

  const CreateStoreScreen({
    Key? key,
    required this.routeId,
  }) : super(key: key);

  @override
  State<CreateStoreScreen> createState() => _CreateStoreScreenState();
}

class _CreateStoreScreenState extends State<CreateStoreScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final addressController = TextEditingController();
  final phoneController = TextEditingController();
  final coordinateController = TextEditingController();

  String storeType = "Toko";
  bool isLoading = false;

  static const primaryColor = Color(0xFFFF7643);

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      await StoreService.createStore(
        routeId: widget.routeId,
        name: nameController.text,
        address: addressController.text,
        phone: phoneController.text,
        coordinate: coordinateController.text,
        storeType: storeType,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Store berhasil ditambahkan"),
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
      if (mounted) setState(() => isLoading = false);
    }
  }

  InputDecoration _input(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF5F6F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Store"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: nameController,
                decoration: _input("Nama Store"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: addressController,
                decoration: _input("Alamat"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: phoneController,
                decoration: _input("No. Telepon"),
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: coordinateController,
                decoration: _input("Koordinat"),
                validator: (v) =>
                    v == null || v.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: storeType,
                decoration: _input("Tipe Store"),
                items: const [
                  DropdownMenuItem(value: "Toko", child: Text("Toko")),
                  DropdownMenuItem(value: "Pasar", child: Text("Pasar")),
                ],
                onChanged: (v) => setState(() => storeType = v!),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
