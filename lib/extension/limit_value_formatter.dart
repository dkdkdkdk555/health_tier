import 'package:flutter/services.dart';

class LimitValueFormatter extends TextInputFormatter {
  final double max;

  LimitValueFormatter({required this.max});

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    if (text.isEmpty) return newValue;

    // 입력값 double 변환
    final double? value = double.tryParse(text);
    if (value == null) return oldValue;

    // 소수점 둘째자리 이상 입력 시 막기
    final parts = text.split('.');
    if (parts.length == 2 && parts[1].length > 1) {
      return oldValue;
    }

    // 최대값 초과 시 막기
    if (value > max) return oldValue;

    return newValue;
  }
}