import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:frontend_roti/services/report/cashflowService.dart';
import 'package:frontend_roti/models/cashflow.dart';
import 'package:frontend_roti/models/cashflowPerDay.dart';

class CashflowScreen extends StatefulWidget {
  const CashflowScreen({super.key});

  @override
  State<CashflowScreen> createState() => _CashflowScreenState();
}

class _CashflowScreenState extends State<CashflowScreen> {
  CashflowData? data;
  CashflowWeeklyData? weeklyData;
  bool isLoading = false;
  DateTime? startDate;
  DateTime? endDate;

  final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);
    endDate = now;
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() => isLoading = true);
    try {
      final results = await Future.wait([
        CashflowService.getCashflow(startDate: startDate, endDate: endDate),
        CashflowService.getCashflowByWeeks(),
      ]);

      setState(() {
        data = results[0] as CashflowData?;
        weeklyData = results[1] as CashflowWeeklyData?;
      });
    } catch (e) {
      debugPrint("Error detail: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cashflow Report"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchAllData,
          color: const Color(0xFFFF7643),
          child: Column(
            children: [
              _buildFilterRow(),
              Expanded(
                child: isLoading && data == null
                    ? const Center(child: CircularProgressIndicator())
                    : (data == null && weeklyData == null)
                    ? _buildEmptyState()
                    : _buildMainContent(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: const [
        SizedBox(height: 100),
        Center(child: Text("Tidak ada data. Tarik ke bawah untuk refresh.")),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(child: _dateField("Start Date", startDate, true)),
          const SizedBox(width: 10),
          Expanded(child: _dateField("End Date", endDate, false)),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF7643),
              padding: const EdgeInsets.all(14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _fetchAllData,
            child: const Icon(Icons.search, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (data != null) ...[
            _cashCard("Debit", currency.format(data!.debit), Colors.red),
            const SizedBox(height: 12),
            _cashCard("Kredit", currency.format(data!.kredit), Colors.green),
            const SizedBox(height: 12),
            _cashCard(
              "Revenue",
              currency.format(data!.revenue),
              const Color(0xFFFF7643),
            ),
          ],
          const SizedBox(height: 24),
          if (weeklyData != null && weeklyData!.daily.isNotEmpty) ...[
            const Text(
              "Cashflow 7 Hari Terakhir",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _weeklyChart(),
          ],
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  Widget _weeklyChart() {
    double maxVal = 0;
    for (var d in weeklyData!.daily) {
      if (d.debit > maxVal) maxVal = d.debit;
      if (d.kredit > maxVal) maxVal = d.kredit;
    }
    final double calculatedMaxY = maxVal == 0 ? 1000 : maxVal * 1.2;

    return Container(
      height: 250,
      width: double.infinity,
      padding: const EdgeInsets.only(right: 16),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: calculatedMaxY,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  currency.format(rod.toY),
                  const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 60,
                getTitlesWidget: (value, meta) {
                  String text = value >= 1000000
                      ? 'Rp ${(value / 1000000).toStringAsFixed(1)}jt'
                      : value >= 1000
                      ? 'Rp ${(value / 1000).toStringAsFixed(0)}rb'
                      : 'Rp ${value.toInt()}';
                  return SideTitleWidget(
                    axisSide: meta.axisSide,
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 8, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  int index = value.toInt();
                  if (index >= 0 && index < weeklyData!.daily.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        DateFormat(
                          'dd/MM',
                        ).format(weeklyData!.daily[index].date),
                        style: const TextStyle(fontSize: 9),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ),
          barGroups: weeklyData!.daily.asMap().entries.map((e) {
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value.debit,
                  color: Colors.red,
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                ),
                BarChartRodData(
                  toY: e.value.kredit,
                  color: Colors.green,
                  width: 8,
                  borderRadius: BorderRadius.circular(2),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _dateField(String label, DateTime? date, bool isStart) {
    return InkWell(
      onTap: () => _pickDate(isStart: isStart),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F9),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          date != null ? DateFormat('dd MMM yyyy').format(date) : label,
          style: const TextStyle(fontSize: 12),
        ),
      ),
    );
  }

  Widget _cashCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null)
      setState(() => isStart ? startDate = picked : endDate = picked);
  }
}
