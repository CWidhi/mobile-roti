class CashflowPerDay {
  final DateTime date;
  final double debit;
  final double kredit;
  final double revenue;

  CashflowPerDay({
    required this.date,
    required this.debit,
    required this.kredit,
    required this.revenue,
  });

  factory CashflowPerDay.fromJson(Map<String, dynamic> json) => CashflowPerDay(
        date: DateTime.parse(json['date']),
        debit: (json['debit'] as num).toDouble(),
        kredit: (json['kredit'] as num).toDouble(),
        revenue: (json['revenue'] as num).toDouble(),
      );
}

class CashflowWeeklyData {
  final List<CashflowPerDay> daily;

  CashflowWeeklyData({required this.daily});

  factory CashflowWeeklyData.fromJson(Map<String, dynamic> json) => CashflowWeeklyData(
        daily: (json['data'] as List)
            .map((e) => CashflowPerDay.fromJson(e))
            .toList(),
      );
}