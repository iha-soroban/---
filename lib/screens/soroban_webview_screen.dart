import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

import 'soroban_view_stub.dart'
    if (dart.library.io) 'soroban_view_native.dart'
    if (dart.library.html) 'soroban_view_web.dart';

/// 電子そろばんを全画面WebViewで表示する画面。
/// GitHub Pagesで公開されている単一HTMLファイル(外部参照ゼロ・オフライン動作)を
/// 全画面表示する。JavaScript有効・珠のクリック操作・WebAudio効果音に対応。
class SorobanWebViewScreen extends StatelessWidget {
  const SorobanWebViewScreen({super.key});

  static const String sorobanUrl =
      'https://iha-soroban.github.io/---/denshi-soroban.html';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF141518),
        foregroundColor: AppTheme.primaryYellow,
        title: const Text(
          '電子そろばん',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: buildSorobanView(sorobanUrl),
      ),
    );
  }
}
