import 'package:audioplayers/audioplayers.dart';
import 'package:xmsleepx/app/data_model/sound_asset.dart';

class PlayingSound {
  final SoundAsset asset;

  final AudioPlayer player;

  PlayingSound({required this.player, required this.asset});
}
