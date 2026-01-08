import 'package:flutter/material.dart';

class Sound {
  final String id;
  final String name;
  final String url;
  final String category;
  final IconData icon;
  final String? description;

  Sound({
    required this.id,
    required this.name,
    required this.url,
    required this.category,
    required this.icon,
    this.description,
  });

  /// 默认声音列表
  static List<Sound> defaultSounds() {
    return [
      // 自然声音
      Sound(
        id: 'rain',
        name: '雨声',
        url: 'assets/sounds/rain.mp3',
        category: '自然',
        icon: Icons.water_drop,
        description: '舒缓的雨声',
      ),
      Sound(
        id: 'thunder',
        name: '雷声',
        url: 'assets/sounds/thunder.mp3',
        category: '自然',
        icon: Icons.thunderstorm,
        description: '温暖的雷声',
      ),
      Sound(
        id: 'wind',
        name: '风声',
        url: 'assets/sounds/wind.mp3',
        category: '自然',
        icon: Icons.air,
        description: '轻柔的风声',
      ),
      Sound(
        id: 'ocean',
        name: '海浪',
        url: 'assets/sounds/ocean.mp3',
        category: '自然',
        icon: Icons.waves,
        description: '海浪拍打声',
      ),
      Sound(
        id: 'forest',
        name: '森林',
        url: 'assets/sounds/forest.mp3',
        category: '自然',
        icon: Icons.park,
        description: '森林鸟鸣',
      ),
      Sound(
        id: 'river',
        name: '溪流',
        url: 'assets/sounds/river.mp3',
        category: '自然',
        icon: Icons.water,
        description: '溪水流动声',
      ),
      // 环境声音
      Sound(
        id: 'fire',
        name: '篝火',
        url: 'assets/sounds/fire.mp3',
        category: '环境',
        icon: Icons.local_fire_department,
        description: '篝火噼啪声',
      ),
      Sound(
        id: 'night',
        name: '夜晚',
        url: 'assets/sounds/night.mp3',
        category: '环境',
        icon: Icons.nights_stay,
        description: '夜晚虫鸣',
      ),
      // 白噪音
      Sound(
        id: 'white_noise',
        name: '白噪音',
        url: 'assets/sounds/white_noise.mp3',
        category: '白噪音',
        icon: Icons.graphic_eq,
        description: '纯白噪音',
      ),
      Sound(
        id: 'pink_noise',
        name: '粉红噪音',
        url: 'assets/sounds/pink_noise.mp3',
        category: '白噪音',
        icon: Icons.equalizer,
        description: '柔和粉红噪音',
      ),
      Sound(
        id: 'brown_noise',
        name: '布朗噪音',
        url: 'assets/sounds/brown_noise.mp3',
        category: '白噪音',
        icon: Icons.graphic_eq,
        description: '深沉布朗噪音',
      ),
    ];
  }

  /// 从 JSON 创建
  factory Sound.fromJson(Map<String, dynamic> json) {
    return Sound(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      category: json['category'] as String,
      icon: IconData(json['iconCode'] as int, fontFamily: 'MaterialIcons'),
      description: json['description'] as String?,
    );
  }

  /// 转换为 JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'url': url,
      'category': category,
      'iconCode': icon.codePoint,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Sound && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
