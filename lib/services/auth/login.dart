import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginService {
  static final String baseUrl = dotenv.get("BASE_URL");

  static Future<String?> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("$baseUrl/api/token/"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "username": email,
        "password": password,
      }),
    );

    final json = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final accessToken = json["data"]?["access"];

      if (accessToken == null) {
        return "Access token tidak ditemukan";
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("access", accessToken);

      return null;
    }

    if (json["error"] != null) {
      final error = json["error"];

      // case: { detail: ["Account is inactive."] }
      if (error["detail"] is List && error["detail"].isNotEmpty) {
        return error["detail"][0];
      }

      // case lain (string)
      if (error is String) {
        return error;
      }
    }

    return "Login gagal, silakan hubungi admin";
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("access");
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access") != null;
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString("access");
  }
}
