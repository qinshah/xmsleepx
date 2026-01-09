import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../../models/sound.dart';
import '../../services/audio_service.dart';

class PlayerPage extends StatefulWidget {
  final Sound sound;

  const PlayerPage({super.key, required this.sound});

  @override
  State<PlayerPage> createState() => _PlayerPageState();
}

class _PlayerPageState extends State<PlayerPage> {
  final AudioService _audioService = AudioService();
  late StreamSubscription _audioSubscription;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _audioService.play(widget.sound);
    
    // 监听音频状态变化
    _audioSubscription = _audioService.onChange.listen((_) {
      if (mounted) {
        setState(() {
          _isPlaying = _audioService.isPlaying(widget.sound.id);
        });
      }
    });
  }

  @override
  void dispose() {
    _audioSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sound.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // 声音图标
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    child: Icon(
                      widget.sound.icon,
                      size: 80,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    widget.sound.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
          ),

          // 播放控制
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                // 音量控制
                _buildVolumeSlider(),
                const SizedBox(height: 24),
                // 播放按钮
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FloatingActionButton.small(
                      heroTag: 'stop',
                      onPressed: () async {
                        final currentContext = context;
                        await _audioService.stop(widget.sound.id);
                        if (!mounted) return;
                        // ignore: use_build_context_synchronously
                        Navigator.pop(currentContext);
                      },
                      child: const Icon(Icons.stop),
                    ),
                    const SizedBox(width: 24),
                    FloatingActionButton.large(
                      heroTag: 'play',
                      onPressed: () => _audioService.toggle(widget.sound.id),
                      child: Icon(
                        _isPlaying
                            ? Icons.pause
                            : Icons.play_arrow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVolumeSlider() {
    final info = _audioService.playingList.firstWhere(
      (i) => i.id == widget.sound.id,
      orElse: () => PlayingInfo(
        id: widget.sound.id,
        url: widget.sound.url,
        name: widget.sound.name,
        player: AudioPlayer(),
        volume: 1.0,
      ),
    );

    return Row(
      children: [
        const Icon(Icons.volume_down),
        const SizedBox(width: 12),
        Expanded(
          child: Slider(
            value: info.volume,
            min: 0,
            max: 1,
            onChanged: (value) =>
                _audioService.setVolume(widget.sound.id, value),
          ),
        ),
        const SizedBox(width: 12),
        const Icon(Icons.volume_up),
      ],
    );
  }
}
