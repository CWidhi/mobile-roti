import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class RupiahInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final numericValue = newValue.text.replaceAll('.', '');

    final number = int.tryParse(numericValue);

    if (number == null) {
      return oldValue;
    }

    final formatted = _formatter.format(number);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(
        offset: formatted.length,
      ),
    );
  }
}

String formatNumber(dynamic value) {
  final number = int.tryParse(value.toString()) ?? 0;
  return number.toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => '.',
  );
}

int parseFormattedNumber(String value) {
  return int.parse(
    value.replaceAll('.', '').replaceAll(',', '').trim(),
  );
}