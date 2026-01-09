import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

import '../models/sound.dart';

/// 正在播放的音频信息
class PlayingInfo {
  final String id;
  final String url;
  final String name;
  final AudioPlayer player;
  double volume;
  bool isPlaying;
  String? error;

  PlayingInfo({
    required this.id,
    required this.url,
    required this.name,
    required this.player,
    this.volume = 1.0,
    this.isPlaying = false,
    this.error,
  });
}

/// 多音频播放服务 - 支持同时播放多个音频
class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final Map<String, PlayingInfo> _players = {};
  final _onChangeController = StreamController.broadcast();
  Stream get onChange => _onChangeController.stream;

  /// 播放一个音频
  Future<void> play(Sound sound) async {
    // 如果已经播放，直接返回
    if (_players.containsKey(sound.id)) {
      final info = _players[sound.id]!;
      if (!info.isPlaying) {
        await info.player.resume();
        info.isPlaying = true;
        _notifyChange();
      }
      return;
    }

    // 创建新的播放器
    final player = AudioPlayer();
    final info = PlayingInfo(
      id: sound.id,
      url: sound.url,
      name: sound.name,
      player: player,
      volume: 1.0,
      isPlaying: true,
    );

    try {
      await player.setSource(AssetSource(sound.url.replaceFirst('assets/', '')));
      await player.resume();

      // 监听播放状态变化
      player.onPlayerStateChanged.listen((state) {
        if (info.isPlaying != (state == PlayerState.playing)) {
          info.isPlaying = state == PlayerState.playing;
          _notifyChange();
        }
      });

      player.onDurationChanged.listen((_) {
        // 不需要频繁通知，除非有特殊需求
      });

      _players[sound.id] = info;
      _notifyChange();
    } catch (e) {
      info.error = e.toString();
      _notifyChange();
    }
  }

  /// 暂停指定音频
  Future<void> pause(String soundId) async {
    final info = _players[soundId];
    if (info != null && info.isPlaying) {
      await info.player.pause();
      info.isPlaying = false;
      _notifyChange();
    }
  }

  /// 恢复指定音频
  Future<void> resume(String soundId) async {
    final info = _players[soundId];
    if (info != null && !info.isPlaying) {
      await info.player.resume();
      info.isPlaying = true;
      _notifyChange();
    }
  }

  /// 切换播放/暂停
  Future<void> toggle(String soundId) async {
    final info = _players[soundId];
    if (info != null) {
      if (info.isPlaying) {
        await pause(soundId);
      } else {
        await resume(soundId);
      }
    }
  }

  /// 停止指定音频
  Future<void> stop(String soundId) async {
    final info = _players[soundId];
    if (info != null) {
      try {
        await info.player.stop();
        await info.player.dispose();
      } catch (e) {
        // 忽略销毁时的错误
      }
      _players.remove(soundId);
      _notifyChange();
    }
  }

  /// 停止所有音频
  Future<void> stopAll() async {
    final infos = List<PlayingInfo>.from(_players.values);
    
    // 并行停止所有音频
    await Future.wait(infos.map((info) async {
      try {
        await info.player.stop();
        await info.player.dispose();
      } catch (e) {
        // 忽略销毁时的错误
      }
    }));
    
    _players.clear();
    _notifyChange();
  }

  /// 设置音量
  Future<void> setVolume(String soundId, double volume) async {
    final info = _players[soundId];
    if (info != null) {
      info.volume = volume.clamp(0.0, 1.0);
      await info.player.setVolume(info.volume);
      _notifyChange();
    }
  }

  /// 获取正在播放的所有音频
  List<PlayingInfo> get playingList {
    return _players.values.toList();
  }

  /// 检查是否正在播放
  bool isPlaying(String soundId) {
    return _players[soundId]?.isPlaying ?? false;
  }

  /// 是否已添加到播放列表
  bool hasSound(String soundId) {
    return _players.containsKey(soundId);
  }

  void _notifyChange() {
    // 防抖处理，避免频繁更新
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!_onChangeController.isClosed) {
        _onChangeController.add(_players.values.toList());
      }
    });
  }

  /// 释放资源
  void dispose() {
    for (final info in _players.values) {
      info.player.dispose();
    }
    _players.clear();
    _onChangeController.close();
  }
}
