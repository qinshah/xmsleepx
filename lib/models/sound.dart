import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
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
  static List<Sound> allSounds = [];

  /// 已扫描的路径缓存
  static final Set<String> _scannedPaths = {};

  /// 初始化扫描所有音频文件
  static Future<void> scanAssets() async {
    // 使用 compute 将扫描操作放到 isolate 中
    allSounds = await compute(_scanAssetsDirectoryIsolate, 'assets/sounds');
  }

  /// 在 isolate 中扫描 assets 目录
  static Future<List<Sound>> _scanAssetsDirectoryIsolate(String path) async {
    return await _scanAssetsDirectory(path);
  }

  /// 扫描 assets 目录下的所有音频文件，并对 AssetManifest 做更健壮的解析
  static Future<List<Sound>> _scanAssetsDirectory(String path) async {
    final sounds = <Sound>[];

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

  /// 硬编码的音频列表（备选方案）
  static final List<Sound> _fallbackSounds = [
    // Rain sounds
    Sound(
      id: 'rain_drizzle',
      name: 'Drizzle',
      url: 'assets/sounds/rain/drizzle.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_heavy_rain',
      name: 'Heavy Rain',
      url: 'assets/sounds/rain/heavy_rain.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_heavy_rain_on_glass',
      name: 'Heavy Rain On Glass',
      url: 'assets/sounds/rain/heavy-rain-on-glass.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_light_rain',
      name: 'Light Rain',
      url: 'assets/sounds/rain/light-rain.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_car_roof',
      name: 'Rain On Car Roof',
      url: 'assets/sounds/rain/rain-on-car-roof.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_eaves',
      name: 'Rain On Eaves',
      url: 'assets/sounds/rain/rain-on-eaves.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_empty_street',
      name: 'Rain On Empty Street',
      url: 'assets/sounds/rain/rain-on-empty-street.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_leaves',
      name: 'Rain On Leaves',
      url: 'assets/sounds/rain/rain-on-leaves.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_raincoat',
      name: 'Rain On Raincoat',
      url: 'assets/sounds/rain/rain-on-raincoat.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_tent',
      name: 'Rain On Tent',
      url: 'assets/sounds/rain/rain-on-tent.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_umbrella',
      name: 'Rain On Umbrella',
      url: 'assets/sounds/rain/rain-on-umbrella.ogg',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_windowsill',
      name: 'Rain On Windowsill',
      url: 'assets/sounds/rain/rain-on-windowsill.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_on_wooden_house',
      name: 'Rain On Wooden House',
      url: 'assets/sounds/rain/rain-on-wooden-house.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_rain_while_driving',
      name: 'Rain While Driving',
      url: 'assets/sounds/rain/rain-while-driving.mp3',
      category: '雨声',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'rain_thunderstorm',
      name: 'Thunderstorm',
      url: 'assets/sounds/rain/thunderstorm.ogg',
      category: '雨声',
      icon: Icons.thunderstorm,
    ),

    // Nature sounds
    Sound(
      id: 'nature_campfire',
      name: 'Campfire',
      url: 'assets/sounds/nature/campfire.ogg',
      category: '自然',
      icon: Icons.local_fire_department,
    ),
    Sound(
      id: 'nature_droplets',
      name: 'Droplets',
      url: 'assets/sounds/nature/droplets.ogg',
      category: '自然',
      icon: Icons.water_drop,
    ),
    Sound(
      id: 'nature_howling_wind',
      name: 'Howling Wind',
      url: 'assets/sounds/nature/howling-wind.ogg',
      category: '自然',
      icon: Icons.air,
    ),
    Sound(
      id: 'nature_jungle',
      name: 'Jungle',
      url: 'assets/sounds/nature/jungle.ogg',
      category: '自然',
      icon: Icons.park,
    ),
    Sound(
      id: 'nature_river',
      name: 'River',
      url: 'assets/sounds/nature/river.ogg',
      category: '自然',
      icon: Icons.water,
    ),
    Sound(
      id: 'nature_walk_in_snow',
      name: 'Walk In Snow',
      url: 'assets/sounds/nature/walk-in-snow.ogg',
      category: '自然',
      icon: Icons.ac_unit,
    ),
    Sound(
      id: 'nature_walk_on_gravel',
      name: 'Walk On Gravel',
      url: 'assets/sounds/nature/walk-on-gravel.ogg',
      category: '自然',
      icon: Icons.directions_walk,
    ),
    Sound(
      id: 'nature_walk_on_leaves',
      name: 'Walk On Leaves',
      url: 'assets/sounds/nature/walk-on-leaves.ogg',
      category: '自然',
      icon: Icons.grass,
    ),
    Sound(
      id: 'nature_waterfall',
      name: 'Waterfall',
      url: 'assets/sounds/nature/waterfall.ogg',
      category: '自然',
      icon: Icons.water,
    ),
    Sound(
      id: 'nature_waves',
      name: 'Waves',
      url: 'assets/sounds/nature/waves.ogg',
      category: '自然',
      icon: Icons.waves,
    ),
    Sound(
      id: 'nature_wind_in_trees',
      name: 'Wind In Trees',
      url: 'assets/sounds/nature/wind-in-trees.ogg',
      category: '自然',
      icon: Icons.terrain,
    ),
    Sound(
      id: 'nature_wind',
      name: 'Wind',
      url: 'assets/sounds/nature/wind.ogg',
      category: '自然',
      icon: Icons.air,
    ),

    // Noise sounds
    Sound(
      id: 'noise_brown_noise',
      name: 'Brown Noise',
      url: 'assets/sounds/noise/brown-noise.ogg',
      category: '白噪音',
      icon: Icons.graphic_eq,
    ),
    Sound(
      id: 'noise_eating_chips',
      name: 'Eating Chips',
      url: 'assets/sounds/noise/eating-chips.ogg',
      category: '白噪音',
      icon: Icons.restaurant,
    ),
    Sound(
      id: 'noise_piano',
      name: 'Piano',
      url: 'assets/sounds/noise/piano.ogg',
      category: '白噪音',
      icon: Icons.piano,
    ),
    Sound(
      id: 'noise_pink_noise',
      name: 'Pink Noise',
      url: 'assets/sounds/noise/pink-noise.ogg',
      category: '白噪音',
      icon: Icons.graphic_eq,
    ),
    Sound(
      id: 'noise_study',
      name: 'Study',
      url: 'assets/sounds/noise/study.ogg',
      category: '白噪音',
      icon: Icons.menu_book,
    ),
    Sound(
      id: 'noise_white_noise',
      name: 'White Noise',
      url: 'assets/sounds/noise/white-noise.ogg',
      category: '白噪音',
      icon: Icons.graphic_eq,
    ),

    // Music sounds
    Sound(
      id: 'music_古筝',
      name: '古筝',
      url: 'assets/sounds/music/古筝.wav',
      category: '音乐',
      icon: Icons.music_note,
    ),
    Sound(
      id: 'music_吉他',
      name: '吉他',
      url: 'assets/sounds/music/吉他.wav',
      category: '音乐',
      icon: Icons.music_note,
    ),
    Sound(
      id: 'music_轻钢琴',
      name: '轻钢琴',
      url: 'assets/sounds/music/轻钢琴.wav',
      category: '音乐',
      icon: Icons.music_note,
    ),
    Sound(
      id: 'music_田野',
      name: '田野',
      url: 'assets/sounds/music/田野.mp3',
      category: '音乐',
      icon: Icons.music_note,
    ),

    // Urban sounds
    Sound(
      id: 'urban_ambulance_siren',
      name: 'Ambulance Siren',
      url: 'assets/sounds/urban/ambulance-siren.mp3',
      category: '城市',
      icon: Icons.local_hospital,
    ),
    Sound(
      id: 'urban_busy_street',
      name: 'Busy Street',
      url: 'assets/sounds/urban/busy-street.mp3',
      category: '城市',
      icon: Icons.location_city,
    ),
    Sound(
      id: 'urban_crowd',
      name: 'Crowd',
      url: 'assets/sounds/urban/crowd.mp3',
      category: '城市',
      icon: Icons.people,
    ),
    Sound(
      id: 'urban_fireworks',
      name: 'Fireworks',
      url: 'assets/sounds/urban/fireworks.mp3',
      category: '城市',
      icon: Icons.celebration,
    ),
    Sound(
      id: 'urban_highway',
      name: 'Highway',
      url: 'assets/sounds/urban/highway.mp3',
      category: '城市',
      icon: Icons.directions_car,
    ),
    Sound(
      id: 'urban_road',
      name: 'Road',
      url: 'assets/sounds/urban/road.mp3',
      category: '城市',
      icon: Icons.route,
    ),
    Sound(
      id: 'urban_traffic',
      name: 'Traffic',
      url: 'assets/sounds/urban/traffic.mp3',
      category: '城市',
      icon: Icons.traffic,
    ),

    // Places sounds
    Sound(
      id: 'places_airport',
      name: 'Airport',
      url: 'assets/sounds/places/airport.mp3',
      category: '场所',
      icon: Icons.flight,
    ),
    Sound(
      id: 'places_cafe',
      name: 'Cafe',
      url: 'assets/sounds/places/cafe.mp3',
      category: '场所',
      icon: Icons.local_cafe,
    ),
    Sound(
      id: 'places_carousel',
      name: 'Carousel',
      url: 'assets/sounds/places/carousel.mp3',
      category: '场所',
      icon: Icons.attractions,
    ),
    Sound(
      id: 'places_church',
      name: 'Church',
      url: 'assets/sounds/places/church.mp3',
      category: '场所',
      icon: Icons.church,
    ),
    Sound(
      id: 'places_construction_site',
      name: 'Construction Site',
      url: 'assets/sounds/places/construction-site.mp3',
      category: '场所',
      icon: Icons.construction,
    ),
    Sound(
      id: 'places_crowded_bar',
      name: 'Crowded Bar',
      url: 'assets/sounds/places/crowded-bar.mp3',
      category: '场所',
      icon: Icons.local_bar,
    ),
    Sound(
      id: 'places_kitchen',
      name: 'Kitchen',
      url: 'assets/sounds/places/kitchen.ogg',
      category: '场所',
      icon: Icons.kitchen,
    ),
    Sound(
      id: 'places_laboratory',
      name: 'Laboratory',
      url: 'assets/sounds/places/laboratory.mp3',
      category: '场所',
      icon: Icons.science,
    ),
    Sound(
      id: 'places_laundry_room',
      name: 'Laundry Room',
      url: 'assets/sounds/places/laundry-room.mp3',
      category: '场所',
      icon: Icons.local_laundry_service,
    ),
    Sound(
      id: 'places_library',
      name: 'Library',
      url: 'assets/sounds/places/library.mp3',
      category: '场所',
      icon: Icons.library_books,
    ),
    Sound(
      id: 'places_night_village',
      name: 'Night Village',
      url: 'assets/sounds/places/night-village.mp3',
      category: '场所',
      icon: Icons.nights_stay,
    ),
    Sound(
      id: 'places_office',
      name: 'Office',
      url: 'assets/sounds/places/office.mp3',
      category: '场所',
      icon: Icons.computer,
    ),
    Sound(
      id: 'places_restaurant',
      name: 'Restaurant',
      url: 'assets/sounds/places/restaurant.mp3',
      category: '场所',
      icon: Icons.restaurant,
    ),
    Sound(
      id: 'places_subway_station',
      name: 'Subway Station',
      url: 'assets/sounds/places/subway-station.mp3',
      category: '场所',
      icon: Icons.train,
    ),
    Sound(
      id: 'places_supermarket',
      name: 'Supermarket',
      url: 'assets/sounds/places/supermarket.mp3',
      category: '场所',
      icon: Icons.shopping_cart,
    ),
    Sound(
      id: 'places_temple',
      name: 'Temple',
      url: 'assets/sounds/places/temple.mp3',
      category: '场所',
      icon: Icons.house,
    ),
    Sound(
      id: 'places_underwater',
      name: 'Underwater',
      url: 'assets/sounds/places/underwater.mp3',
      category: '场所',
      icon: Icons.water,
    ),

    // Transport sounds
    Sound(
      id: 'transport_airplane',
      name: 'Airplane',
      url: 'assets/sounds/transport/airplane.mp3',
      category: '交通',
      icon: Icons.flight,
    ),
    Sound(
      id: 'transport_inside_a_train',
      name: 'Inside A Train',
      url: 'assets/sounds/transport/inside-a-train.mp3',
      category: '交通',
      icon: Icons.train,
    ),
    Sound(
      id: 'transport_rowing_boat',
      name: 'Rowing Boat',
      url: 'assets/sounds/transport/rowing-boat.mp3',
      category: '交通',
      icon: Icons.sailing,
    ),
    Sound(
      id: 'transport_sailboat',
      name: 'Sailboat',
      url: 'assets/sounds/transport/sailboat.mp3',
      category: '交通',
      icon: Icons.sailing,
    ),
    Sound(
      id: 'transport_submarine',
      name: 'Submarine',
      url: 'assets/sounds/transport/submarine.mp3',
      category: '交通',
      icon: Icons.directions_boat,
    ),
    Sound(
      id: 'transport_train',
      name: 'Train',
      url: 'assets/sounds/transport/train.mp3',
      category: '交通',
      icon: Icons.train,
    ),

    // Animals sounds
    Sound(
      id: 'animals_beehive',
      name: 'Beehive',
      url: 'assets/sounds/animals/beehive.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_birds',
      name: 'Birds',
      url: 'assets/sounds/animals/birds.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_cat_purring',
      name: 'Cat Purring',
      url: 'assets/sounds/animals/cat-purring.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_chickens',
      name: 'Chickens',
      url: 'assets/sounds/animals/chickens.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_cows',
      name: 'Cows',
      url: 'assets/sounds/animals/cows.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_crickets',
      name: 'Crickets',
      url: 'assets/sounds/animals/crickets.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_crows',
      name: 'Crows',
      url: 'assets/sounds/animals/crows.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_dog_barking',
      name: 'Dog Barking',
      url: 'assets/sounds/animals/dog-barking.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_frog',
      name: 'Frog',
      url: 'assets/sounds/animals/frog.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_horse_gallop',
      name: 'Horse Gallop',
      url: 'assets/sounds/animals/horse-gallop.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_owl',
      name: 'Owl',
      url: 'assets/sounds/animals/owl.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_seagulls',
      name: 'Seagulls',
      url: 'assets/sounds/animals/seagulls.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_sheep',
      name: 'Sheep',
      url: 'assets/sounds/animals/sheep.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_whale',
      name: 'Whale',
      url: 'assets/sounds/animals/whale.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_wolf',
      name: 'Wolf',
      url: 'assets/sounds/animals/wolf.ogg',
      category: '动物',
      icon: Icons.pets,
    ),
    Sound(
      id: 'animals_woodpecker',
      name: 'Woodpecker',
      url: 'assets/sounds/animals/woodpecker.ogg',
      category: '动物',
      icon: Icons.pets,
    ),

    // Things sounds
    Sound(
      id: 'things_boiling_water',
      name: 'Boiling Water',
      url: 'assets/sounds/things/boiling-water.mp3',
      category: '物品',
      icon: Icons.kitchen,
    ),
    Sound(
      id: 'things_bubbles',
      name: 'Bubbles',
      url: 'assets/sounds/things/bubbles.mp3',
      category: '物品',
      icon: Icons.ac_unit,
    ),
    Sound(
      id: 'things_ceiling_fan',
      name: 'Ceiling Fan',
      url: 'assets/sounds/things/ceiling-fan.mp3',
      category: '物品',
      icon: Icons.ac_unit,
    ),
    Sound(
      id: 'things_clock',
      name: 'Clock',
      url: 'assets/sounds/things/clock.mp3',
      category: '物品',
      icon: Icons.access_time,
    ),
    Sound(
      id: 'things_dryer',
      name: 'Dryer',
      url: 'assets/sounds/things/dryer.mp3',
      category: '物品',
      icon: Icons.local_laundry_service,
    ),
    Sound(
      id: 'things_ear_cleaning_1',
      name: 'Ear Cleaning 1',
      url: 'assets/sounds/things/ear-cleaning-1.mp3',
      category: '物品',
      icon: Icons.hearing,
    ),
    Sound(
      id: 'things_ear_cleaning_2',
      name: 'Ear Cleaning 2',
      url: 'assets/sounds/things/ear-cleaning-2.mp3',
      category: '物品',
      icon: Icons.hearing,
    ),
    Sound(
      id: 'things_keyboard',
      name: 'Keyboard',
      url: 'assets/sounds/things/keyboard.mp3',
      category: '物品',
      icon: Icons.keyboard,
    ),
    Sound(
      id: 'things_morse_code',
      name: 'Morse Code',
      url: 'assets/sounds/things/morse-code.mp3',
      category: '物品',
      icon: Icons.code,
    ),
    Sound(
      id: 'things_paper',
      name: 'Paper',
      url: 'assets/sounds/things/paper.mp3',
      category: '物品',
      icon: Icons.description,
    ),
    Sound(
      id: 'things_singing_bowl',
      name: 'Singing Bowl',
      url: 'assets/sounds/things/singing-bowl.mp3',
      category: '物品',
      icon: Icons.music_note,
    ),
    Sound(
      id: 'things_slide_projector',
      name: 'Slide Projector',
      url: 'assets/sounds/things/slide-projector.mp3',
      category: '物品',
      icon: Icons.slideshow,
    ),
    Sound(
      id: 'things_tuning_radio',
      name: 'Tuning Radio',
      url: 'assets/sounds/things/tuning-radio.mp3',
      category: '物品',
      icon: Icons.radio,
    ),
    Sound(
      id: 'things_typewriter',
      name: 'Typewriter',
      url: 'assets/sounds/things/typewriter.mp3',
      category: '物品',
      icon: Icons.keyboard,
    ),
    Sound(
      id: 'things_vinyl_effect',
      name: 'Vinyl Effect',
      url: 'assets/sounds/things/vinyl-effect.mp3',
      category: '物品',
      icon: Icons.album,
    ),
    Sound(
      id: 'things_washing_machine',
      name: 'Washing Machine',
      url: 'assets/sounds/things/washing-machine.mp3',
      category: '物品',
      icon: Icons.local_laundry_service,
    ),
    Sound(
      id: 'things_wind_chimes',
      name: 'Wind Chimes',
      url: 'assets/sounds/things/wind-chimes.mp3',
      category: '物品',
      icon: Icons.music_note,
    ),
    Sound(
      id: 'things_windshield_wipers',
      name: 'Windshield Wipers',
      url: 'assets/sounds/things/windshield-wipers.mp3',
      category: '物品',
      icon: Icons.ac_unit,
    ),
  ];

  /// 将文件路径转换为 Sound 对象
  static Sound? _pathToSound(String path) {
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

    return Sound(
      id: id,
      name: name,
      url: path,
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

  /// 获取所有分类
  static List<String> getCategories() {
    final categories = <String>{};
    for (final sound in allSounds) {
      if (sound.category != '全部') {
        categories.add(sound.category);
      }
    }
    final sortedCategories = categories.toList()..sort();
    return ['全部', ...sortedCategories];
  }

  /// 根据分类筛选
  static List<Sound> getByCategory(String category) {
    if (category == '全部') return allSounds;
    return allSounds.where((s) => s.category == category).toList();
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
