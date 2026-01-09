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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'XMSleepX',
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          '助眠音效',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return FilterChip(
            selected: isSelected,
            label: Text(_categories[index]),
            selectedColor: Theme.of(context).colorScheme.primary,
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
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.9,
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

class SoundCard extends StatelessWidget {
  final Sound sound;

  const SoundCard({super.key, required this.sound});

  @override
  Widget build(BuildContext context) {
    final isPlaying = AudioService().isPlaying(sound.id);

    return Card(
      elevation: isPlaying ? 4 : 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PlayerPage(sound: sound)),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    sound.icon,
                    size: 36,
                    color: isPlaying
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  if (isPlaying)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                sound.name,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PlayingListSheet extends StatelessWidget {
  final AudioService audioService;

  const PlayingListSheet({super.key, required this.audioService});

  @override
  Widget build(BuildContext context) {
    final playingList = audioService.playingList;

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
                    await audioService.stopAll();
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
                              onPressed: () => audioService.toggle(info.id),
                            ),
                            IconButton(
                              icon: const Icon(Icons.stop),
                              onPressed: () => audioService.stop(info.id),
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
