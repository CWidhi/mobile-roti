import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SignupService {
  static final String baseUrl = dotenv.get("BASE_URL");

  static Future<String?> signup({
    required String email,
    required String firstName,
    required String lastName,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/api/signup/");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "first_name": firstName,
        "last_name": lastName,
        "password": password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      final data = jsonDecode(response.body);
      if (data["error"] is Map) {
        final Map errors = data["error"];

        final messages = errors.entries
            .where((e) =>
                e.key != "non_field_errors" &&
                e.key != "non_filed_error" &&
                e.key != "detail")
            .map((e) {
          final field = e.key.toString().replaceAll("_", " ");
          final msgs = (e.value as List).join(", ");
          return "$field: $msgs";
        }).join("\n");

        return messages.isEmpty ? "Signup failed" : messages;
      }

      return "Signup failed";
    }

    return null;
  }
}
