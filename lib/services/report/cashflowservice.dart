import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/services/auth/login.dart';
import 'package:frontend_roti/models/cashflow.dart';
import 'package:frontend_roti/models/cashflowPerDay.dart';

class CashflowService {
  static final String baseUrl = dotenv.get("BASE_URL");

  static Future<CashflowData> getCashflow({DateTime? startDate, DateTime? endDate}) async {
    final token = await LoginService.getToken();
    final queryParams = {
      if (startDate != null) "start_date": DateFormat('yyyy-MM-dd').format(startDate),
      if (endDate != null) "end_date": DateFormat('yyyy-MM-dd').format(endDate),
    };

    final uri = Uri.parse("$baseUrl/api/report/cashflow/").replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return CashflowResponse.fromJson(body).data;
    } else {
      throw Exception("Gagal mengambil summary cashflow");
    }
  }

  static Future<CashflowWeeklyData> getCashflowByWeeks() async {
    final token = await LoginService.getToken();
    final uri = Uri.parse('$baseUrl/api/report/cashflow/weeks/');

    final response = await http.get(uri, headers: {"Authorization": "Bearer $token"});

    if (response.statusCode == 200) {
      final Map<String, dynamic> body = jsonDecode(response.body);
      return CashflowWeeklyData.fromJson(body);
    } else {
      throw Exception('Gagal mengambil weekly data: ${response.statusCode}');
    }
  }
}