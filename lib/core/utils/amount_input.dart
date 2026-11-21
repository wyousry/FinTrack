import 'package:flutter/services.dart';

class AmountInputFormatter extends TextInputFormatter {
  static final RegExp _valid = RegExp(r'^\d{0,9}(\.\d{0,2})?$');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(',', '.');
    if (text.isEmpty || _valid.hasMatch(text)) {
      return newValue.copyWith(text: text);
    }
    return oldValue;
  }
}

abstract final class AmountInput {
  static const double maxValue = 999999999.99;

  static String add(String current, double delta) {
    final sum = (double.tryParse(current) ?? 0) + delta;
    if (sum > maxValue) return current;
    return format(sum);
  }

  static String backspace(String current) {
    if (current.isEmpty) return current;
    return current.substring(0, current.length - 1);
  }

  static String format(double value) {
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }
}