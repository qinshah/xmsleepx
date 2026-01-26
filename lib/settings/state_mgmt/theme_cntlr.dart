import 'package:flutter/material.dart';
import 'package:niceleep/app/theme.dart';

class ThemeCntlr extends ChangeNotifier {
  ThemeCntlr._() {
    _loadThemeSettings();
  }
  static final ThemeCntlr i = ThemeCntlr._();

  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = AppTheme.defaultSeedColor;
  bool _useBlackBackground = false;
  bool _useDynamicColor = false;

  // Getters
  ThemeMode get themeMode => _themeMode;
  Color get seedColor => _seedColor;
  bool get useBlackBackground => _useBlackBackground;
  bool get useDynamicColor => _useDynamicColor;

  // 生成亮色主题
  ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
  );

  // 生成暗色主题
  ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
      surface: _useBlackBackground ? Colors.black : null,
    ),
  );

  /// 加载主题设置
  Future<void> _loadThemeSettings() async {
    _themeMode = await AppTheme.getThemeMode();
    _seedColor = await AppTheme.getSeedColor();
    _useBlackBackground = await AppTheme.getUseBlackBackground();
    _useDynamicColor = await AppTheme.getUseDynamicColor();
    notifyListeners();
  }

  /// 设置主题模式
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await AppTheme.setThemeMode(mode);
    notifyListeners();
  }

  /// 设置主题色
  Future<void> setSeedColor(Color color) async {
    _seedColor = color;
    await AppTheme.setSeedColor(color);
    notifyListeners();
  }

  /// 设置纯黑背景
  Future<void> setUseBlackBackground(bool use) async {
    _useBlackBackground = use;
    await AppTheme.setUseBlackBackground(use);
    notifyListeners();
  }

  /// 设置动态颜色
  Future<void> setUseDynamicColor(bool use) async {
    _useDynamicColor = use;
    await AppTheme.setUseDynamicColor(use);
    notifyListeners();
  }

  /// 重置为默认主题
  Future<void> resetToDefault() async {
    await setThemeMode(ThemeMode.system);
    await setSeedColor(AppTheme.defaultSeedColor);
    await setUseBlackBackground(false);
    await setUseDynamicColor(false);
  }
}
