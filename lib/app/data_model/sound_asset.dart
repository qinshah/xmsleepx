import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class SoundAsset {
  final String id;
  final String name;
  final String path;
  final String category;
  final IconData icon;
  final String? description;

  SoundAsset({
    required this.id,
    required this.name,
    required this.path,
    required this.category,
    required this.icon,
    this.description,
  });

  /// 所有音频分类
  static const Map<String, IconData> categoryIcons = {
    'rain': Icons.water_drop,
    'nature': Icons.park,
    'noise': Icons.graphic_eq,
    'music': Icons.music_note,
    'urban': Icons.location_city,
    'places': Icons.place,
    'transport': Icons.directions_transit,
    'animals': Icons.pets,
    'things': Icons.toys,
  };

  /// 所有音频分类名称映射
  static const Map<String, String> categoryNames = {
    'rain': '雨声',
    'nature': '自然',
    'noise': '白噪音',
    'music': '音乐',
    'urban': '城市',
    'places': '场所',
    'transport': '交通',
    'animals': '动物',
    'things': '物品',
  };

  /// 所有音频文件列表
  static List<SoundAsset> allSounds = [];

  /// 已扫描的路径缓存
  static final Set<String> _scannedPaths = {};

  /// 初始化扫描所有音频文件
  static Future<void> scanAssets() async {
    // 使用 compute 将扫描操作放到 isolate 中
    allSounds = await compute(_scanAssetsDirectoryIsolate, 'assets/sounds');
  }

  /// 在 isolate 中扫描 assets 目录
  static Future<List<SoundAsset>> _scanAssetsDirectoryIsolate(
    String path,
  ) async {
    return await _scanAssetsDirectory(path);
  }

  /// 扫描 assets 目录下的所有音频文件，并对 AssetManifest 做更健壮的解析
  static Future<List<SoundAsset>> _scanAssetsDirectory(String path) async {
    final sounds = <SoundAsset>[];

    // 防止重复扫描
    if (_scannedPaths.contains(path)) {
      return sounds;
    }
    _scannedPaths.add(path);

    try {
      // 首先尝试直接使用硬编码列表（避免 AssetManifest.json 解析的卡顿）
      if (_fallbackSounds.isNotEmpty) {
        return _fallbackSounds;
      }

      // 如果硬编码列表为空，再尝试解析 AssetManifest
      final manifest = await rootBundle.loadString('AssetManifest.json');

      // 兼容 AssetManifest 的不同结构（有时候是 Map，有时候是 List）
      Map<String, dynamic> manifestMap = {};
      try {
        final decoded = jsonDecode(manifest);
        if (decoded is Map<String, dynamic>) {
          manifestMap = decoded;
        } else if (decoded is Map) {
          manifestMap = Map<String, dynamic>.from(decoded);
        }
      } catch (e) {
        manifestMap = {};
      }

      dynamic assetsObj = manifestMap['assets'];
      List<String> assetPaths = [];
      if (assetsObj is Map<String, dynamic>) {
        assetPaths = assetsObj.keys.toList();
      } else if (assetsObj is List) {
        assetPaths = List<String>.from(assetsObj.map((e) => e.toString()));
      }

      if (assetPaths.isNotEmpty) {
        // 获取所有音频文件路径
        final audioExtensions = ['.mp3', '.ogg', '.wav'];

        for (final p in assetPaths) {
          final String pathItem = p;
          if (!pathItem.startsWith('assets/sounds/')) continue;

          final extIndex = pathItem.lastIndexOf('.');
          if (extIndex == -1) continue;
          final ext = pathItem.substring(extIndex).toLowerCase();
          if (audioExtensions.contains(ext)) {
            final sound = _pathToSound(pathItem);
            if (sound != null) {
              sounds.add(sound);
            }
          }
        }
      }
    } catch (e) {
      // 如果无法加载 AssetManifest.json，回退到硬编码列表
      debugPrint('无法加载 AssetManifest.json: $e');
    }

    // If manifest exists but no sounds found, fall back to built-in samples
    if (sounds.isEmpty) {
      sounds.addAll(_fallbackSounds);
    }

    return sounds;
  }

  /// Android版本繁星页的16个声音（按顺序排列）
  static final List<SoundAsset> _androidStarSounds = [
    // 1. 伞上雨声
    SoundAsset(
      id: 'rain_umbrella_rain',
      name: '伞上雨声',
      path: 'assets/sounds/rain/rain-on-umbrella.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    // 2. 划船
    SoundAsset(
      id: 'transport_rowing_boat',
      name: '划船',
      path: 'assets/sounds/transport/rowing-boat.mp3',
      category: '交通',
      icon: Icons.sailing,
    ),
    // 3. 办公室
    SoundAsset(
      id: 'places_office',
      name: '办公室',
      path: 'assets/sounds/places/office.mp3',
      category: '场所',
      icon: Icons.computer,
    ),
    // 4. 图书馆
    SoundAsset(
      id: 'places_library',
      name: '图书馆',
      path: 'assets/sounds/places/library.mp3',
      category: '场所',
      icon: Icons.library_books,
    ),
    // 5. 大雨
    SoundAsset(
      id: 'rain_heavy_rain',
      name: '大雨',
      path: 'assets/sounds/rain/heavy_rain.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    // 6. 打字机
    SoundAsset(
      id: 'things_typewriter',
      name: '打字机',
      path: 'assets/sounds/things/typewriter.mp3',
      category: '物品',
      icon: Icons.keyboard,
    ),
    // 7. 打雷
    SoundAsset(
      id: 'rain_thunderstorm',
      name: '打雷',
      path: 'assets/sounds/rain/thunderstorm.ogg',
      category: '雨声',
      icon: Icons.thunderstorm,
    ),
    // 8. 时钟
    SoundAsset(
      id: 'things_clock',
      name: '时钟',
      path: 'assets/sounds/things/clock.mp3',
      category: '物品',
      icon: Icons.access_time,
    ),
    // 9. 森林鸟鸣
    SoundAsset(
      id: 'animals_birds',
      name: '森林鸟鸣',
      path: 'assets/sounds/animals/birds.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    // 10. 漂流
    SoundAsset(
      id: 'transport_sailboat',
      name: '漂流',
      path: 'assets/sounds/transport/sailboat.mp3',
      category: '交通',
      icon: Icons.sailing,
    ),
    // 11. 篝火
    SoundAsset(
      id: 'nature_campfire',
      name: '篝火',
      path: 'assets/sounds/nature/campfire.ogg',
      category: '自然',
      icon: Icons.local_fire_department,
    ),
    // 12. 起风了
    SoundAsset(
      id: 'nature_wind',
      name: '起风了',
      path: 'assets/sounds/nature/wind.ogg',
      category: '自然',
      icon: Icons.air,
    ),
    // 13. 键盘
    SoundAsset(
      id: 'things_keyboard',
      name: '键盘',
      path: 'assets/sounds/things/keyboard.mp3',
      category: '物品',
      icon: Icons.keyboard,
    ),
    // 14. 雪地徒步
    SoundAsset(
      id: 'nature_walk_in_snow',
      name: '雪地徒步',
      path: 'assets/sounds/nature/walk-in-snow.ogg',
      category: '自然',
      icon: Icons.ac_unit,
    ),
    // 15. 早晨咖啡
    SoundAsset(
      id: 'places_cafe',
      name: '早晨咖啡',
      path: 'assets/sounds/places/cafe.mp3',
      category: '场所',
      icon: Icons.local_cafe,
    ),
    // 16. 吊扇
    SoundAsset(
      id: 'things_ceiling_fan',
      name: '吊扇',
      path: 'assets/sounds/things/ceiling-fan.mp3',
      category: '物品',
      icon: Icons.air,
    ),
  ];

  /// 完整的音频列表（按Android版本order顺序排列）
  static final List<SoundAsset> _fallbackSounds = [
    // 自然声音 (按Android版本order顺序)
    SoundAsset(
      id: 'nature_river',
      name: '河流',
      path: 'assets/sounds/nature/river.ogg',
      category: '自然',
      icon: Icons.water,
    ),
    SoundAsset(
      id: 'nature_waves',
      name: '海浪',
      path: 'assets/sounds/nature/waves.ogg',
      category: '自然',
      icon: Icons.waves,
    ),
    SoundAsset(
      id: 'nature_campfire',
      name: '篝火',
      path: 'assets/sounds/nature/campfire.ogg',
      category: '自然',
      icon: Icons.local_fire_department,
    ),
    SoundAsset(
      id: 'nature_wind',
      name: '风声',
      path: 'assets/sounds/nature/wind.ogg',
      category: '自然',
      icon: Icons.air,
    ),
    SoundAsset(
      id: 'nature_howling_wind',
      name: '呼啸的风',
      path: 'assets/sounds/nature/howling-wind.ogg',
      category: '自然',
      icon: Icons.air,
    ),
    SoundAsset(
      id: 'nature_wind_in_trees',
      name: '树间风声',
      path: 'assets/sounds/nature/wind-in-trees.ogg',
      category: '自然',
      icon: Icons.terrain,
    ),
    SoundAsset(
      id: 'nature_waterfall',
      name: '瀑布',
      path: 'assets/sounds/nature/waterfall.ogg',
      category: '自然',
      icon: Icons.water,
    ),
    SoundAsset(
      id: 'nature_walk_in_snow',
      name: '雪中行走',
      path: 'assets/sounds/nature/walk-in-snow.ogg',
      category: '自然',
      icon: Icons.ac_unit,
    ),
    SoundAsset(
      id: 'nature_walk_on_leaves',
      name: '踩踏树叶',
      path: 'assets/sounds/nature/walk-on-leaves.ogg',
      category: '自然',
      icon: Icons.grass,
    ),
    SoundAsset(
      id: 'nature_walk_on_gravel',
      name: '踩踏碎石',
      path: 'assets/sounds/nature/walk-on-gravel.ogg',
      category: '自然',
      icon: Icons.directions_walk,
    ),
    SoundAsset(
      id: 'nature_droplets',
      name: '水滴',
      path: 'assets/sounds/nature/droplets.ogg',
      category: '自然',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'nature_jungle',
      name: '丛林',
      path: 'assets/sounds/nature/jungle.ogg',
      category: '自然',
      icon: Icons.park,
    ),
    SoundAsset(
      id: 'music_field',
      name: '田野',
      path: 'assets/sounds/music/田野.mp3',
      category: '音乐',
      icon: Icons.music_note,
    ),
    // 雨声 (按Android版本order顺序)
    SoundAsset(
      id: 'rain_light_rain',
      name: '小雨',
      path: 'assets/sounds/rain/light-rain.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_heavy_rain',
      name: '大雨',
      path: 'assets/sounds/rain/heavy_rain.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_car_roof',
      name: '车顶雨声',
      path: 'assets/sounds/rain/rain-on-car-roof.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_umbrella',
      name: '伞上雨声',
      path: 'assets/sounds/rain/rain-on-umbrella.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_tent',
      name: '帐篷雨声',
      path: 'assets/sounds/rain/rain-on-tent.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_leaves',
      name: '叶上雨声',
      path: 'assets/sounds/rain/rain-on-leaves.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_raincoat',
      name: '雨落雨披',
      path: 'assets/sounds/rain/rain-on-raincoat.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_windowsill',
      name: '雨打窗台',
      path: 'assets/sounds/rain/rain-on-windowsill.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_wooden_house',
      name: '雨敲木屋',
      path: 'assets/sounds/rain/rain-on-wooden-house.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_thunderstorm',
      name: '雷雨声',
      path: 'assets/sounds/rain/thunderstorm.ogg',
      category: '雨声',
      icon: Icons.thunderstorm,
    ),
    SoundAsset(
      id: 'rain_rain_while_driving',
      name: '开车时遇雨',
      path: 'assets/sounds/rain/rain-while-driving.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_empty_street',
      name: '空荡街道的雨',
      path: 'assets/sounds/rain/rain-on-empty-street.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_drizzle',
      name: '绵绵细雨',
      path: 'assets/sounds/rain/drizzle.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_rain_on_eaves',
      name: '屋檐落雨',
      path: 'assets/sounds/rain/rain-on-eaves.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    SoundAsset(
      id: 'rain_heavy_rain_on_glass',
      name: '大雨落玻璃',
      path: 'assets/sounds/rain/heavy-rain-on-glass.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),

    // 动物声音 (按Android版本order顺序)
    SoundAsset(
      id: 'animals_birds',
      name: '鸟鸣',
      path: 'assets/sounds/animals/birds.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_seagulls',
      name: '海鸥',
      path: 'assets/sounds/animals/seagulls.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_crickets',
      name: '蟋蟀',
      path: 'assets/sounds/animals/crickets.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_wolf',
      name: '狼嚎',
      path: 'assets/sounds/animals/wolf.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_owl',
      name: '猫头鹰',
      path: 'assets/sounds/animals/owl.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_frog',
      name: '青蛙',
      path: 'assets/sounds/animals/frog.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_dog_barking',
      name: '狗叫',
      path: 'assets/sounds/animals/dog-barking.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_horse_gallop',
      name: '马奔腾',
      path: 'assets/sounds/animals/horse-gallop.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_cat_purring',
      name: '猫咪呼噜',
      path: 'assets/sounds/animals/cat-purring.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_crows',
      name: '乌鸦',
      path: 'assets/sounds/animals/crows.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_whale',
      name: '鲸鱼',
      path: 'assets/sounds/animals/whale.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_beehive',
      name: '蜂巢',
      path: 'assets/sounds/animals/beehive.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_woodpecker',
      name: '啄木鸟',
      path: 'assets/sounds/animals/woodpecker.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_chickens',
      name: '鸡',
      path: 'assets/sounds/animals/chickens.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_cows',
      name: '牛',
      path: 'assets/sounds/animals/cows.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_sheep',
      name: '羊',
      path: 'assets/sounds/animals/sheep.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'noise_eating_chips',
      name: 'Eating Chips',
      path: 'assets/sounds/noise/eating-chips.ogg',
      category: '白噪音',
      icon: Icons.restaurant,
    ),
    SoundAsset(
      id: 'noise_piano',
      name: 'Piano',
      path: 'assets/sounds/noise/piano.ogg',
      category: '白噪音',
      icon: Icons.piano,
    ),
    SoundAsset(
      id: 'noise_pink_noise',
      name: 'Pink Noise',
      path: 'assets/sounds/noise/pink-noise.ogg',
      category: '白噪音',
      icon: Icons.graphic_eq,
    ),
    SoundAsset(
      id: 'noise_study',
      name: 'Study',
      path: 'assets/sounds/noise/study.ogg',
      category: '白噪音',
      icon: Icons.menu_book,
    ),
    SoundAsset(
      id: 'noise_white_noise',
      name: 'White Noise',
      path: 'assets/sounds/noise/white-noise.ogg',
      category: '白噪音',
      icon: Icons.graphic_eq,
    ),

    // Music sounds
    SoundAsset(
      id: 'music_古筝',
      name: '古筝',
      path: 'assets/sounds/music/古筝.wav',
      category: '音乐',
      icon: Icons.music_note,
    ),
    SoundAsset(
      id: 'music_吉他',
      name: '吉他',
      path: 'assets/sounds/music/吉他.wav',
      category: '音乐',
      icon: Icons.music_note,
    ),
    SoundAsset(
      id: 'music_轻钢琴',
      name: '轻钢琴',
      path: 'assets/sounds/music/轻钢琴.wav',
      category: '音乐',
      icon: Icons.music_note,
    ),
    SoundAsset(
      id: 'music_田野',
      name: '田野',
      path: 'assets/sounds/music/田野.mp3',
      category: '音乐',
      icon: Icons.music_note,
    ),

    // Urban sounds
    SoundAsset(
      id: 'urban_ambulance_siren',
      name: 'Ambulance Siren',
      path: 'assets/sounds/urban/ambulance-siren.mp3',
      category: '城市',
      icon: Icons.local_hospital,
    ),
    SoundAsset(
      id: 'urban_busy_street',
      name: 'Busy Street',
      path: 'assets/sounds/urban/busy-street.mp3',
      category: '城市',
      icon: Icons.location_city,
    ),
    SoundAsset(
      id: 'urban_crowd',
      name: 'Crowd',
      path: 'assets/sounds/urban/crowd.mp3',
      category: '城市',
      icon: Icons.people,
    ),
    SoundAsset(
      id: 'urban_fireworks',
      name: 'Fireworks',
      path: 'assets/sounds/urban/fireworks.mp3',
      category: '城市',
      icon: Icons.celebration,
    ),
    SoundAsset(
      id: 'urban_highway',
      name: 'Highway',
      path: 'assets/sounds/urban/highway.mp3',
      category: '城市',
      icon: Icons.directions_car,
    ),
    SoundAsset(
      id: 'urban_road',
      name: 'Road',
      path: 'assets/sounds/urban/road.mp3',
      category: '城市',
      icon: Icons.route,
    ),
    SoundAsset(
      id: 'urban_traffic',
      name: 'Traffic',
      path: 'assets/sounds/urban/traffic.mp3',
      category: '城市',
      icon: Icons.traffic,
    ),

    // Places sounds
    SoundAsset(
      id: 'places_airport',
      name: 'Airport',
      path: 'assets/sounds/places/airport.mp3',
      category: '场所',
      icon: Icons.flight,
    ),
    SoundAsset(
      id: 'places_cafe',
      name: 'Cafe',
      path: 'assets/sounds/places/cafe.mp3',
      category: '场所',
      icon: Icons.local_cafe,
    ),
    SoundAsset(
      id: 'places_carousel',
      name: 'Carousel',
      path: 'assets/sounds/places/carousel.mp3',
      category: '场所',
      icon: Icons.attractions,
    ),
    SoundAsset(
      id: 'places_church',
      name: 'Church',
      path: 'assets/sounds/places/church.mp3',
      category: '场所',
      icon: Icons.church,
    ),
    SoundAsset(
      id: 'places_construction_site',
      name: 'Construction Site',
      path: 'assets/sounds/places/construction-site.mp3',
      category: '场所',
      icon: Icons.construction,
    ),
    SoundAsset(
      id: 'places_crowded_bar',
      name: 'Crowded Bar',
      path: 'assets/sounds/places/crowded-bar.mp3',
      category: '场所',
      icon: Icons.local_bar,
    ),
    SoundAsset(
      id: 'places_kitchen',
      name: 'Kitchen',
      path: 'assets/sounds/places/kitchen.ogg',
      category: '场所',
      icon: Icons.kitchen,
    ),
    SoundAsset(
      id: 'places_laboratory',
      name: 'Laboratory',
      path: 'assets/sounds/places/laboratory.mp3',
      category: '场所',
      icon: Icons.science,
    ),
    SoundAsset(
      id: 'places_laundry_room',
      name: 'Laundry Room',
      path: 'assets/sounds/places/laundry-room.mp3',
      category: '场所',
      icon: Icons.local_laundry_service,
    ),
    SoundAsset(
      id: 'places_library',
      name: 'Library',
      path: 'assets/sounds/places/library.mp3',
      category: '场所',
      icon: Icons.library_books,
    ),
    SoundAsset(
      id: 'places_night_village',
      name: 'Night Village',
      path: 'assets/sounds/places/night-village.mp3',
      category: '场所',
      icon: Icons.nights_stay,
    ),
    SoundAsset(
      id: 'places_office',
      name: 'Office',
      path: 'assets/sounds/places/office.mp3',
      category: '场所',
      icon: Icons.computer,
    ),
    SoundAsset(
      id: 'places_restaurant',
      name: 'Restaurant',
      path: 'assets/sounds/places/restaurant.mp3',
      category: '场所',
      icon: Icons.restaurant,
    ),
    SoundAsset(
      id: 'places_subway_station',
      name: 'Subway Station',
      path: 'assets/sounds/places/subway-station.mp3',
      category: '场所',
      icon: Icons.train,
    ),
    SoundAsset(
      id: 'places_supermarket',
      name: 'Supermarket',
      path: 'assets/sounds/places/supermarket.mp3',
      category: '场所',
      icon: Icons.shopping_cart,
    ),
    SoundAsset(
      id: 'places_temple',
      name: 'Temple',
      path: 'assets/sounds/places/temple.mp3',
      category: '场所',
      icon: Icons.house,
    ),
    SoundAsset(
      id: 'places_underwater',
      name: 'Underwater',
      path: 'assets/sounds/places/underwater.mp3',
      category: '场所',
      icon: Icons.water,
    ),

    // Transport sounds
    SoundAsset(
      id: 'transport_airplane',
      name: 'Airplane',
      path: 'assets/sounds/transport/airplane.mp3',
      category: '交通',
      icon: Icons.flight,
    ),
    SoundAsset(
      id: 'transport_inside_a_train',
      name: 'Inside A Train',
      path: 'assets/sounds/transport/inside-a-train.mp3',
      category: '交通',
      icon: Icons.train,
    ),
    SoundAsset(
      id: 'transport_rowing_boat',
      name: 'Rowing Boat',
      path: 'assets/sounds/transport/rowing-boat.mp3',
      category: '交通',
      icon: Icons.sailing,
    ),
    SoundAsset(
      id: 'transport_sailboat',
      name: 'Sailboat',
      path: 'assets/sounds/transport/sailboat.mp3',
      category: '交通',
      icon: Icons.sailing,
    ),
    SoundAsset(
      id: 'transport_submarine',
      name: 'Submarine',
      path: 'assets/sounds/transport/submarine.mp3',
      category: '交通',
      icon: Icons.directions_boat,
    ),
    SoundAsset(
      id: 'transport_train',
      name: 'Train',
      path: 'assets/sounds/transport/train.mp3',
      category: '交通',
      icon: Icons.train,
    ),

    // Animals sounds
    SoundAsset(
      id: 'animals_beehive',
      name: 'Beehive',
      path: 'assets/sounds/animals/beehive.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_birds',
      name: 'Birds',
      path: 'assets/sounds/animals/birds.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_cat_purring',
      name: 'Cat Purring',
      path: 'assets/sounds/animals/cat-purring.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_chickens',
      name: 'Chickens',
      path: 'assets/sounds/animals/chickens.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_cows',
      name: 'Cows',
      path: 'assets/sounds/animals/cows.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_crickets',
      name: 'Crickets',
      path: 'assets/sounds/animals/crickets.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_crows',
      name: 'Crows',
      path: 'assets/sounds/animals/crows.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_dog_barking',
      name: 'Dog Barking',
      path: 'assets/sounds/animals/dog-barking.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_frog',
      name: 'Frog',
      path: 'assets/sounds/animals/frog.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_horse_gallop',
      name: 'Horse Gallop',
      path: 'assets/sounds/animals/horse-gallop.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_owl',
      name: 'Owl',
      path: 'assets/sounds/animals/owl.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_seagulls',
      name: 'Seagulls',
      path: 'assets/sounds/animals/seagulls.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_sheep',
      name: 'Sheep',
      path: 'assets/sounds/animals/sheep.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_whale',
      name: 'Whale',
      path: 'assets/sounds/animals/whale.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_wolf',
      name: 'Wolf',
      path: 'assets/sounds/animals/wolf.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    SoundAsset(
      id: 'animals_woodpecker',
      name: 'Woodpecker',
      path: 'assets/sounds/animals/woodpecker.ogg',
      category: '动物',
      icon: Icons.pets,
    ),

    // Things sounds
    SoundAsset(
      id: 'things_boiling_water',
      name: 'Boiling Water',
      path: 'assets/sounds/things/boiling-water.mp3',
      category: '物品',
      icon: Icons.kitchen,
    ),
    SoundAsset(
      id: 'things_bubbles',
      name: 'Bubbles',
      path: 'assets/sounds/things/bubbles.mp3',
      category: '物品',
      icon: Icons.ac_unit,
    ),
    SoundAsset(
      id: 'things_ceiling_fan',
      name: 'Ceiling Fan',
      path: 'assets/sounds/things/ceiling-fan.mp3',
      category: '物品',
      icon: Icons.ac_unit,
    ),
    SoundAsset(
      id: 'things_clock',
      name: 'Clock',
      path: 'assets/sounds/things/clock.mp3',
      category: '物品',
      icon: Icons.access_time,
    ),
    SoundAsset(
      id: 'things_dryer',
      name: 'Dryer',
      path: 'assets/sounds/things/dryer.mp3',
      category: '物品',
      icon: Icons.local_laundry_service,
    ),
    SoundAsset(
      id: 'things_ear_cleaning_1',
      name: 'Ear Cleaning 1',
      path: 'assets/sounds/things/ear-cleaning-1.mp3',
      category: '物品',
      icon: Icons.hearing,
    ),
    SoundAsset(
      id: 'things_ear_cleaning_2',
      name: 'Ear Cleaning 2',
      path: 'assets/sounds/things/ear-cleaning-2.mp3',
      category: '物品',
      icon: Icons.hearing,
    ),
    SoundAsset(
      id: 'things_keyboard',
      name: 'Keyboard',
      path: 'assets/sounds/things/keyboard.mp3',
      category: '物品',
      icon: Icons.keyboard,
    ),
    SoundAsset(
      id: 'things_morse_code',
      name: 'Morse Code',
      path: 'assets/sounds/things/morse-code.mp3',
      category: '物品',
      icon: Icons.code,
    ),
    SoundAsset(
      id: 'things_paper',
      name: 'Paper',
      path: 'assets/sounds/things/paper.mp3',
      category: '物品',
      icon: Icons.description,
    ),
    SoundAsset(
      id: 'things_singing_bowl',
      name: 'Singing Bowl',
      path: 'assets/sounds/things/singing-bowl.mp3',
      category: '物品',
      icon: Icons.music_note,
    ),
    SoundAsset(
      id: 'things_slide_projector',
      name: 'Slide Projector',
      path: 'assets/sounds/things/slide-projector.mp3',
      category: '物品',
      icon: Icons.slideshow,
    ),
    SoundAsset(
      id: 'things_tuning_radio',
      name: 'Tuning Radio',
      path: 'assets/sounds/things/tuning-radio.mp3',
      category: '物品',
      icon: Icons.radio,
    ),
    SoundAsset(
      id: 'things_typewriter',
      name: 'Typewriter',
      path: 'assets/sounds/things/typewriter.mp3',
      category: '物品',
      icon: Icons.keyboard,
    ),
    SoundAsset(
      id: 'things_vinyl_effect',
      name: 'Vinyl Effect',
      path: 'assets/sounds/things/vinyl-effect.mp3',
      category: '物品',
      icon: Icons.album,
    ),
    SoundAsset(
      id: 'things_washing_machine',
      name: 'Washing Machine',
      path: 'assets/sounds/things/washing-machine.mp3',
      category: '物品',
      icon: Icons.local_laundry_service,
    ),
    SoundAsset(
      id: 'things_wind_chimes',
      name: 'Wind Chimes',
      path: 'assets/sounds/things/wind-chimes.mp3',
      category: '物品',
      icon: Icons.music_note,
    ),
    SoundAsset(
      id: 'things_windshield_wipers',
      name: 'Windshield Wipers',
      path: 'assets/sounds/things/windshield-wipers.mp3',
      category: '物品',
      icon: Icons.ac_unit,
    ),
  ];

  /// 将文件路径转换为 Sound 对象
  static SoundAsset? _pathToSound(String path) {
    // 解析路径: assets/sounds/rain/heavy_rain.ogg
    final parts = path.replaceFirst('assets/sounds/', '').split('/');
    if (parts.length < 2) return null;

    final category = parts[0];
    final filename = parts[1].replaceAll(RegExp(r'\.(mp3|ogg|wav)$'), '');

    // 生成ID
    final id = '${category}_$filename';

    // 生成名称（从文件名转换）
    final name = _filenameToName(filename);

    // 获取分类图标
    final icon = categoryIcons[category] ?? Icons.audiotrack;
    final categoryName = categoryNames[category] ?? category;

    return SoundAsset(
      id: id,
      name: name,
      path: path,
      category: categoryName,
      icon: icon,
      description: null,
    );
  }

  /// 将文件名转换为可读名称
  static String _filenameToName(String filename) {
    // 下划线转空格，首字母大写
    return filename
        .split('_')
        .map(
          (word) => word.isNotEmpty
              ? word[0].toUpperCase() + word.substring(1).toLowerCase()
              : '',
        )
        .join(' ');
  }

  /// 所有音频分类（按Android版本顺序排列）
  static const List<String> allCategories = [
    '自然',
    '雨声',
    '城市',
    '场所',
    '交通',
    '物品',
    '白噪音',
    '动物',
    '音乐',
  ];

  /// 获取所有分类（按Android版本顺序排列）
  static List<String> getCategories() {
    // 按Android版本的顺序排列分类
    final categories = <String>{};
    for (final sound in allSounds) {
      if (sound.category != '全部') {
        categories.add(sound.category);
      }
    }

    // 按Android顺序排列，如果分类不在预定义顺序中，则按字母顺序排在后面
    final sortedCategories = <String>['全部'];
    for (final category in allCategories) {
      if (categories.contains(category)) {
        sortedCategories.add(category);
        categories.remove(category);
      }
    }

    // 添加剩余的分类（按字母顺序）
    if (categories.isNotEmpty) {
      final remaining = categories.toList()..sort();
      sortedCategories.addAll(remaining);
    }

    return sortedCategories;
  }

  /// 获取Android版本繁星页的声音列表
  static List<SoundAsset> getAndroidStarSounds() {
    return _androidStarSounds;
  }

  /// 获取按分类分组的Android繁星页声音
  static Map<String, List<SoundAsset>> getAndroidStarSoundsByCategory() {
    final Map<String, List<SoundAsset>> grouped = {};
    for (final sound in _androidStarSounds) {
      if (!grouped.containsKey(sound.category)) {
        grouped[sound.category] = [];
      }
      grouped[sound.category]!.add(sound);
    }
    return grouped;
  }

  /// 根据分类筛选
  static List<SoundAsset> getByCategory(String category) {
    if (category == '全部') return _fallbackSounds;
    return _fallbackSounds.where((s) => s.category == category).toList();
  }

  /// 从 JSON 创建
  factory SoundAsset.fromJson(Map<String, dynamic> json) {
    return SoundAsset(
      id: json['id'] as String,
      name: json['name'] as String,
      path: json['url'] as String,
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
      'url': path,
      'category': category,
      'iconCode': icon.codePoint,
      'description': description,
    };
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SoundAsset && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
