import 'package:flutter/material.dart';

import '../../config/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader('外观'),
          _buildThemeTile(context),
          const Divider(),
          _buildSectionHeader('播放'),
          _buildSwitchTile(
            icon: Icons.repeat,
            title: '循环播放',
            subtitle: '自动重复播放当前声音',
          ),
          _buildSwitchTile(
            icon: Icons.timer,
            title: '睡眠定时',
            subtitle: '设置自动停止播放的时间',
          ),
          const Divider(),
          _buildSectionHeader('关于'),
          _buildListTile(
            icon: Icons.info,
            title: '版本',
            subtitle: '1.0.0',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.privacy_tip,
            title: '隐私政策',
            onTap: () {},
          ),
          _buildListTile(
            icon: Icons.description,
            title: '使用条款',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildThemeTile(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.palette),
      title: const Text('主题模式'),
      subtitle: const Text('跟随系统'),
      onTap: () => _showThemeDialog(context),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(value: true, onChanged: (_) {}),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
      trailing: const Icon(Icons.chevron_right),
    );
  }

  void _showThemeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('选择主题'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.brightness_auto),
                title: const Text('跟随系统'),
                onTap: () {
                  AppTheme.setThemeMode(ThemeMode.system);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.light_mode),
                title: const Text('浅色模式'),
                onTap: () {
                  AppTheme.setThemeMode(ThemeMode.light);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode),
                title: const Text('深色模式'),
                onTap: () {
                  AppTheme.setThemeMode(ThemeMode.dark);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
