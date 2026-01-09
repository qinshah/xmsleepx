import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/sound.dart';
import '../../services/audio_service.dart';
import '../player/player_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AudioService _audioService = AudioService();
  int _selectedCategory = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSounds();
  }

  Future<void> _loadSounds() async {
    await Sound.scanAssets();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<String> get _categories => Sound.getCategories();

  List<Sound> get _filteredSounds {
    if (_isLoading) return [];
    final category = _selectedCategory == 0
        ? '全部'
        : _categories[_selectedCategory];
    return Sound.getByCategory(category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 16),
              _buildCategories(),
              const SizedBox(height: 16),
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildSoundsGrid(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showPlayingList(context),
        child: const Icon(Icons.list),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'XMSleepX',
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '助眠音效',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.3),
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Container(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 4),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return FilterChip(
            selected: isSelected,
            label: Text(
              _categories[index],
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            selectedColor: Theme.of(context).colorScheme.primary,
            checkmarkColor: Theme.of(context).colorScheme.onPrimary,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            side: BorderSide(
              color: isSelected 
                  ? Theme.of(context).colorScheme.primary 
                  : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              width: 1,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? index : 0;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildSoundsGrid() {
    return Expanded(
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.0,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _filteredSounds.length,
        itemBuilder: (context, index) {
          final sound = _filteredSounds[index];
          return SoundCard(sound: sound);
        },
      ),
    );
  }

  void _showPlayingList(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return PlayingListSheet(audioService: _audioService);
      },
    );
  }
}

class SoundCard extends StatefulWidget {
  final Sound sound;

  const SoundCard({super.key, required this.sound});

  @override
  State<SoundCard> createState() => _SoundCardState();
}

class _SoundCardState extends State<SoundCard> {
  final AudioService _audioService = AudioService();
  late StreamSubscription _audioSubscription;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _isPlaying = _audioService.isPlaying(widget.sound.id);
    
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
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _isPlaying 
              ? [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.primary.withOpacity(0.05),
                ]
              : [
                  Theme.of(context).colorScheme.surface,
                  Theme.of(context).colorScheme.surface,
                ],
        ),
        border: Border.all(
          color: _isPlaying 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
              : Theme.of(context).colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isPlaying 
                ? Theme.of(context).colorScheme.primary.withOpacity(0.2)
                : Colors.black.withOpacity(0.05),
            blurRadius: _isPlaying ? 8 : 4,
            offset: Offset(0, _isPlaying ? 4 : 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PlayerPage(sound: widget.sound)),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _isPlaying
                                ? [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary.withOpacity(0.7),
                                  ]
                                : [
                                    Theme.of(context).colorScheme.surfaceVariant,
                                    Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.8),
                                  ],
                          ),
                        ),
                        child: Icon(
                          widget.sound.icon,
                          size: 30,
                          color: _isPlaying
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (_isPlaying)
                        Positioned(
                          top: 0,
                          right: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      // 快速播放/暂停按钮
                      Positioned(
                        bottom: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () {
                            _audioService.toggle(widget.sound.id);
                          },
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 2,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.sound.name,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: _isPlaying ? FontWeight.w600 : FontWeight.w500,
                    color: _isPlaying 
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurface,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.sound.category,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class PlayingListSheet extends StatefulWidget {
  final AudioService audioService;

  const PlayingListSheet({super.key, required this.audioService});

  @override
  State<PlayingListSheet> createState() => _PlayingListSheetState();
}

class _PlayingListSheetState extends State<PlayingListSheet> {
  late StreamSubscription _audioSubscription;

  @override
  void initState() {
    super.initState();
    
    // 监听音频状态变化
    _audioSubscription = widget.audioService.onChange.listen((_) {
      if (mounted) {
        setState(() {});
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
    final playingList = widget.audioService.playingList;

    return SizedBox(
      height: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Theme.of(context).dividerColor),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('正在播放', style: Theme.of(context).textTheme.titleLarge),
                TextButton(
                  onPressed: () async {
                    await widget.audioService.stopAll();
                    if (context.mounted) Navigator.pop(context);
                  },
                  child: const Text('全部停止'),
                ),
              ],
            ),
          ),
          Expanded(
            child: playingList.isEmpty
                ? Center(child: Text('暂无正在播放的音频'))
                : ListView.builder(
                    itemCount: playingList.length,
                    itemBuilder: (context, idx) {
                      final info = playingList[idx];
                      return ListTile(
                        leading: Icon(Icons.audiotrack),
                        title: Text(info.name),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                info.isPlaying ? Icons.pause : Icons.play_arrow,
                              ),
                              onPressed: () => widget.audioService.toggle(info.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop),
                              onPressed: () => widget.audioService.stop(info.id),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
