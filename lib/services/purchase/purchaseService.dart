import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/services/auth/login.dart';
import 'package:frontend_roti/models/purchase.dart';

class PurchaseService {
  static final String baseUrl = dotenv.get("BASE_URL");

  static Future<Map<String, dynamic>> getPurchases({
    String? search,
    String? url,
  }) async {
    final token = await LoginService.getToken();
    Uri uri;

    if (url != null) {
      uri = Uri.parse(url);
    } else {
      uri = Uri.parse("$baseUrl/api/purchase/").replace(
        queryParameters: {
          if (search != null && search.isNotEmpty) "search": search,
        },
      );
    }

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["data"];
    } else {
      throw Exception("Gagal mengambil purchase");
    }
  }

  static Future<Purchase> getPurchaseDetail(int id) async {
    final token = await LoginService.getToken();

    final uri = Uri.parse("$baseUrl/api/purchase/$id/");

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return Purchase.fromJson(jsonBody['data']);
    } else {
      throw Exception("Gagal mengambil detail purchase");
    }
  }

  static Future<void> createPurchase({
    required int supplierId,
    required String purchaseDate,
    String? description,
    int? cashback,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await LoginService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/purchase/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "supplier": supplierId,
        "purchase_date": purchaseDate,
        "description": description,
        "cashback": cashback,
        "items": items,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body["message"] ?? "Gagal menambahkan purchase");
    }
  }

  static Future<void> updatePurchase({
    required int purchaseId,
    required int supplierId,
    required String purchaseDate,
    String? description,
    int? cashback,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await LoginService.getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/api/purchase/$purchaseId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "supplier": supplierId,
        "purchase_date": purchaseDate,
        "description": description ?? "",
        "cashback": cashback ?? 0,
        "items": items,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal update purchase");
    }
  }
}
