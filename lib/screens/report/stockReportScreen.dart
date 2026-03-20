import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:frontend_roti/models/stockMovement.dart';
import 'package:frontend_roti/services/report/stockMovementService.dart';

class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({super.key});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  final ScrollController _scrollController = ScrollController();

  List<StockMovement> movements = [];
  String? nextPageUrl;

  bool isLoading = false;
  bool isRefreshing = false;

  DateTime? startDate;
  DateTime? endDate;

  @override
  void initState() {
    super.initState();

    /// DEFAULT BULAN INI
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = now;

    fetchMovements();

    _scrollController.addListener(() {
      if (!isRefreshing &&
          !isLoading &&
          nextPageUrl != null &&
          _scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200) {
        fetchMovements(url: nextPageUrl);
      }
    });
  }

  /// ================= FETCH =================

  Future<void> fetchMovements({String? url}) async {
    setState(() => isLoading = true);

    try {
      final data = await StockService.getStockMovement(
        url: url,
        startDate: startDate,
        endDate: endDate,
      );

      nextPageUrl = data['next'];

      final List<StockMovement> fetched = (data['results'] as List)
          .map((e) => StockMovement.fromJson(e))
          .toList();

      setState(() {
        if (url == null) movements.clear();
        movements.addAll(fetched);
      });
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// ================= REFRESH =================

  Future<void> _onRefresh() async {
    isRefreshing = true;
    nextPageUrl = null;
    await fetchMovements(url: null);
    isRefreshing = false;
  }

  /// ================= DATE PICKER =================

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          startDate = picked;
        } else {
          endDate = picked;
        }
      });
    }
  }

  Widget _dateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          date != null ? DateFormat('dd MMM yyyy').format(date) : label,
          style: TextStyle(
            color: date != null ? Colors.black : Colors.grey,
          ),
        ),
      ),
    );
  }

  /// ================= UI =================

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Movement"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// FILTER DATE
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: _dateField(
                      label: "Start Date",
                      date: startDate,
                      onTap: () => _pickDate(isStart: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _dateField(
                      label: "End Date",
                      date: endDate,
                      onTap: () => _pickDate(isStart: false),
                    ),
                  ),
                  const SizedBox(width: 10),

                  /// BUTTON FILTER
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFF7643),
                      padding: const EdgeInsets.all(14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      fetchMovements(url: null);
                    },
                    child: const Icon(Icons.search, color: Colors.white),
                  )
                ],
              ),
            ),

            /// LIST
            Expanded(
              child: RefreshIndicator(
                color: const Color(0xFFFF7643),
                onRefresh: _onRefresh,
                child: ListView.separated(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: movements.length +
                      ((nextPageUrl != null || isLoading) ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    if (index < movements.length) {
                      return _movementCard(
                        movements[index],
                        dateFormat,
                      );
                    }

                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ================= CARD =================

  Widget _movementCard(
    StockMovement movement,
    DateFormat dateFormat,
  ) {
    final isIn = movement.movementType == "IN";

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PRODUCT
          Text(
            movement.product.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          /// TYPE
          Row(
            children: [
              Icon(
                isIn ? Icons.arrow_downward : Icons.arrow_upward,
                color: isIn ? Colors.green : Colors.red,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                isIn ? "Stock Masuk" : "Stock Keluar",
                style: TextStyle(
                  color: isIn ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          /// QTY
          Text(
            "Qty: ${movement.qty} ${movement.unit}",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 6),

          /// SUPPLIER / USER
          Text(
            movement.supplier?.name ?? movement.user?.firstName ?? "-",
            style: const TextStyle(color: Colors.grey),
          ),

          const SizedBox(height: 6),

          /// NOTES
          Text(
            movement.notes,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
