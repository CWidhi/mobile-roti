import 'package:flutter/material.dart';
import 'package:frontend_roti/models/supplier.dart';
import 'package:frontend_roti/screens/supplier/supplierUpdateScreen.dart';

class SupplierDetailScreen extends StatelessWidget {
  final Supplier supplier;

  const SupplierDetailScreen({
    super.key,
    required this.supplier,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Detail Supplier"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// ICON HEADER
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFFFECDF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.local_shipping,
                size: 40,
                color: Color(0xFFFF7643),
              ),
            ),

            const SizedBox(height: 20),

            /// NAME
            Text(
              supplier.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 24),

            /// DETAIL CARD
            _infoCard(
              icon: Icons.location_on,
              label: "Alamat",
              value: supplier.address,
            ),
            const SizedBox(height: 12),
            _infoCard(
              icon: Icons.phone,
              label: "No. Telepon",
              value: supplier.phoneNumber,
            ),

            const Spacer(),

            /// EDIT BUTTON
            SizedBox(
              height: 48,
              width: double.infinity,
              child: ElevatedButton.icon(
                label: const Text(
                  "Update Supplier",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7643),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditSupplierScreen(supplier: supplier),
                    ),
                  );

                  if (result == true) {
                    Navigator.pop(context, true); // refresh list
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFFFECDF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFFFF7643)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
