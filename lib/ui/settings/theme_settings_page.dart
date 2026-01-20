import 'package:flutter/material.dart';
import '../../app/theme.dart';

class ThemeSettingsPage extends StatefulWidget {
  final VoidCallback? onThemeChanged;
  const ThemeSettingsPage({super.key, this.onThemeChanged});

  @override
  State<ThemeSettingsPage> createState() => _ThemeSettingsPageState();
}

class _ThemeSettingsPageState extends State<ThemeSettingsPage> {
  ThemeMode _themeMode = ThemeMode.system;
  Color _selectedColor = AppTheme.defaultSeedColor;
  bool _useDynamicColor = false;
  bool _useBlackBackground = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final themeMode = await AppTheme.getThemeMode();
    final selectedColor = await AppTheme.getSeedColor();
    final useDynamicColor = await AppTheme.getUseDynamicColor();
    final useBlackBackground = await AppTheme.getUseBlackBackground();

    if (mounted) {
      setState(() {
        _themeMode = themeMode;
        _selectedColor = selectedColor;
        _useDynamicColor = useDynamicColor;
        _useBlackBackground = useBlackBackground;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('主题与色彩'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildSectionHeader('外观模式'),
                _buildThemeModeSelector(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('主题设置'),
                _buildDynamicColorSwitch(),
                const SizedBox(height: 16),
                _buildBlackBackgroundSwitch(),
                const SizedBox(height: 24),
                
                _buildSectionHeader('调色板'),
                _buildColorPalette(),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildThemeModeSelector() {
    return Container(
      height: 180,
      child: Row(
        children: [
          Expanded(child: _buildThemeOption(ThemeMode.light, '浅色模式', Icons.light_mode)),
          const SizedBox(width: 16),
          Expanded(child: _buildThemeOption(ThemeMode.dark, '深色模式', Icons.dark_mode)),
          const SizedBox(width: 16),
          Expanded(child: _buildThemeOption(ThemeMode.system, '跟随系统', Icons.brightness_auto)),
        ],
      ),
    );
  }

  Widget _buildThemeOption(ThemeMode mode, String title, IconData icon) {
    final isSelected = _themeMode == mode;
    return GestureDetector(
      onTap: () async {
        await AppTheme.setThemeMode(mode);
        setState(() {
          _themeMode = mode;
        });
        widget.onThemeChanged?.call();
      },
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: isSelected 
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected 
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withOpacity(0.2),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surfaceVariant,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isSelected 
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.outline.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                      Icons.check,
                      size: 12,
                      color: Theme.of(context).colorScheme.primary,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDynamicColorSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.palette,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          '动态颜色',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '使用壁纸颜色作为主题',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: _useDynamicColor,
          onChanged: (value) async {
            await AppTheme.setUseDynamicColor(value);
            setState(() {
              _useDynamicColor = value;
            });
            widget.onThemeChanged?.call();
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildBlackBackgroundSwitch() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Icon(
          Icons.contrast,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          '高对比度',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '在深色模式下使用纯黑背景',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: _useBlackBackground,
          onChanged: (value) async {
            await AppTheme.setUseBlackBackground(value);
            setState(() {
              _useBlackBackground = value;
            });
            widget.onThemeChanged?.call();
          },
          activeColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildColorPalette() {
    return Opacity(
      opacity: _useDynamicColor ? 0.5 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '选择主题色',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: _useDynamicColor 
                  ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: AppTheme.presetColors.map((color) {
              final isSelected = _selectedColor == color && !_useDynamicColor;
              return GestureDetector(
                onTap: _useDynamicColor ? null : () async {
                  await AppTheme.setSeedColor(color);
                  setState(() {
                    _selectedColor = color;
                  });
                  widget.onThemeChanged?.call();
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                  child: isSelected
                      ? Icon(
                          Icons.check,
                          color: _getContrastColor(color),
                          size: 24,
                        )
                      : null,
                ),
              );
            }).toList(),
          ),
          if (_useDynamicColor)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '使用动态颜色时无法手动选择主题色',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getContrastColor(Color color) {
    // 计算颜色亮度，返回对比色
    final luminance = color.computeLuminance();
    return luminance > 0.5 ? Colors.black : Colors.white;
  }
}
