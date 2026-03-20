import 'dart:convert';
import 'package:frontend_roti/models/supplier.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/services/auth/login.dart';

class SupplierService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  static Future<List<Supplier>> getSupplierDropdown() async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized: token tidak ditemukan");
    }

    final response = await http.get(
      Uri.parse("$baseUrl/api/supplier/dropdown/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      final List data = body['data'];
      return data.map((e) => Supplier.fromJson(e)).toList();
    } else {
      throw Exception("Gagal mengambil produk");
    }
  }

  static Future<Map<String, dynamic>> getSuppliers({
    String? search,
    String? url,
  }) async{
    final token = await LoginService.getToken();
    Uri uri;

    if (url != null) {
      uri = Uri.parse(url); 
    } else {
      uri = Uri.parse("$baseUrl/api/supplier/").replace(
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
      return json[
          "data"]; 
    } else {
      throw Exception("Gagal mengambil produk");
    }
  }

  static Future<bool> createSupplier({
    required String name,
    required String address,
    required String phoneNumber,
  }) async {
    final token = await LoginService.getToken();

    final response = await http.post(
      Uri.parse("$baseUrl/api/supplier/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "address": address,
        "phone_number": phoneNumber,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    } else {
      final json = jsonDecode(response.body);
      throw Exception(json["message"] ?? "Gagal menambah supplier");
    }
  }

  static Future<bool> updateSupplier({
    required int id,
    required String name,
    required String address,
    required String phoneNumber,
  }) async {
    final token = await LoginService.getToken();

    final response = await http.put(
      Uri.parse("$baseUrl/api/supplier/$id/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "name": name,
        "address": address,
        "phone_number": phoneNumber,
      }),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception("Gagal update supplier");
    }
  }
}
