import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:niceleep/app/data_model/playing_sound.dart';
import 'package:niceleep/app/data_model/sound_asset.dart';

class SoundManager extends ChangeNotifier {
  SoundManager._();
  //  {
  //   AudioSession.instance.then((audioSession) {
  //     audioSession.configure(AudioSessionConfiguration.music());
  //     _audioSession = audioSession;
  //   });
  // }
  static final SoundManager i = SoundManager._();
  final _playingMap = <String, PlayingSound>{};
  List<PlayingSound> get playingSounds => _playingMap.values.toList();

  // late final AudioSession _audioSession;

  Future<void> onTapSound(SoundAsset asset) async {
    // 如果在播放，移除
    if (_playingMap.containsKey(asset.id)) {
      stopSound(_playingMap[asset.id]!);
      return;
    }
    // 否则添加到播放列表
    final player = AudioPlayer(playerId: asset.id);
    await player.setPlayerMode(PlayerMode.lowLatency);
    await player.setSource(AssetSource(asset.path.replaceFirst('assets/', '')));
    await player.setReleaseMode(ReleaseMode.loop); // 设置为循环播放
    await player.setVolume(0.5); // 默认0.5音量
    await player.resume();
    notifyListeners();
    _playingMap[asset.id] = PlayingSound(asset: asset, player: player);
  }

  void setVolume({required PlayingSound playingSound, required double volume}) {
    playingSound.player.setVolume(volume.clamp(0.0, 1.0));
  }

  void setAllVolume(double volume) {
    volume = volume.clamp(0.0, 1.0);
    for (var playingSound in _playingMap.values) {
      playingSound.player.setVolume(volume);
    }
  }

  void stopSound(PlayingSound playingSound) {
    playingSound.player.dispose();
    _playingMap.remove(playingSound.asset.id);
    notifyListeners();
  }

  void stopAllSound() {
    for (var playingSound in _playingMap.values) {
      playingSound.player.dispose();
    }
    _playingMap.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    stopAllSound();
    super.dispose();
  }

  bool isSoundPlaying(SoundAsset sound) {
    return _playingMap.containsKey(sound.id);
  }
}
