import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserService {
  static final String baseUrl = dotenv.get("BASE_URL");

  static Future<Map<String, dynamic>?> getMe() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    if (token == null) {
      return null;
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/me/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return json["data"];
    }

    return null;
  }

  static Future<List<dynamic>> getUsers({String search = ""}) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    final uri = Uri.parse("$baseUrl/api/users/?search=$search");

    final response = await http.get(
      uri,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json["data"] ?? [];
    } else {
      throw Exception("Gagal mengambil data user");
    }
  }

  static Future<void> activateUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    final response = await http.get(
      Uri.parse("$baseUrl/api/activate/$userId/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal mengaktifkan user");
    }
  }

  static Future<void> deactivateUser(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    final response = await http.get(
      Uri.parse("$baseUrl/api/deactivate/$userId/"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode != 200) {
      throw Exception("Gagal menonaktifkan user");
    }
  }

  static Future<bool> isAdmin() async {
    final me = await getMe();
    return me?["is_staff"] == true;
  }

  static Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("access");

    final response = await http.post(
      Uri.parse("$baseUrl/api/reset/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "old_password": oldPassword,
        "new_password": newPassword,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(
        body["error"]?.join("\n") ??
            body["message"] ??
            "Gagal mengubah password",
      );
    }
  }
}
