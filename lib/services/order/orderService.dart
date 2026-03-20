import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/services/auth/login.dart';
import 'package:frontend_roti/models/order.dart';

class OrderPickingService {
  static final String baseUrl = dotenv.get("BASE_URL");

  /// ================= GET LIST ORDER PICKING =================
  /// return: data { count, next, previous, results }
  static Future<Map<String, dynamic>> getOrderPickings({
    String? search,
    String? url,
  }) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized");
    }

    Uri uri;

    /// pagination (next / previous)
    if (url != null) {
      uri = Uri.parse(url);
    } else {
      uri = Uri.parse("$baseUrl/api/order-picking/").replace(
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
      final body = jsonDecode(response.body);
      return body['data'];
    } else {
      throw Exception("Gagal mengambil order picking");
    }
  }

  static Future<void> createOrder({
    required int userId,
    required int ruteId,
    required DateTime orderDate,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await LoginService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/order-picking/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "user_id": userId,
        "rute_id": ruteId,
        "order_date": orderDate.toIso8601String().split("T").first,
        "items": items,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      final body = jsonDecode(response.body);

      String message = "Gagal membuat order";

      if (body is Map<String, dynamic>) {
        final error = body['error'];

        if (error is List && error.isNotEmpty) {
          message = error.map((e) => e.toString()).join(', ');
        } else if (error is String) {
          message = error;
        }
      }

      throw Exception(message);
    }
  }

  static Future<OrderPicking> getOrderDetail(int id) async {
    final token = await LoginService.getToken();

    final uri = Uri.parse("$baseUrl/api/order-picking/$id/");

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final jsonBody = jsonDecode(response.body);
      return OrderPicking.fromJson(jsonBody['data']);
    } else {
      throw Exception("Gagal mengambil detail purchase");
    }
  }

  static Future<void> confirmOrder(int orderId) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/api/order-picking/confirm/$orderId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (json["status"] != true) {
        throw Exception(json["message"] ?? "Gagal konfirmasi order");
      }
      return;
    }

    throw Exception(
      json["message"] ?? "Gagal konfirmasi order",
    );
  }

  static Future<OrderPicking> updateOrder({
    required int orderId,
    required int ruteId,
    required DateTime orderDate,
    required List<Map<String, dynamic>> items,
  }) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Token tidak ditemukan");
    }

    final uri = Uri.parse("$baseUrl/api/order-picking/$orderId/");

    final body = {
      "rute_id": ruteId,
      "order_date": orderDate.toIso8601String().split("T").first,
      "items": items,
    };

    final response = await http.put(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body);
      return OrderPicking.fromJson(json["data"]);
    } else {
      throw Exception(
        "Gagal update order (${response.statusCode}) : ${response.body}",
      );
    }
  }
}
