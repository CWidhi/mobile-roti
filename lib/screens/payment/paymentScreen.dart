import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/screens/payment/paymentDetailScreen.dart';
import 'package:frontend_roti/services/payment/paymentService.dart';
import 'package:frontend_roti/models/payment.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final ScrollController _scrollController = ScrollController();

  List<Payment> payments = [];
  String? nextPageUrl;

  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchPayments();

    _scrollController.addListener(() {
      if (!isRefreshing &&
          !isLoading &&
          nextPageUrl != null &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        fetchPayments(url: nextPageUrl);
      }
    });
  }

  /// ================= FETCH =================
  Future<void> fetchPayments({String? url}) async {
    setState(() {
      isLoading = true;
      if (url == null) errorMessage = null;
    });

    try {
      final data = await PaymentService.getPayments(url: url);

      nextPageUrl = data['next'];

      final fetched =
          (data['results'] as List).map((e) => Payment.fromJson(e)).toList();

      setState(() {
        if (url == null) payments.clear();
        payments.addAll(fetched);
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString().replaceAll("Exception: ", "");
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ================= REFRESH =================
  Future<void> _onRefresh() async {
    isRefreshing = true;
    nextPageUrl = null;

    await fetchPayments(url: null);

    isRefreshing = false;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// ================= UI =================
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
        title: const Text("Pembayaran"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: _buildBody(currency, dateFormat),
      ),
    );
  }

  /// ================= BODY STATE =================
  Widget _buildBody(NumberFormat currency, DateFormat dateFormat) {
    if (isLoading && payments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (errorMessage != null && payments.isEmpty) {
      return _errorState();
    }

    if (payments.isEmpty) {
      return _emptyState();
    }

    return RefreshIndicator(
      color: const Color(0xFFFF7643),
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount:
            payments.length + ((nextPageUrl != null || isLoading) ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index < payments.length) {
            return _paymentCard(
              payments[index],
              currency,
              dateFormat,
            );
          }

          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  /// ================= CARD =================
  Widget _paymentCard(
    Payment payment,
    NumberFormat currency,
    DateFormat dateFormat,
  ) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () {
        /// 👉 INI TRIGGER BUTTON-NYA
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentDetailScreen(
              paymentId: payment.id,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  payment.userName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(
                  payment.statusIcon,
                  color: payment.statusColor,
                  size: 16,
                ),
              ],
            ),

            const SizedBox(height: 4),

            Text(
              payment.userEmail,
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 8),

            Text(
              "Order Picking #${payment.orderPicking}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 6),

            Text(
              "Tanggal: ${dateFormat.format(payment.paymentDate)}",
              style: const TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  currency.format(payment.totalOrder),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFF7643),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// ================= EMPTY =================
  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.receipt_long,
              size: 72,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            const Text(
              "Belum ada pembayaran",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Data pembayaran akan muncul setelah transaksi dilakukan",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7643),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => fetchPayments(url: null),
              child: const Text(
                "Muat ulang",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= ERROR =================
  Widget _errorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 72,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 16),
            const Text(
              "Terjadi kesalahan",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ?? "Gagal memuat data",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7643),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => fetchPayments(url: null),
              child: const Text("Coba lagi"),
            ),
          ],
        ),
      ),
    );
  }
}
