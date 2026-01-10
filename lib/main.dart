import 'package:flutter/material.dart';

import 'config/theme.dart';
import 'ui/home/home_page.dart';
import 'ui/settings/settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _seedColor = AppTheme.defaultSeedColor;
  bool _useDynamicColor = false;
  bool _useBlackBackground = false;
  
  @override
  void initState() {
    super.initState();
    _loadThemeSettings();
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
    return MaterialApp(
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
                brightness: _useBlackBackground ? Brightness.dark : Brightness.dark,
                surface: _useBlackBackground ? Colors.black : null,
              ),
            ),
      themeMode: _themeMode,
      home: MainPage(
        onThemeChanged: _updateTheme,
      ),
      debugShowCheckedModeBanner: false,
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
            icon: Icon(Icons.local_florist_outlined),
            selectedIcon: Icon(Icons.local_florist),
            label: '白噪音',
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
