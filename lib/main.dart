import 'package:flutter/material.dart';

import 'config/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'XMSleepX',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: AppTheme.getThemeMode(),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategory = 0;
  final List<String> _categories = ['全部', '自然', '环境', '冥想', '白噪音'];

  // 示例数据
  final List<Map<String, dynamic>> _sounds = [
    {'id': 'rain', 'name': '雨声', 'category': '自然', 'icon': Icons.water_drop},
    {'id': 'thunder', 'name': '雷声', 'category': '自然', 'icon': Icons.thunderstorm},
    {'id': 'wind', 'name': '风声', 'category': '自然', 'icon': Icons.air},
    {'id': 'ocean', 'name': '海浪', 'category': '自然', 'icon': Icons.waves},
    {'id': 'forest', 'name': '森林', 'category': '自然', 'icon': Icons.park},
    {'id': 'river', 'name': '溪流', 'category': '自然', 'icon': Icons.water},
    {'id': 'fire', 'name': '篝火', 'category': '环境', 'icon': Icons.local_fire_department},
    {'id': 'night', 'name': '夜晚', 'category': '环境', 'icon': Icons.nights_stay},
    {'id': 'white_noise', 'name': '白噪音', 'category': '白噪音', 'icon': Icons.graphic_eq},
    {'id': 'pink_noise', 'name': '粉红噪音', 'category': '白噪音', 'icon': Icons.equalizer},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildCategories(),
              const SizedBox(height: 20),
              _buildSoundsGrid(),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '晚安',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            Text(
              '好梦',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: () {},
        ),
      ],
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final isSelected = _selectedCategory == index;
          return FilterChip(
            selected: isSelected,
            label: Text(_categories[index]),
            selectedColor: Theme.of(context).colorScheme.primary,
            onSelected: (selected) {
              setState(() {
                _selectedCategory = selected ? index : -1;
              });
            },
          );
        },
      ),
    );
  }

  Widget _buildSoundsGrid() {
    final filteredSounds = _selectedCategory == 0
        ? _sounds
        : _sounds.where((s) => s['category'] == _categories[_selectedCategory]).toList();

    return Expanded(
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: filteredSounds.length,
        itemBuilder: (context, index) {
          final sound = filteredSounds[index];
          return SoundCard(
            id: sound['id'] as String,
            name: sound['name'] as String,
            icon: sound['icon'] as IconData,
            category: sound['category'] as String,
          );
        },
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return NavigationBar(
      selectedIndex: 0,
      onDestinationSelected: (index) {},
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: '首页',
        ),
        NavigationDestination(
          icon: Icon(Icons.favorite_outline),
          selectedIcon: Icon(Icons.favorite),
          label: '收藏',
        ),
        NavigationDestination(
          icon: Icon(Icons.timer_outlined),
          selectedIcon: Icon(Icons.timer),
          label: '定时',
        ),
      ],
    );
  }
}

class SoundCard extends StatelessWidget {
  final String id;
  final String name;
  final IconData icon;
  final String category;

  const SoundCard({
    super.key,
    required this.id,
    required this.name,
    required this.icon,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 48,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 12),
              Text(
                name,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
