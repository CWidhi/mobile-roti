import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:frontend_roti/services/auth/login.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class StoreService {
  static final String baseUrl = dotenv.get("BASE_URL");

  /// CREATE STORE BY ROUTE ID
  static Future<void> createStore({
    required int routeId,
    required String name,
    required String address,
    required String phone,
    required String coordinate,
    required String storeType,
  }) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/api/store/$routeId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "address": address,
        "phone": phone,
        "coordinate": coordinate,
        "storeType": storeType,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(
        body["message"] ?? "Gagal menambahkan store",
      );
    }
  }

  static Future<Map<String, dynamic>> getStoreDetail({
    required int routeId,
    required int storeId,
  }) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/store/$routeId/$storeId"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      if (body["status"] == true) {
        return body["data"];
      } else {
        throw Exception(body["message"] ?? "Gagal mengambil detail store");
      }
    } else {
      throw Exception("Gagal mengambil detail store (${response.statusCode})");
    }
  }

  static Future<void> updateStore({
    required int routeId,
    required int storeId,
    required Map<String, dynamic> data,
  }) async {
    final token = await LoginService.getToken();

    final url = Uri.parse("$baseUrl/api/store/$routeId/$storeId/");

    final response = await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(data),
    );

    if (response.statusCode != 200) {
      final res = jsonDecode(response.body);
      throw Exception(res["message"] ?? "Gagal update store");
    }
  }
}
