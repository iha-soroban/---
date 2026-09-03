import 'package:flutter/material.dart';

/// Flash Calc アプリのテーマ定義
/// 黒背景 x 黄色アクセントの高コントラストデザイン(フラッシュ暗算風)
class AppTheme {
  AppTheme._();

  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceLight = Color(0xFF262626);
  static const Color primaryYellow = Color(0xFFFFD400);
  static const Color accentRed = Color(0xFFFF3B30);
  static const Color accentGreen = Color(0xFF34D058);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB0B0B0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      fontFamily: 'Sorofont',
      colorScheme: const ColorScheme.dark(
        primary: primaryYellow,
        secondary: accentRed,
        surface: surface,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: primaryYellow,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
        iconTheme: IconThemeData(color: primaryYellow),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF333333), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          side: const BorderSide(color: Color(0xFF555555), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 28),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryYellow,
        inactiveTrackColor: const Color(0xFF333333),
        thumbColor: primaryYellow,
        overlayColor: primaryYellow.withValues(alpha: 0.2),
        valueIndicatorColor: primaryYellow,
        valueIndicatorTextStyle: const TextStyle(color: Colors.black),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textPrimary,
          fontWeight: FontWeight.bold,
        ),
        titleMedium: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textSecondary),
      ),
      dividerColor: const Color(0xFF333333),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primaryYellow,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
