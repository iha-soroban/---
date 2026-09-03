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
