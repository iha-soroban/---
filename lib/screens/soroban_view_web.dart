import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Web 向け: iframe を使って電子そろばんを全画面表示する。
/// GitHub Pages 上の単一 HTML ファイルをそのまま iframe に読み込む。
/// JavaScript・WebAudio はブラウザの iframe 内でそのまま動作する。
Widget buildSorobanView(String url) {
  final viewType = 'soroban-iframe-${url.hashCode}';

  // ignore: undefined_prefixed_name
  ui_web.platformViewRegistry.registerViewFactory(viewType, (int viewId) {
    final iframe = html.IFrameElement()
      ..src = url
      ..style.border = 'none'
      ..style.width = '100%'
      ..style.height = '100%'
      ..allowFullscreen = true;
    // JavaScript はデフォルトで有効。allow 属性でオーディオ再生等を許可する。
    iframe.setAttribute('allow', 'autoplay; fullscreen');
    return iframe;
  });

  return HtmlElementView(viewType: viewType);
}
