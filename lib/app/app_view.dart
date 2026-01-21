import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:xmsleepx/app/state_mgmt/sound_manager.dart';
import 'package:xmsleepx/app/theme.dart';
import 'package:xmsleepx/timed_off/timed_off_page_view.dart';
import 'package:xmsleepx/ui/home/home_page.dart';
import 'package:xmsleepx/ui/settings/settings_page.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = AppTheme.defaultSeedColor;
  bool _useDynamicColor = false;
  bool _useBlackBackground = false;

  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
  }

  @override
  void dispose() {
    SoundManager.i.dispose();
    super.dispose();
  }

  Future<void> _loadThemeSettings() async {
    final mode = await AppTheme.getThemeMode();
    final seedColor = await AppTheme.getSeedColor();
    final useDynamicColor = await AppTheme.getUseDynamicColor();
    final useBlackBackground = await AppTheme.getUseBlackBackground();

    if (mounted) {
      setState(() {
        _themeMode = mode;
        _seedColor = seedColor;
        _useDynamicColor = useDynamicColor;
        _useBlackBackground = useBlackBackground;
      });
    }
  }

  Future<void> _updateTheme() async {
    await _loadThemeSettings();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: SoundManager.i,
      child: MaterialApp(
        title: 'XMSleepX',
        theme: _useDynamicColor
            ? ThemeData.light(useMaterial3: true)
            : ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: _seedColor,
                  brightness: Brightness.light,
                ),
              ),
        darkTheme: _useDynamicColor
            ? ThemeData.dark(useMaterial3: true)
            : ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: _seedColor,
                  brightness: _useBlackBackground
                      ? Brightness.dark
                      : Brightness.dark,
                  surface: _useBlackBackground ? Colors.black : null,
                ),
              ),
        themeMode: _themeMode,
        home: MainPage(onThemeChanged: _updateTheme),
      ),
    );
  }
}

class MainPage extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const MainPage({super.key, required this.onThemeChanged});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  List<Widget> get _pages => [
    const HomePage(),
    const TimedOffPageView(),
    SettingsPage(onThemeChanged: widget.onThemeChanged),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.my_library_music_outlined),
            selectedIcon: Icon(Icons.my_library_music),
            label: '声音',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer),
            label: '定时关闭',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}
