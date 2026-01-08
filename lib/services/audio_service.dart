import 'dart:async';

import 'package:audioplayers/audioplayers.dart';

import 'storage_service.dart';

/// 音频播放服务
class AudioService {
  final AudioPlayer _player = AudioPlayer();
  final Map<String, StreamSubscription> _subscriptions = {};
  final Map<String, Duration> _positions = {};
  String? _currentSourceId;

  /// 当前播放状态
  bool get isPlaying => _player.state == PlayerState.playing;

  /// 当前播放的音频ID
  String? get currentSourceId => _currentSourceId;

  /// 当前音量 (0.0 - 1.0)
  double get volume => _player.volume;

  /// 设置音量
  set volume(double value) {
    _player.setVolume(value);
  }

  /// 当前播放位置
  Duration get currentPosition => _positions[_currentSourceId] ?? Duration.zero;

  /// 播放音频
  Future<void> play({
    required String id,
    required String url,
    String title = '',
  }) async {
    // 如果正在播放其他音频，先停止
    if (_currentSourceId != null && _currentSourceId != id) {
      await stop();
    }

    _currentSourceId = id;
    
    // 恢复播放位置
    final savedPosition = _positions[id] ?? Duration.zero;
    
    await _player.setSourceUrl(url);
    await _player.resume();

    // 订阅播放位置更新
    _subscriptions[id] = _player.onPositionChanged.listen((position) {
      _positions[id] = position;
    });

    // 添加到播放历史
    unawaited(StorageService.addPlayHistory({
      'id': id,
      'url': url,
      'title': title,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    }));
  }

  /// 暂停播放
  Future<void> pause() async {
    await _player.pause();
  }

  /// 恢复播放
  Future<void> resume() async {
    await _player.resume();
  }

  /// 停止播放
  Future<void> stop() async {
    // 保存当前位置
    if (_currentSourceId != null) {
      _positions[_currentSourceId!] = await _player.getCurrentPosition() ?? Duration.zero;
    }
    
    // 取消订阅
    _subscriptions[_currentSourceId]?.cancel();
    _subscriptions.remove(_currentSourceId);
    
    await _player.stop();
    _currentSourceId = null;
  }

  /// 设置音量
  Future<void> setVolume(double volume) async {
    await _player.setVolume(volume.clamp(0.0, 1.0));
  }

  /// 设置播放速度
  Future<void> setPlaybackRate(double rate) async {
    await _player.setPlaybackRate(rate);
  }

  /// 循环模式
  Future<void> setReleaseMode(ReleaseMode mode) async {
    await _player.setReleaseMode(mode);
  }

  /// 跳转到指定位置
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  /// 订阅播放状态
  Stream<PlayerState> onPlayerStateChanged() {
    return _player.onPlayerStateChanged;
  }

  /// 订阅播放完成事件
  Stream<Duration> onPlayerComplete() {
    return _player.onDurationChanged;
  }

  /// 订阅位置更新
  Stream<Duration> onPositionChanged() {
    return _player.onPositionChanged;
  }

  /// 释放资源
  Future<void> dispose() async {
    for (final sub in _subscriptions.values) {
      await sub.cancel();
    }
    _subscriptions.clear();
    _positions.clear();
    await _player.dispose();
  }
}
