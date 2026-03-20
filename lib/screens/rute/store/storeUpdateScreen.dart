import 'package:flutter/material.dart';
import 'package:frontend_roti/services/rute/storeService.dart';

class UpdateStoreScreen extends StatefulWidget {
  final int routeId;
  final int storeId;

  const UpdateStoreScreen({
    Key? key,
    required this.routeId,
    required this.storeId,
  }) : super(key: key);

  @override
  State<UpdateStoreScreen> createState() => _UpdateStoreScreenState();
}

class _UpdateStoreScreenState extends State<UpdateStoreScreen> {
  static const primaryColor = Color(0xFFFF7643);

  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _coordinateCtrl = TextEditingController();
  String _storeType = "Toko";

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadStore();
  }

  Future<void> _loadStore() async {
    final store = await StoreService.getStoreDetail(
      routeId: widget.routeId,
      storeId: widget.storeId,
    );

    _nameCtrl.text = store["name"] ?? "";
    _addressCtrl.text = store["address"] ?? "";
    _phoneCtrl.text = store["phone"] ?? "";
    _coordinateCtrl.text = store["coordinate"] ?? "";
    _storeType = store["storeType"] ?? "Toko";

    setState(() {});
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final payload = {
      "name": _nameCtrl.text,
      "address": _addressCtrl.text,
      "phone": _phoneCtrl.text,
      "coordinate": _coordinateCtrl.text,
      "storeType": _storeType,
    };

    await StoreService.updateStore(
      routeId: widget.routeId,
      storeId: widget.storeId,
      data: payload,
    );

    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Update Store"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _InputCard(
                label: "Nama Store",
                controller: _nameCtrl,
              ),
              _InputCard(
                label: "Alamat",
                controller: _addressCtrl,
                maxLines: 2,
              ),
              _InputCard(
                label: "No. Telepon",
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),
              _InputCard(
                label: "Koordinat",
                controller: _coordinateCtrl,
              ),

              /// STORE TYPE
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonFormField<String>(
                  value: _storeType,
                  decoration: const InputDecoration(
                    labelText: "Tipe Store",
                    border: InputBorder.none,
                  ),
                  items: const [
                    DropdownMenuItem(value: "Toko", child: Text("Toko")),
                    DropdownMenuItem(value: "Agen", child: Text("Agen")),
                  ],
                  onChanged: (val) {
                    setState(() => _storeType = val!);
                  },
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Perubahan", style: TextStyle(color: Colors.white),),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final int maxLines;
  final TextInputType keyboardType;

  const _InputCard({
    required this.label,
    required this.controller,
    this.maxLines = 1,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: (v) => v == null || v.isEmpty ? "Wajib diisi" : null,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
        ),
      ),
    );
  }
}
