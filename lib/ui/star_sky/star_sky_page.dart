import 'package:flutter/material.dart';
import 'dart:math';

class StarSkyPage extends StatefulWidget {
  const StarSkyPage({super.key});

  @override
  State<StarSkyPage> createState() => _StarSkyPageState();
}

class _StarSkyPageState extends State<StarSkyPage> 
    with TickerProviderStateMixin {
  late AnimationController _starController;
  late AnimationController _twinkleController;
  final List<Star> _stars = [];
  
  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateStars();
  }

  void _initializeAnimations() {
    _starController = AnimationController(
      duration: const Duration(seconds: 200),
      vsync: this,
    )..repeat();
    
    _twinkleController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  void _generateStars() {
    final random = DateTime.now().millisecondsSinceEpoch;
    for (int i = 0; i < 150; i++) {
      _stars.add(Star(
        x: (random * (i + 1)) % 1000 / 1000,
        y: (random * (i + 2)) % 1000 / 1000,
        size: (random % 5 + 1).toDouble(),
        twinklePhase: (random % 100) / 100.0,
      ));
    }
    setState(() {});
  }

  @override
  void dispose() {
    _starController.dispose();
    _twinkleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF0A0E27),
              const Color(0xFF1A237E),
              const Color(0xFF283593),
            ],
          ),
        ),
        child: Stack(
          children: [
            // 星空背景
            AnimatedBuilder(
              animation: _starController,
              builder: (context, child) {
                return CustomPaint(
                  painter: StarPainter(
                    stars: _stars,
                    animation: _starController.value,
                    twinkleAnimation: _twinkleController.value,
                  ),
                  size: Size.infinite,
                );
              },
            ),
            // 主要内容
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),
                    _buildHeader(),
                    const SizedBox(height: 40),
                    _buildFeatureCards(),
                    const Spacer(),
                    _buildBottomSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '星空',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '探索无限的声音宇宙',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      children: [
        _buildFeatureCard(
          icon: Icons.music_note,
          title: '远程音效',
          subtitle: '连接云端音效库',
          onTap: () {
            // TODO: 实现远程音效功能
          },
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.folder,
          title: '本地音频',
          subtitle: '导入本地音频文件',
          onTap: () {
            // TODO: 实现本地音频功能
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.7),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.auto_awesome,
                color: Colors.white.withOpacity(0.8),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '星空模式',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '在浩瀚星空下享受宁静的声音体验',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class Star {
  final double x;
  final double y;
  final double size;
  final double twinklePhase;

  Star({
    required this.x,
    required this.y,
    required this.size,
    required this.twinklePhase,
  });
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  final double animation;
  final double twinkleAnimation;

  StarPainter({
    required this.stars,
    required this.animation,
    required this.twinkleAnimation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      final x = star.x * size.width;
      final y = (star.y + animation * 0.1) % 1.0 * size.height;
      
      // 计算闪烁效果
      final twinkle = (sin((star.twinklePhase + twinkleAnimation) * 2 * pi) + 1) / 2;
      final opacity = 0.3 + twinkle * 0.7;
      
      paint.color = Colors.white.withOpacity(opacity);
      canvas.drawCircle(
        Offset(x, y),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) {
    return oldDelegate.animation != animation || 
           oldDelegate.twinkleAnimation != twinkleAnimation;
  }
}
