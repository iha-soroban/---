import 'package:flutter/material.dart';

/// dart:io も dart:html も使えない環境向けのフォールバック(通常は使用されない)。
Widget buildSorobanView(String url) {
  return Center(
    child: Text('この環境では電子そろばんを表示できません: $url'),
  );
}
