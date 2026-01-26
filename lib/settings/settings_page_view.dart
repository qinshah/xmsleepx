import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:niceleep/app/state_mgmt/sound_manager.dart';
import 'package:niceleep/settings/state_mgmt/theme_cntlr.dart';
import 'package:provider/provider.dart';
import 'theme_page_view.dart';

class SettingsPageView extends StatefulWidget {
  const SettingsPageView({super.key});

  @override
  State<SettingsPageView> createState() => _SettingsPageViewState();
}

class _SettingsPageViewState extends State<SettingsPageView> {
  bool _hideAnimation = false;
  String _version = '1.0.0';
  double _globalVolume = 0.5; // 默认音量50%
  bool _isClearingCache = false;
  int _cacheSize = 0;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = packageInfo.version;
    });
    _calculateCacheSize();
  }

  Future<void> _calculateCacheSize() async {
    setState(() {
      _isClearingCache = true;
    });

    // 模拟缓存大小计算
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _cacheSize = 1024 * 1024; // 1MB
      _isClearingCache = false;
    });
  }

  Future<void> _clearCache() async {
    setState(() {
      _isClearingCache = true;
    });

    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _cacheSize = 0;
      _isClearingCache = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('缓存已清除')));
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('外观'),
          _buildThemeTile(context),
          _buildSwitchTile(
            icon: Icons.animation,
            title: '隐藏动画',
            subtitle: '隐藏声音卡片中的动画效果',
            value: _hideAnimation,
            onChanged: (value) {
              setState(() {
                _hideAnimation = value;
              });
            },
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('系统'),
          _buildListTile(
            icon: Icons.language,
            title: '语言',
            subtitle: '简体中文',
            onTap: () => _showLanguageSelectionDialog(context),
          ),
          _buildVolumeTile(context),
          _buildListTile(
            icon: Icons.cleaning_services,
            title: '清除缓存',
            subtitle: _isClearingCache ? '正在清除...' : _formatBytes(_cacheSize),
            onTap: () => _showCacheClearDialog(context),
          ),
          const SizedBox(height: 24),

          _buildSectionHeader('其他'),
          _buildListTile(
            icon: Icons.info,
            title: '版本',
            subtitle: _version,
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: '隐私政策',
            onTap: () => _launchUrl('https://example.com/privacy'),
          ),
          _buildListTile(
            icon: Icons.description,
            title: '使用条款',
            onTap: () => _launchUrl('https://example.com/terms'),
          ),
          _buildListTile(
            icon: Icons.feedback,
            title: '意见反馈',
            onTap: () => _launchUrl('https://example.com/feedback'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4, top: 8),
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

  Widget _buildThemeTile(BuildContext context) {
    return Consumer<ThemeCntlr>(
      builder: (context, themeCntlr, child) {
        return Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            ),
          ),
          child: ListTile(
            leading: Icon(
              Icons.palette,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(
              '主题模式',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
            subtitle: Text(
              _getThemeModeText(themeCntlr.themeMode),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ThemePageView(),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
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
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Switch(
          value: value,
          onChanged: onChanged,
          activeThumbColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
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
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              )
            : null,
        trailing: onTap != null
            ? Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              )
            : null,
        onTap: onTap,
      ),
    );
  }

  Widget _buildVolumeTile(BuildContext context) {
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
          Icons.volume_up,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        title: Text(
          '调整所有音量',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          '统一调整所有正在播放声音的音量',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: Text(
          '${(_globalVolume * 100).round()}%',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () => _showVolumeAdjustDialog(context),
      ),
    );
  }

  String _getThemeModeText(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色模式';
      case ThemeMode.dark:
        return '深色模式';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  void _showLanguageSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择语言'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('简体中文'),
                trailing: const Icon(Icons.check, color: Colors.blue),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  void _showVolumeAdjustDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        double inDialogVolume = _globalVolume;
        return AlertDialog(
          title: const Text('调整所有音量'),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('应用到所有正在播放的声音'),
                  const SizedBox(height: 16),
                  Slider(
                    value: inDialogVolume,
                    min: 0.0,
                    max: 1.0,
                    divisions: 20,
                    onChanged: (value) {
                      setDialogState(() => inDialogVolume = value);
                      // 实时更新全局音量
                      SoundManager.i.setAllVolume(value);
                      setState(() => _globalVolume = value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('0%'),
                      Text('${(inDialogVolume * 100).round()}%'),
                      const Text('100%'),
                    ],
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void _showCacheClearDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('清除缓存'),
          content: const Text('确定要清除所有缓存数据吗？这将删除所有临时文件。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearCache();
              },
              child: const Text('确定'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
