import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/services/auth/login.dart';

class StockService {
  static final String baseUrl = dotenv.get("BASE_URL");

  static Future<Map<String, dynamic>> getStockMovement({
    String? url,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final token = await LoginService.getToken();

    Uri uri;

    if (url != null) {
      uri = Uri.parse(url);
    } else {
      final queryParams = {
        if (startDate != null)
          "start_date": DateFormat('yyyy-MM-dd').format(startDate),
        if (endDate != null)
          "end_date": DateFormat('yyyy-MM-dd').format(endDate),
      };

      uri = Uri.parse("$baseUrl/api/report/stock/movement/")
          .replace(queryParameters: queryParams);
    }

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return {
        "results": body['data']['results'],
        "next": body['data']['next'],
      };
    } else {
      throw Exception("Gagal fetch stock movement");
    }
  }
}
