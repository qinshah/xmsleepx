import 'package:hive_ce/hive_ce.dart';

class StorageService {
  static const String _settingsBox = 'settings';
  static const String _favoritesBox = 'favorites';
  static const String _playHistoryBox = 'playHistory';

  // 静态实例
  static Box? _settings;
  static Box? _favorites;
  static Box? _playHistory;

  /// 初始化存储服务
  static Future<void> init() async {
    await Hive.openBox(_settingsBox);
    await Hive.openBox(_favoritesBox);
    await Hive.openBox(_playHistoryBox);
    _settings = Hive.box(_settingsBox);
    _favorites = Hive.box(_favoritesBox);
    _playHistory = Hive.box(_playHistoryBox);
  }

  /// 获取设置值
  static T? get<T>(String key, {T? defaultValue}) {
    return _settings?.get(key, defaultValue: defaultValue) as T?;
  }

  /// 保存设置值
  static Future<void> set<T>(String key, T value) async {
    await _settings?.put(key, value);
  }

  /// 获取收藏列表
  static List<dynamic> getFavorites() {
    return _favorites?.get('items', defaultValue: []).toList() ?? [];
  }

  /// 添加收藏
  static Future<void> addFavorite(dynamic item) async {
    final favorites = getFavorites()..add(item);
    await _favorites?.put('items', favorites);
  }

  /// 移除收藏
  static Future<void> removeFavorite(String id) async {
    final favorites = getFavorites()..removeWhere((item) => item['id'] == id);
    await _favorites?.put('items', favorites);
  }

  /// 获取播放历史
  static List<dynamic> getPlayHistory() {
    return _playHistory?.get('items', defaultValue: []).toList() ?? [];
  }

  /// 添加播放历史
  static Future<void> addPlayHistory(dynamic item) async {
    final history = getPlayHistory()..insert(0, item);
    // 只保留最近100条
    if (history.length > 100) {
      history.removeRange(100, history.length);
    }
    await _playHistory?.put('items', history);
  }

  /// 清空播放历史
  static Future<void> clearPlayHistory() async {
    await _playHistory?.clear();
  }

  /// 关闭所有盒子
  static Future<void> close() async {
    await Hive.close();
  }
}
