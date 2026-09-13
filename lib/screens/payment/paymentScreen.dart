import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/screens/payment/paymentDetailScreen.dart';
import 'package:frontend_roti/services/payment/paymentService.dart';
import 'package:frontend_roti/models/payment.dart';
import 'package:frontend_roti/services/auth/userService.dart';

class PaymentListScreen extends StatefulWidget {
  const PaymentListScreen({super.key});

  @override
  State<PaymentListScreen> createState() => _PaymentListScreenState();
}

class _PaymentListScreenState extends State<PaymentListScreen> {
  final ScrollController _scrollController = ScrollController();

  final TextEditingController _searchController = TextEditingController();

  String searchQuery = "";

  List<Payment> payments = [];
  String? nextPageUrl;

  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;

  List<dynamic> users = [];
  bool isLoadingUsers = false;
  String? selectedUserEmail;

  @override
  void initState() {
    super.initState();
    fetchPayments();
    fetchUsers();

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
      final search = selectedUserEmail ?? searchQuery;
      final data = await PaymentService.getPayments(
        url: url,
        search: url == null ? search : "",
      );

      nextPageUrl = data['next'];

      final fetched = (data['results'] as List)
          .map((e) => Payment.fromJson(e))
          .toList();

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

  Future<void> fetchUsers() async {
    setState(() {
      isLoadingUsers = true;
    });

    try {
      final data = await UserService.getUsers();

      setState(() {
        users = data;
      });
    } catch (e) {
      // optional: jangan ganggu list payment kalau user gagal dimuat
    } finally {
      setState(() {
        isLoadingUsers = false;
      });
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
        child: Column(
          children: [
            _userList(),
            _searchBar(),
            Expanded(child: _buildBody(currency, dateFormat)),
          ],
        ),
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
            return _paymentCard(payments[index], currency, dateFormat);
          }

          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.black),
        onSubmitted: (value) {
          setState(() {
            searchQuery = value.trim();
            payments.clear();
            nextPageUrl = null;
          });

          fetchPayments(url: null);
        },
        decoration: InputDecoration(
          hintText: "Cari email atau rute...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      searchQuery = "";
                      payments.clear();
                      nextPageUrl = null;
                    });

                    fetchPayments(url: null);
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFFF5F6F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _userList() {
    if (isLoadingUsers) {
      return const SizedBox(
        height: 70,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      height: 82,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        itemCount: users.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          // Semua user
          if (index == 0) {
            final selected = selectedUserEmail == null;

            return _userItem(name: "Semua", email: null, selected: selected);
          }

          final user = users[index - 1];

          final email = user["email"]?.toString() ?? "";
          final username = user["username"]?.toString() ?? email;

          return _userItem(
            name: username,
            email: email,
            selected: selectedUserEmail == email,
          );
        },
      ),
    );
  }

  Widget _userItem({
    required String name,
    required String? email,
    required bool selected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedUserEmail = email;
          searchQuery = "";
          _searchController.clear();
          payments.clear();
          nextPageUrl = null;
        });

        fetchPayments(url: null);
      },
      child: Container(
        width: 110,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF7643) : const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.person,
              size: 20,
              color: selected ? Colors.white : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
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
            builder: (_) => PaymentDetailScreen(paymentId: payment.id),
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
                    color: Colors.black,
                  ),
                ),
                Icon(payment.statusIcon, color: payment.statusColor, size: 16),
              ],
            ),

            const SizedBox(height: 4),

            Text(payment.userEmail, style: const TextStyle(color: Colors.grey)),

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
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
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
            const Icon(Icons.receipt_long, size: 72, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              "Belum ada pembayaran",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
            const Icon(Icons.error_outline, size: 72, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              "Terjadi kesalahan",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
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
