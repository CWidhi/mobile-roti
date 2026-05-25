import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/models/purchase.dart';
import 'package:frontend_roti/services/purchase/purchaseService.dart';
import 'package:frontend_roti/screens/purchase/purchaseUpdateScreen.dart';

class PurchaseDetailScreen extends StatefulWidget {
  final int purchaseId;

  const PurchaseDetailScreen({
    super.key,
    required this.purchaseId,
  });

  @override
  State<PurchaseDetailScreen> createState() => _PurchaseDetailScreenState();
}

class _PurchaseDetailScreenState extends State<PurchaseDetailScreen> {
  late Future<Purchase> futurePurchase;

  @override
  void initState() {
    super.initState();
    futurePurchase = PurchaseService.getPurchaseDetail(widget.purchaseId);
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Tambah Purchase"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.edit),
            label: const Text("Edit Purchase"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7643),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PurchaseUpdateScreen(
                    purchaseId: widget.purchaseId,
                  ),
                ),
              );

              // reload data setelah edit
              if (result == true) {
                setState(() {
                  futurePurchase =
                      PurchaseService.getPurchaseDetail(widget.purchaseId);
                });
              }
            },
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder<Purchase>(
          future: futurePurchase,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text(snapshot.error.toString()));
            }

            final purchase = snapshot.data!;
            final supplier = purchase.supplier;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// SUPPLIER
                  _sectionTitle("Supplier"),
                  _card([
                    _row("Nama", supplier.name),
                    _row("Alamat", supplier.address),
                    _row("Telepon", supplier.phoneNumber),
                  ]),

                  const SizedBox(height: 16),

                  /// INFO
                  _sectionTitle("Informasi Purchase"),
                  _card([
                    _row(
                      "Tanggal",
                      dateFormat.format(purchase.purchaseDate),
                    ),
                    _row(
                      "Total Item",
                      "${purchase.items.length} item",
                    ),
                  ]),

                  const SizedBox(height: 16),

                  /// ITEMS
                  _sectionTitle("Item"),
                  ...purchase.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F6F9),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.product.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          _row("Unit", item.unit),
                          _row("Qty", item.qty.toString()),
                          _row("Harga", currency.format(item.buyPrice)),
                          const Divider(height: 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              currency.format(item.totalPrice),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFFFF7643),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// INFO
                  _sectionTitle("Keterangan BS"),
                  _card([
                    _row("Deskripsi", purchase.description ?? "-"),
                    const Divider(height: 20),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        currency.format(purchase.cashback ?? 0),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFFFF7643),
                        ),
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  ///  TOTAL
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFECDF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Total Purchase",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          currency.format(purchase.total),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFFF7643),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// ===== helpers =====

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
      ),
    );
  }

  Widget _card(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(color: Colors.black)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, color:Colors.black,),
            ),
          ),
        ],
      ),
    );
  }
}
