import 'package:flutter/services.dart';

/// 数値を3桁区切り(カンマ区切り)の文字列に変換する。
/// 例: 12345 -> "12,345"、-6789 -> "-6,789"
String formatWithComma(int value) {
  final isNegative = value < 0;
  final digits = value.abs().toString();

  final buffer = StringBuffer();
  final length = digits.length;
  for (int i = 0; i < length; i++) {
    if (i > 0 && (length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }

  return isNegative ? '-${buffer.toString()}' : buffer.toString();
}

/// カンマ・符号を取り除いた数字文字列を返す(パース用)。
String stripComma(String text) => text.replaceAll(',', '');

/// TextField入力中にリアルタイムで3桁区切りカンマを自動挿入するFormatter。
/// マイナス記号(先頭のみ)を許可し、カーソル位置も末尾に保つ。
class CommaNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 数字とマイナス記号(先頭のみ)以外を除去
    String raw = newValue.text.replaceAll(RegExp(r'[^\d-]'), '');

    final isNegative = raw.startsWith('-');
    // マイナス記号は先頭の1つだけ許可、それ以外の'-'は除去
    String digitsOnly = raw.replaceAll('-', '');

    if (digitsOnly.isEmpty) {
      final text = isNegative ? '-' : '';
      return TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    }

    // 先頭の余分な0を削除(ただし単一の0は許可)
    digitsOnly = digitsOnly.replaceFirst(RegExp(r'^0+(?=\d)'), '');

    final buffer = StringBuffer();
    final length = digitsOnly.length;
    for (int i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(digitsOnly[i]);
    }

    final formatted = (isNegative ? '-' : '') + buffer.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
