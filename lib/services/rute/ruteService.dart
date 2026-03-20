import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/services/auth/login.dart';
import 'package:frontend_roti/models/rute.dart';

class RouteLineService {
  static final String baseUrl = dotenv.get("BASE_URL");

  static Future<List<RouteLine>> getRouteLinesHome() async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/rute-line/home/?max=2"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final List results = body['data'];

      return results.map((e) => RouteLine.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data route line");
    }
  }

  static Future<List<RouteLine>> getRouteLinesDropdown(
    int? userId,
  ) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/rute/$userId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final List results = body['data'];

      return results.map((e) => RouteLine.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data route line");
    }
  }

  static Future<List<RouteLine>> getRouteLines(
    String? search,
    String? url,
  ) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/rute-line/").replace(
        queryParameters: {
          if (search != null && search.isNotEmpty) "search": search,
        },
      ),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final List results = body['data']['results'];

      return results.map((e) => RouteLine.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil data route line");
    }
  }

  static Future<void> createRouteLine(Map<String, dynamic> payload) async {
    final token = await LoginService.getToken();
    final response = await http.post(
      Uri.parse("$baseUrl/api/rute-line/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 201) {
      throw Exception("Gagal menambah rute");
    }
  }

  static Future<void> updateRouteLine(
      int id, Map<String, dynamic> payload) async {
    final token = await LoginService.getToken();
    final response = await http.put(
      Uri.parse("$baseUrl/api/rute-line/$id/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal update rute");
    }
  }

  static Future<void> deleteRouteLine(int id) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/api/rute-line/$id/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      final body = jsonDecode(response.body);
      throw Exception(body["message"] ?? "Gagal menghapus rute");
    }
  }

  static Future<RouteLine> getRouteLineDetail(int id) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/rute-line/$id/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );
    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      return RouteLine.fromJson(body['data']);
    } else if (response.statusCode == 401) {
      throw Exception("Session habis, silakan login ulang");
    } else {
      throw Exception("Gagal mengambil detail produk");
    }
  }

  static Future<void> addUserToRute({
    required int userId,
    required int ruteLineId,
  }) async {
    final token = await LoginService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/rute/add/user/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "user_id": userId,
        "rute_line_id": ruteLineId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Gagal menambahkan user ke rute");
    }
  }
  static Future<void> removeUserToRute({
    required int userId,
    required int ruteLineId,
  }) async {
    final token = await LoginService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/rute/remove/user/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "user_id": userId,
        "rute_line_id": ruteLineId,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception("Gagal menghapus user dari rute");
    }
  }
}
