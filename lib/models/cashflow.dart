class CashflowResponse {
  final bool status;
  final String version;
  final CashflowData data;

  CashflowResponse({
    required this.status,
    required this.version,
    required this.data,
  });

  factory CashflowResponse.fromJson(Map<String, dynamic> json) {
    return CashflowResponse(
      status: json['status'],
      version: json['version'],
      data: CashflowData.fromJson(json['data']),
    );
  }
}

class CashflowData {
  final int debit;
  final int kredit;
  final int revenue;

  CashflowData({
    required this.debit,
    required this.kredit,
    required this.revenue,
  });

  factory CashflowData.fromJson(Map<String, dynamic> json) {
    return CashflowData(
      debit: int.tryParse(json['debit'].toString()) ?? 0,
      kredit: int.tryParse(json['kredit'].toString()) ?? 0,
      revenue: int.tryParse(json['revenue'].toString()) ?? 0,
    );
  }
}