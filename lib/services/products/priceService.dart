import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/models/productPrice.dart';
import 'package:frontend_roti/services/auth/login.dart';

class PriceService {
  static final String baseUrl = dotenv.get("BASE_URL");
  static Future<List<ProductPrice>> getProductsPrice(int productId) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/price/list/$productId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => ProductPrice.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil produk");
    }
  }

  static Future<bool> createProductPrice(
      {required int productId,
      required String unit,
      required int quantity,
      required int price,
      required String typePrice}) async {
    final token = await LoginService.getToken();

    final response = await http.post(
        Uri.parse("$baseUrl/api/price/list/$productId/"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "unit": unit,
          "qty": quantity,
          "price": price,
          "typePrice": typePrice
        }));

    print("CREATE PRICE BODY: ${response.body}");

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json["message"] ?? "Gagal menambah harga");
    }
  }

  static Future<ProductPrice> getPriceDetail(int productId, int priceId) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/price/detail/$productId/$priceId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return ProductPrice.fromJson(body['data']);
    } else if (response.statusCode == 401) {
      throw Exception("Session habis, silakan login ulang");
    } else {
      throw Exception("Gagal mengambil detail price");
    }
  }

  static Future<void> updatePrice(
      int productId, int priceId, Map<String, dynamic> payload) async {
    {
      final url = Uri.parse("$baseUrl/api/price/detail/$productId/$priceId/");
      final token = await LoginService.getToken();

      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode != 200) {
        throw Exception(
            "Gagal memperbarui produk: ${response.statusCode} ${response.body}");
      }
    }
  }
}
