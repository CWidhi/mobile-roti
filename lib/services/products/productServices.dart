import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/models/product.dart';
import 'package:frontend_roti/services/auth/login.dart';

class ProductService {
  static final String baseUrl = dotenv.get("BASE_URL");

  static Future<List<Product>> getProductsHome() async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/product/home/?max=3"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil produk");
    }
  }

  static Future<List<Product>> getProductsDropdown() async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/product/dropdown/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => Product.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil produk");
    }
  }

  static Future<Map<String, dynamic>> getProducts({
    String? search,
    String? url,
  }) async {
    final token = await LoginService.getToken();
    Uri uri;

    if (url != null) {
      uri = Uri.parse(url);
    } else {
      uri = Uri.parse("$baseUrl/api/product/").replace(
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
      throw Exception("Gagal mengambil produk");
    }
  }

  static Future<Product> getProductDetail(int id) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/product/$id/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return Product.fromJson(body['data']);
    } else if (response.statusCode == 401) {
      throw Exception("Session habis, silakan login ulang");
    } else {
      throw Exception("Gagal mengambil detail produk");
    }
  }

  static Future<void> createProduct(Map<String, dynamic> payload) async {
    final token = await LoginService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/product/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body["message"] ?? "Gagal menambahkan produk");
    }
  }

  // productServices.dart
  static Future<void> deleteProduct(int productId) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized");
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/api/product/remove/$productId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception("Gagal menghapus produk");
    }
  }

  static Future<void> updateProduct(
      int productId, 
      Map<String, dynamic> payload
    ) async {
    final url = Uri.parse("$baseUrl/api/product/update/$productId/");
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
