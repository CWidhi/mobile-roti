import 'package:flutter/material.dart';
import 'package:frontend_roti/models/rute.dart';
import 'package:frontend_roti/services/rute/ruteService.dart';

class RouteLineFormModal extends StatefulWidget {
  final RouteLine? route; // null = create, ada value = update

  const RouteLineFormModal({
    Key? key,
    this.route,
  }) : super(key: key);

  @override
  State<RouteLineFormModal> createState() => _RouteLineFormModalState();
}

class _RouteLineFormModalState extends State<RouteLineFormModal> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  bool loading = false;

  static const primaryColor = Color(0xFFFF7643);

  @override
  void initState() {
    super.initState();
    if (widget.route != null) {
      nameController.text = widget.route!.name;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      if (widget.route == null) {
        /// CREATE
        await RouteLineService.createRouteLine({
          "name": nameController.text,
        });
      } else {
        /// UPDATE
        await RouteLineService.updateRouteLine(
          widget.route!.id,
          {
            "name": nameController.text,
          },
        );
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.route == null ? "Tambah Rute" : "Edit Rute",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            /// NAME
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: "Nama rute",
                filled: true,
                fillColor: const Color(0xFFF5F6F9),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) =>
                  v == null || v.isEmpty ? "Nama wajib diisi" : null,
            ),

            const SizedBox(height: 24),

            /// SUBMIT
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        widget.route == null ? "Simpan" : "Update",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
