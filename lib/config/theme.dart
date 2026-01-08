import 'package:flutter/material.dart';

class AppTheme {
  // 亮色主题
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF6750A4),
        primary: const Color(0xFF6750A4),
        onPrimary: Colors.white,
        secondary: const Color(0xFF625B71),
        onSecondary: Colors.white,
        tertiary: const Color(0xFF7D5260),
        background: const Color(0xFFFFFBFE),
        onBackground: const Color(0xFF1C1B1F),
        surface: const Color(0xFFFFFBFE),
        onSurface: const Color(0xFF1C1B1F),
        surfaceVariant: const Color(0xFFE7E0EC),
        onSurfaceVariant: const Color(0xFF49454F),
        outline: const Color(0xFF79747E),
      ),
      scaffoldBackgroundColor: const Color(0xFFFFFBFE),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFE7E0EC),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE7E0EC),
      ),
    );
  }

  // 暗色主题
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFD0BCFF),
        primary: const Color(0xFFD0BCFF),
        onPrimary: const Color(0xFF381E72),
        secondary: const Color(0xFFCCC2DC),
        onSecondary: const Color(0xFF332D41),
        tertiary: const Color(0xFFEFB8C8),
        onTertiary: const Color(0xFF492532),
        background: const Color(0xFF1C1B1F),
        onBackground: const Color(0xFFE6E1E5),
        surface: const Color(0xFF1C1B1F),
        onSurface: const Color(0xFFE6E1E5),
        surfaceVariant: const Color(0xFF49454F),
        onSurfaceVariant: const Color(0xFFCAC4D0),
        outline: const Color(0xFF938F99),
      ),
      scaffoldBackgroundColor: const Color(0xFF1C1B1F),
      cardTheme: CardThemeData(
        color: const Color(0xFF2B2930),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF49454F),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF2B2930),
        indicatorColor: const Color(0xFF49454F),
      ),
    );
  }

  /// 从存储获取主题模式
  static ThemeMode getThemeMode() {
    return ThemeMode.system;
  }

  /// 设置主题模式
  static void setThemeMode(ThemeMode mode) {}
}
