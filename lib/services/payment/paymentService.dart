import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:frontend_roti/services/auth/login.dart';
import 'package:frontend_roti/models/payment.dart';

class PaymentService {
  static final String baseUrl = dotenv.get("BASE_URL");
  static Future<Map<String, dynamic>> getPayments({String? url}) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized");
    }

    Uri uri;

    /// pagination (next / previous)
    if (url != null) {
      uri = Uri.parse(url);
    } else {
      uri = Uri.parse("$baseUrl/api/payment/").replace();
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
      throw Exception("Gagal mengambil payment");
    }
  }

  static Future<Payment> getPaymentDetail(int paymentId) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized");
    }

    final uri = Uri.parse("$baseUrl/api/payment/detail/$paymentId/");

    final response = await http.get(
      uri,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      /// Jika response dibungkus:
      /// { status, version, data }
      final data = body['data'] ?? body;

      return Payment.fromJson(data);
    } else {
      throw Exception(_parseError(response.body));
    }
  }

  /// ================= ERROR PARSER =================
  static String _parseError(String responseBody) {
    try {
      final body = jsonDecode(responseBody);
      if (body is Map && body['error'] != null) {
        if (body['error'] is List) {
          return body['error'].join(', ');
        }
        return body['error'].toString();
      }
    } catch (_) {}
    return "Gagal mengambil detail pembayaran";
  }

  static Future<void> submitPayment({
    required int paymentId,
    required DateTime paymentDate,
    required int totalPaid,
  }) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/api/payment/$paymentId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "payment_date": paymentDate.toIso8601String().split("T").first,
        "total_paid": totalPaid,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);

      String message = body['error']?['detail'] ?? "Gagal menyimpan pembayaran";

      throw Exception(message);
    }
  }

  static Future<void> submitRepayment({
    required int paymentId,
    required DateTime paymentDate,
    required int amount,
  }) async {
    final token = await LoginService.getToken();
    if (token == null) {
      throw Exception("Unauthorized");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/api/repayment/$paymentId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "date": paymentDate.toIso8601String().split("T").first,
        "amount": amount,
      }),
    );
    print(response.body);

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);

      String message = body['error']?['detail'] ?? "Gagal menyimpan pembayaran";

      throw Exception(message);
    }
  }

  static Future<void> createPaymentItem({
    required int paymentId,
    required int productId,
    required String unit,
    required String refundType, // "retur" / "bs"
    required int qty,
    required String store, // "pasar" / "toko"
  }) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized");
    }

    final response = await http.post(
      Uri.parse("$baseUrl/api/payment/item/$paymentId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "product_id": productId,
        "unit": unit,
        "refund_type": refundType,
        "qty": qty,
        "store": store,
      }),
    );

    final body = jsonDecode(response.body);

    if (response.statusCode != 201) {
      String message =
          body["message"] ??
          body["error"]?["detail"] ??
          "Gagal menambahkan item";

      throw Exception(message);
    }
  }

  static Future<void> deletePaymentItem(int itemId) async {
    final token = await LoginService.getToken();

    if (token == null) {
      throw Exception("Unauthorized");
    }

    final response = await http.delete(
      Uri.parse("$baseUrl/api/payment/item/delete/$itemId/"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};

    if (response.statusCode != 200) {
      String message =
          body["message"] ?? body["error"]?["detail"] ?? "Gagal menghapus item";

      throw Exception(message);
    }
  }
}
