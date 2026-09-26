import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Android / iOS 向け: webview_flutter を使って全画面表示する。
/// JavaScript を有効化し、珠のタップ操作・WebAudio 効果音が動作するようにする。
Widget buildSorobanView(String url) {
  final controller = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..setBackgroundColor(const Color(0xFFE7E2D5))
    ..loadRequest(Uri.parse(url));

  return WebViewWidget(controller: controller);
}
