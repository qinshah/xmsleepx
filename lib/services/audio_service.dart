import 'dart:async';
import 'dart:collection';
import 'package:audioplayers/audioplayers.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';

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
    this.volume = 0.5, // 默认音量50%
    this.isPlaying = false,
    this.error,
  });
}

/// 多音频播放服务 - 支持同时播放多个音频
class AudioService {
  static final AudioService _instance = AudioService._();
  factory AudioService() => _instance;
  AudioService._();

  final Map<String, PlayingInfo> _players = HashMap<String, PlayingInfo>();
  final _onChangeController = StreamController.broadcast();
  Stream get onChange => _onChangeController.stream;
  
  // 全局音量控制
  double _globalVolume = 0.5; // 默认音量50%
  double get globalVolume => _globalVolume;
  
  // 播放队列管理 - 参考Android版本实现
  static const int _maxConcurrentSounds = 10; // 最多同时播放10个音频
  final List<String> _playingQueue = []; // 播放顺序队列
  
  // 音频会话管理
  AudioSession? _audioSession;
  bool _isInitialized = false;

  /// 播放一个音频
  Future<void> play(Sound sound) async {
    // 初始化音频会话
    await _initializeAudioSession();
    
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

    // 检查是否已达到最大播放数量，如果是则停止最早播放的声音
    if (_playingQueue.length >= _maxConcurrentSounds) {
      final oldestSoundId = _playingQueue.removeAt(0);
      await stop(oldestSoundId);
    }

    // 创建新的播放器
    final player = AudioPlayer();
    
    // 设置播放器模式以支持同时播放多个音频
    await player.setPlayerMode(PlayerMode.lowLatency);
    
    final info = PlayingInfo(
      id: sound.id,
      url: sound.url,
      name: sound.name,
      player: player,
      volume: _globalVolume, // 使用全局音量作为初始音量
      isPlaying: true,
    );

    try {
      await player.setSource(AssetSource(sound.url.replaceFirst('assets/', '')));
      
      // 设置为循环播放
      await player.setReleaseMode(ReleaseMode.loop);
      
      // 应用全局音量
      await player.setVolume(_globalVolume);
      
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
      // 添加到播放队列
      _playingQueue.add(sound.id);
      _notifyChange();
    } catch (e) {
      info.error = e.toString();
      _notifyChange();
    }
  }

  /// 初始化音频会话
  Future<void> _initializeAudioSession() async {
    if (_isInitialized) return;
    
    try {
      _audioSession = await AudioSession.instance;
      await _audioSession?.configure(AudioSessionConfiguration.music());
      _isInitialized = true;
    } catch (e) {
      // 静默处理音频会话初始化失败
      debugPrint('Failed to initialize audio session: $e');
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

  /// 切换播放/暂停 (已废弃，建议直接使用play和stop)
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
      // 从播放队列中移除
      _playingQueue.remove(soundId);
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
    // 清空播放队列
    _playingQueue.clear();
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

  /// 设置全局音量 - 统一调整所有正在播放声音的音量
  Future<void> setGlobalVolume(double volume) async {
    _globalVolume = volume.clamp(0.0, 1.0);
    
    // 应用到所有正在播放的音频
    for (final info in _players.values) {
      await info.player.setVolume(_globalVolume);
      info.volume = _globalVolume;
    }
    
    _notifyChange();
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
    // 停止所有播放器并清理资源
    stopAll();
    
    // 释放音频会话
    _audioSession = null;
    
    // 关闭流控制器
    _onChangeController.close();
    _isInitialized = false;
  }
}
