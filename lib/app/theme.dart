import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppTheme {
  static const String _themeKey = 'theme_mode';
  static const String _colorKey = 'primary_color';
  static const String _dynamicColorKey = 'dynamic_color';
  static const String _blackBackgroundKey = 'black_background';
  
  // 默认主题色
  static const Color defaultSeedColor = Color(0xFF6750A4);
  
  // 预设颜色方案（使用HCT色彩空间的柔和粉彩色）
  static const List<Color> presetColors = [
    Color(0xFFB3261E), // 柔和红
    Color(0xFF7D5260), // 柔和橙
    Color(0xFF6750A4), // 柔和紫
    Color(0xFF4F378B), // 深紫
    Color(0xFF52525A), // 柔和灰
    Color(0xFF006493), // 柔和蓝
    Color(0xFF006D3C), // 柔和绿
    Color(0xFF7D5700), // 柔和黄绿
    Color(0xFFB3261E), // 柔和红
    Color(0xFF8C4D00), // 柔和橙
  ];
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
        surface: const Color(0xFFFFFBFE),
        onSurface: const Color(0xFF1C1B1F),
        surfaceContainerHighest: const Color(0xFFE7E0EC),
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
        surface: const Color(0xFF1C1B1F),
        onSurface: const Color(0xFFE6E1E5),
        surfaceContainerHighest: const Color(0xFF49454F),
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
  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final String? savedTheme = prefs.getString(_themeKey);
    switch (savedTheme) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// 设置主题模式
  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
    }
    await prefs.setString(_themeKey, themeString);
  }
  
  /// 获取保存的主题色
  static Future<Color> getSeedColor() async {
    final prefs = await SharedPreferences.getInstance();
    final int? savedColor = prefs.getInt(_colorKey);
    return savedColor != null ? Color(savedColor) : defaultSeedColor;
  }
  
  /// 设置主题色
  static Future<void> setSeedColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_colorKey, color.value);
  }
  
  /// 是否使用动态颜色
  static Future<bool> getUseDynamicColor() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_dynamicColorKey) ?? false;
  }
  
  /// 设置动态颜色
  static Future<void> setUseDynamicColor(bool use) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_dynamicColorKey, use);
  }
  
  /// 是否使用纯黑背景
  static Future<bool> getUseBlackBackground() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_blackBackgroundKey) ?? false;
  }
  
  /// 设置纯黑背景
  static Future<void> setUseBlackBackground(bool use) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_blackBackgroundKey, use);
  }
  
}
