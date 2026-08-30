import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/constants/helper.dart';
import 'package:frontend_roti/models/payment.dart';
import 'package:frontend_roti/services/payment/paymentService.dart';
import 'package:frontend_roti/services/auth/userService.dart';
import 'package:frontend_roti/services/products/productServices.dart';
import 'package:frontend_roti/models/product.dart';

class PaymentDetailScreen extends StatefulWidget {
  final int paymentId;

  const PaymentDetailScreen({super.key, required this.paymentId});

  @override
  State<PaymentDetailScreen> createState() => _PaymentDetailScreenState();
}

class _PaymentDetailScreenState extends State<PaymentDetailScreen> {
  Payment? payment;

  bool isAdmin = false;
  bool loadingUser = true;
  bool loadingPayment = true;

  @override
  void initState() {
    super.initState();
    _loadMe();
    _loadPayment();
  }

  /// ================= LOAD USER =================
  Future<void> _loadMe() async {
    final me = await UserService.getMe();

    if (!mounted) return;

    setState(() {
      isAdmin = me?['is_staff'] == true;
      loadingUser = false;
    });
  }

  /// ================= LOAD PAYMENT =================
  Future<void> _loadPayment() async {
    try {
      final result = await PaymentService.getPaymentDetail(widget.paymentId);

      if (!mounted) return;

      setState(() {
        payment = result;
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      if (mounted) {
        setState(() => loadingPayment = false);
      }
    }
  }

  /// ================= REFRESH =================
  Future<void> _refreshPayment() async {
    setState(() {
      payment = null;
      loadingPayment = true;
    });

    await _loadPayment();
  }

  /// ================= DELETE =================
  Future<void> _deletePaymentItem(PaymentItem item) async {
    try {
      await PaymentService.deletePaymentItem(item.id);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Item berhasil dihapus")));

      await _refreshPayment();
    } catch (e) {
      if (!mounted) return;

      final message = e.toString().replaceFirst("Exception: ", "");

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (payment == null) {
      return const Scaffold(body: Center(child: Text("Data tidak ditemukan")));
    }
    final currency = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final dateFormat = DateFormat('dd MMM yyyy');
    final data = payment!;

    final totalReturBs = data.orderPickingTotal - data.totalOrder;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
        title: const Text("Detail Pembayaran"),
      ),

      /// ================= BODY =================
      body: loadingUser || loadingPayment
          ? const Center(child: CircularProgressIndicator())
          : payment == null
          ? const Center(child: Text("Data tidak ditemukan"))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                /// ===== DETAIL =====
                _sectionCard(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow("Sales", data.userName),
                      _infoRow("Email", data.userEmail),
                      _infoRow("Order Picking", "#${data.orderPicking}"),
                      _infoRow("Tanggal", dateFormat.format(data.paymentDate)),
                      _infoRow("Status", data.status),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ===== SUMMARY =====
                _sectionCard(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _infoRow(
                        "Total Order",
                        currency.format(data.orderPickingTotal),
                      ),
                      _infoRow("Total Retur/Bs", currency.format(totalReturBs)),
                      _infoRow("Total Bayar", currency.format(data.totalOrder)),
                      _infoRow(
                        "Total Dibayar",
                        currency.format(data.totalPaid),
                      ),
                      _infoRow(
                        "Sisa Pembayaran",
                        currency.format(data.remainingAmount),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                /// ===== ITEMS =====
                _sectionCard(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Daftar Item",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (data.items.isEmpty)
                        _emptyItemState()
                      else
                        Column(
                          children: data.items
                              .map((item) => _itemCard(item, currency))
                              .toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),

      /// ================= BOTTOM BAR (ADMIN ONLY) =================
      bottomNavigationBar: payment != null
          ? _BottomBar(
              payment: data,
              onRefresh: _refreshPayment,
              isAdmin: isAdmin,
            )
          : null,
    );
  }

  /// ================= UI HELPERS =================

  Widget _sectionCard(Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: child,
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyItemState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: const [
          Icon(Icons.inventory_2_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text("Belum ada item", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _itemCard(PaymentItem item, NumberFormat currency) {
    final isRetur = item.refundType.toLowerCase() == "retur";

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= PRODUCT =================
          Text(
            item.productName,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 6),

          /// ================= QTY & TOTAL =================
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${item.qty} ${item.unit}",
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                currency.format(item.total),
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          /// ================= PRICE =================
          Text(
            currency.format(item.price),
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 8),

          /// ================= REFUND TYPE =================
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isRetur
                  ? Colors.red.withOpacity(0.1)
                  : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              item.refundType.toUpperCase(),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isRetur ? Colors.red : Colors.orange,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// ================= DELETE BUTTON =================
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: BorderSide(color: Colors.red.shade300),
                minimumSize: const Size(double.infinity, 42),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                _showDeleteConfirmation(item);
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text(
                "Hapus Item",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(PaymentItem item) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Hapus Item?",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Apakah kamu yakin ingin menghapus "${item.productName}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () async {
                Navigator.pop(dialogContext);

                await _deletePaymentItem(item);
              },
              child: const Text(
                "Hapus",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BottomBar extends StatelessWidget {
  final Payment payment;
  final VoidCallback onRefresh;
  final bool isAdmin;

  const _BottomBar({
    required this.isAdmin,
    required this.payment,
    required this.onRefresh,
  });

  static const primaryColor = Color(0xFFFF7643);

  bool get isLunas => payment.status.toLowerCase() == "lunas";

  @override
  Widget build(BuildContext context) {
    /// Jika sudah lunas → tidak tampil apa-apa
    if (isLunas) return const SizedBox.shrink();

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ================= EDIT PAYMENT =================
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFECDF),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: () {
                showAddItemModal(
                  context: context,
                  payment: payment,
                  onSuccess: onRefresh,
                );
              },
              icon: const Icon(Icons.add, color: primaryColor),
              label: const Text(
                "Tambah Retur",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),

            if (isAdmin && payment.totalPaid == 0) ...[
              const SizedBox(height: 12),

              /// ================= PAYMENT =================
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  showPaymentModal(
                    context: context,
                    payment: payment,
                    onSuccess: onRefresh,
                  );
                },
                icon: const Icon(Icons.payments, color: Colors.white),
                label: const Text(
                  "Tambah Pembayaran",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],

            /// ================= REPAYMENT (CICILAN) =================
            if (isAdmin &&
                payment.totalPaid > 0 &&
                payment.remainingAmount < payment.totalOrder) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  side: const BorderSide(color: primaryColor),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                onPressed: () {
                  showRepaymentModal(
                    context: context,
                    payment: payment,
                    onSuccess: onRefresh,
                  );
                },
                icon: const Icon(Icons.history, color: primaryColor),
                label: const Text(
                  "Tambah Cicilan",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

void showPaymentModal({
  required BuildContext context,
  required Payment payment,
  required VoidCallback onSuccess,
}) {
  final parentContext = context; // 🔥 penting
  final totalController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Tambah Pembayaran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Jumlah Pembayaran",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      minimumSize: const Size(double.infinity, 48),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final totalPaid = int.tryParse(
                              totalController.text,
                            );

                            if (totalPaid == null || totalPaid <= 0) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Jumlah pembayaran tidak valid",
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            try {
                              await PaymentService.submitRepayment(
                                paymentId: payment.id,
                                paymentDate: selectedDate,
                                amount: totalPaid,
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Pembayaran berhasil disimpan"),
                                ),
                              );

                              onSuccess();
                            } catch (e) {
                              Navigator.pop(
                                context,
                              ); // 🔥 TUTUP MODAL SAAT ERROR

                              String message = e.toString().replaceFirst(
                                "Exception: ",
                                "",
                              );

                              ScaffoldMessenger.of(
                                parentContext,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Simpan Pembayaran",
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showRepaymentModal({
  required BuildContext context,
  required Payment payment,
  required VoidCallback onSuccess,
}) {
  final parentContext = context;
  final totalController = TextEditingController();
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Cicil Pembayaran",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),

                /// DATE
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      setState(() => selectedDate = picked);
                    }
                  },
                  icon: const Icon(Icons.date_range),
                  label: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                ),

                const SizedBox(height: 12),

                /// INPUT
                TextField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: "Jumlah Pembayaran",
                    hintText: "Contoh: 42000",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// BUTTON
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final amount = int.tryParse(totalController.text);

                            if (amount == null || amount <= 0) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "Jumlah pembayaran tidak valid",
                                  ),
                                ),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            try {
                              await PaymentService.submitRepayment(
                                paymentId: payment.id,
                                paymentDate: selectedDate,
                                amount: amount,
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Pembayaran berhasil disimpan"),
                                ),
                              );

                              onSuccess();
                            } catch (e) {
                              Navigator.pop(
                                context,
                              ); // 🔥 TUTUP MODAL SAAT ERROR
                              String message = e.toString().replaceFirst(
                                "Exception: ",
                                "",
                              );

                              ScaffoldMessenger.of(
                                parentContext,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Simpan Pembayaran",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

void showAddItemModal({
  required BuildContext context,
  required Payment payment,
  required VoidCallback onSuccess,
}) {
  final parentContext = context;

  final qtyController = TextEditingController();

  String selectedUnit = PRODUCT_TYPE.first;
  String refundType = ITEM_TYPE.first;
  String store = STORE_TYPE.first;

  List<Product> products = [];
  Product? selectedProduct;

  bool isLoading = false;
  bool isLoadingProduct = true;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          /// ================= LOAD PRODUCT =================
          Future<void> loadProducts() async {
            try {
              final result = await ProductService.getProductsDropdown();

              setState(() {
                products = result;
                isLoadingProduct = false;

                if (products.isNotEmpty) {
                  selectedProduct = products.first;
                }
              });
            } catch (e) {
              setState(() => isLoadingProduct = false);

              ScaffoldMessenger.of(parentContext).showSnackBar(
                const SnackBar(content: Text("Gagal load produk")),
              );

              Navigator.pop(context); // 🔥 tutup modal kalau gagal
            }
          }

          /// trigger load sekali
          if (isLoadingProduct) {
            loadProducts();
          }

          return Padding(
            padding: EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Icon(Icons.drag_handle, color: Colors.grey),
                ),
                const SizedBox(height: 8),

                const Text(
                  "Tambah Item",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),

                const SizedBox(height: 16),

                /// ================= PRODUCT =================
                isLoadingProduct
                    ? const Center(child: CircularProgressIndicator())
                    : DropdownButtonFormField<Product>(
                        dropdownColor: Colors.white,
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Colors.black,
                        ),
                        value: products.contains(selectedProduct)
                            ? selectedProduct
                            : null,
                        items: products
                            .map(
                              (p) => DropdownMenuItem(
                                value: p,
                                child: Text(
                                  p.name,
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            )
                            .toList(),
                        onChanged: (val) {
                          setState(() {
                            selectedProduct = val;
                          });
                        },
                        decoration: InputDecoration(
                          labelText: "Produk",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                const SizedBox(height: 12),

                /// ================= QTY =================
                TextField(
                  controller: qtyController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    labelText: "Qty",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ================= UNIT =================
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  value: PRODUCT_TYPE.contains(selectedUnit)
                      ? selectedUnit
                      : null,
                  items: PRODUCT_TYPE
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => selectedUnit = val!),
                  decoration: InputDecoration(
                    labelText: "Unit",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ================= REFUND TYPE =================
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  value: ITEM_TYPE.contains(refundType) ? refundType : null,
                  items: ITEM_TYPE
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => refundType = val!),
                  decoration: InputDecoration(
                    labelText: "Refund Type",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                /// ================= STORE =================
                DropdownButtonFormField<String>(
                  dropdownColor: Colors.white,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.black,
                  ),
                  value: STORE_TYPE.contains(store) ? store : null,
                  items: STORE_TYPE
                      .map(
                        (e) => DropdownMenuItem(
                          value: e,
                          child: Text(
                            e,
                            style: const TextStyle(color: Colors.black),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => store = val!),
                  decoration: InputDecoration(
                    labelText: "Store",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// ================= BUTTON =================
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: isLoading
                        ? null
                        : () async {
                            final qty = int.tryParse(qtyController.text);

                            if (selectedProduct == null) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Produk belum dipilih"),
                                ),
                              );
                              return;
                            }

                            if (qty == null || qty <= 0) {
                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Qty tidak valid"),
                                ),
                              );
                              return;
                            }

                            setState(() => isLoading = true);

                            try {
                              await PaymentService.createPaymentItem(
                                paymentId: payment.id,
                                productId: selectedProduct!.id,
                                unit: selectedUnit,
                                refundType: refundType,
                                qty: qty,
                                store: store,
                              );

                              Navigator.pop(context);

                              ScaffoldMessenger.of(parentContext).showSnackBar(
                                const SnackBar(
                                  content: Text("Item berhasil ditambahkan"),
                                ),
                              );

                              onSuccess();
                            } catch (e) {
                              Navigator.pop(context); // 🔥 auto close

                              String message = e.toString().replaceFirst(
                                "Exception: ",
                                "",
                              );

                              ScaffoldMessenger.of(
                                parentContext,
                              ).showSnackBar(SnackBar(content: Text(message)));
                            } finally {
                              setState(() => isLoading = false);
                            }
                          },
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            "Simpan Item",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
