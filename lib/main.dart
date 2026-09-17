import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'screens/mode_select_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await StorageService.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState()..init(),
      child: MaterialApp(
        title: 'そろばん式暗算トレーニング',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        // 日本語の漢字字体(简体字ではなく日本の標準字体)で
        // 正しく表示されるように、ロケールを明示的に日本語に固定する。
        locale: const Locale('ja', 'JP'),
        supportedLocales: const [Locale('ja', 'JP')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const ModeSelectScreen(),
      ),
    );
  }
}
