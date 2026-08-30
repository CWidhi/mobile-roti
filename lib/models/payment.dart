import 'package:flutter/material.dart';

class Payment {
  final int id;
  final String userEmail;
  final String userName;
  final String orderPicking;
  final int orderPickingTotal;
  final DateTime paymentDate;
  final int totalOrder;
  final int totalPaid;
  final int remainingAmount;
  final String status;
  final List<PaymentItem> items;

  Payment({
    required this.id,
    required this.userEmail,
    required this.userName,
    required this.orderPicking,
    required this.orderPickingTotal,
    required this.paymentDate,
    required this.totalOrder,
    required this.totalPaid,
    required this.remainingAmount,
    required this.status,
    required this.items,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final orderPicking = json['order_picking'];

    return Payment(
      id: json['id'],
      userEmail: user['email'],
      userName: "${user['first_name']} ${user['last_name']}",
      orderPicking: orderPicking?['rute']?['name'] ?? "-",
      orderPickingTotal: orderPicking?['total'] ?? 0,
      paymentDate: DateTime.parse(json['payment_date']),
      totalOrder: json['total_order'],
      totalPaid: json['total_paid'],
      remainingAmount: json['remaining_amount'],
      status: json['status'],

      /// ✅ PARSE ITEMS
      items: (json['items'] as List? ?? [])
          .map((e) => PaymentItem.fromJson(e))
          .toList(),
    );
  }

  /// === Helpers (UX & logic friendly)
  bool get isLunas => status.toLowerCase() == "lunas";
  bool get isBelumLunas => status.toLowerCase() == "belum lunas";
}


class PaymentItem {
  final int id;
  final String productName;
  final String unit;
  final String refundType;
  final int qty;
  final int price;
  final int total;

  PaymentItem({
    required this.id,
    required this.productName,
    required this.unit,
    required this.refundType,
    required this.qty,
    required this.price,
    required this.total,
  });

  factory PaymentItem.fromJson(Map<String, dynamic> json) {
    return PaymentItem(
      id: json['id'],
      productName: json['product']['name'],
      unit: json['unit'],
      refundType: json['refund_type'],
      qty: json['qty'],
      price: json['price'],
      total: json['total'],
    );
  }
}


enum PaymentStatusUI {
  Lunas,
  BelumLunas,
  BelumDibayar,
}

extension PaymentUI on Payment {
  PaymentStatusUI get uiStatus {
    if (totalPaid == totalOrder) {
      return PaymentStatusUI.Lunas;
    }
    if (totalPaid > 0 && remainingAmount < totalOrder) {
      return PaymentStatusUI.BelumLunas;
    }
    return PaymentStatusUI.BelumDibayar;
  }

  Color get statusColor {
    switch (uiStatus) {
      case PaymentStatusUI.Lunas:
        return Colors.green;
      case PaymentStatusUI.BelumLunas:
        return Colors.orange;
      case PaymentStatusUI.BelumDibayar:
        return Colors.red;
    }
  }

  IconData get statusIcon {
    switch (uiStatus) {
      case PaymentStatusUI.Lunas:
        return Icons.check_circle;
      case PaymentStatusUI.BelumLunas:
        return Icons.timelapse;
      case PaymentStatusUI.BelumDibayar:
        return Icons.cancel;
    }
  }

  String get statusLabel {
    switch (uiStatus) {
      case PaymentStatusUI.Lunas:
        return "Lunas";
      case PaymentStatusUI.BelumLunas:
        return "Belum Lunas";
      case PaymentStatusUI.BelumDibayar:
        return "Belum Dibayar";
    }
  }
}


