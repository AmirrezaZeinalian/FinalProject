import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math';

// import 'package:learngetx/introWalk.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  late AnimationController _iconRotationController;
  late AnimationController _colorPulseController;

  double progressValue = 0.0;
  Timer? _timer;
  final List<_FloatingNote> _floatingNotes = [];
  final List<_Particle> _particles = [];
  final List<_Spark> _sparks = [];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeIn),
    );
    _fadeController.forward();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.7, end: 1.2).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    _iconRotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _colorPulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _timer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      setState(() {
        progressValue += 0.005;
        if (progressValue >= 1.0) {
          progressValue = 1.0;
          timer.cancel();
          Future.delayed(const Duration(milliseconds: 500), () {
            Get.offAllNamed('/home');
          });
        }

        // اضافه کردن نوت‌های شناور به‌صورت تصادفی
        if (Random().nextDouble() < 0.08) {
          _floatingNotes.add(_FloatingNote());
        }

        // اضافه کردن ذرات پراکنده به‌صورت تصادفی
        if (_particles.length < 100 && Random().nextDouble() < 0.05) {
          _particles.add(_Particle(
            x: Random().nextDouble() * MediaQuery.of(context).size.width,
            y: Random().nextDouble() * MediaQuery.of(context).size.height,
            size: Random().nextDouble() * 2 + 1,
            speed: Random().nextDouble() * 0.5 + 0.1,
          ));
        }

        // اضافه کردن جرقه‌ها اطراف آیکن به صورت تصادفی
        if (_sparks.length < 20 && Random().nextDouble() < 0.1) {
          _sparks.add(_Spark(
            centerX: MediaQuery.of(context).size.width / 2,
            centerY: MediaQuery.of(context).size.height / 2 - 50,
          ));
        }

        // به‌روزرسانی وضعیت نوت‌ها
        for (var note in _floatingNotes) {
          note.update();
        }
        _floatingNotes.removeWhere((note) => note.opacity <= 0);

        // به‌روزرسانی ذرات پراکنده
        for (var particle in _particles) {
          particle.update();
        }
        _particles.removeWhere((p) => p.opacity <= 0);

        // به‌روزرسانی جرقه‌ها
        for (var spark in _sparks) {
          spark.update();
        }
        _sparks.removeWhere((spark) => spark.opacity <= 0);
      });
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _glowController.dispose();
    _iconRotationController.dispose();
    _colorPulseController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  Color lerpPurple(Color start, Color end, double t) {
    return Color.lerp(start, end, t.clamp(0.0, 1.0))!;
  }

  // تابع جدید برای رنگین کمانی کردن رنگ نت‌های موسیقی
  Color rainbowColor(double t) {
    final hue = (t * 360) % 360;
    return HSVColor.fromAHSV(1, hue, 0.8, 1).toColor();
  }


  @override
  Widget build(BuildContext context) {
    double barWidth = 250;
    double barHeight = 6;
    double ballSize = 24;

    final Color basePurple = const Color(0xFFDAB6F8);
    final Color deepPurple = const Color(0xFF9C27B0);

    final dynamicPurple = lerpPurple(basePurple, deepPurple, progressValue);

    // رنگ متغیر برای درخشش pulsating (بین بنفش و صورتی روشن)
    final glowColor = Color.lerp(
      Colors.purple.shade300,
      Colors.pink.shade300,
      _colorPulseController.value,
    )!;

    return Scaffold(
      backgroundColor: const Color(0xFF2B1055),
      body: Stack(
        children: [
          // ذرات پراکنده (ستاره‌های ریز)
          ..._particles.map((particle) {
            return Positioned(
              left: particle.x,
              top: particle.y,
              child: Opacity(
                opacity: particle.opacity,
                child: Container(
                  width: particle.size,
                  height: particle.size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.7),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 4,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                ),
              ),
            );
          }),

          // پس‌زمینه با پرتو بنفش متحرک
          AnimatedBuilder(
            animation: _iconRotationController,
            builder: (context, child) {
              return CustomPaint(
                size: MediaQuery.of(context).size,
                painter: _LightRayPainter(_iconRotationController.value, dynamicPurple),
              );
            },
          ),

          // نوت‌های شناور بنفش با چرخش و رنگین کمانی
          ..._floatingNotes.map((note) => Positioned(
            left: note.x,
            top: note.y,
            child: Opacity(
              opacity: note.opacity,
              child: RotationTransition(
                turns: AlwaysStoppedAnimation(note.rotation),
                child: Icon(
                  Icons.music_note,
                  color: rainbowColor(note.rotation) .withOpacity(0.8),
                  size: note.size,
                ),
              ),
            ),
          )),

          // نور پراکنده متحرک دایره‌ای (Radial Burst)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return CustomPaint(
                  painter: _RadialBurstPainter(
                    glowColor.withOpacity(0.3 * _glowAnimation.value),
                  ),
                );
              },
            ),
          ),

          // جرقه‌های کوچک اطراف آیکن اصلی
          ..._sparks.map((spark) {
            return Positioned(
              left: spark.x,
              top: spark.y,
              child: Opacity(
                opacity: spark.opacity,
                child: Container(
                  width: spark.size,
                  height: spark.size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.8),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),


          // محتوای اصلی وسط
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // آیکن اصلی با درخشش متغیر و pulsating glow
                  ScaleTransition(
                    scale: _glowAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: glowColor.withOpacity(0.8),
                            blurRadius: 60,
                            spreadRadius: 15,
                          ),
                        ],
                      ),
                      child: Icon(Icons.headphones, size: 110, color: glowColor),
                    ),
                  ),
                  const SizedBox(height: 20),


                  // نام اپ
                  const Text(
                    'Purple Beats',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          blurRadius: 6,
                          color: Colors.black45,
                          offset: Offset(2, 3),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),

                  // نوار پیشرفت با افکت موج نوری زیر آن
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: barWidth,
                        height: barHeight * 2,
                        child: CustomPaint(
                          painter: _LightWavePainter(progressValue, dynamicPurple),
                        ),
                      ),
                      SizedBox(
                        width: barWidth,
                        height: 30,
                        child: Stack(
                          alignment: Alignment.centerLeft,
                          children: [
                            Container(
                              width: barWidth,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: dynamicPurple.withOpacity(0.25),
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Container(
                              width: barWidth * progressValue,
                              height: barHeight,
                              decoration: BoxDecoration(
                                color: dynamicPurple,
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            Positioned(
                              left: (barWidth * progressValue) - (ballSize / 2),
                              child: RotationTransition(
                                turns: _iconRotationController,
                                child: Icon(Icons.music_note, color: dynamicPurple, size: ballSize),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// --- مدل‌ها ---


class _FloatingNote {
  double x = Random().nextDouble() * 300 + 40;
  double y = 700;
  double opacity = 1;
  double size = Random().nextDouble() * 14 + 12;
  double speed = Random().nextDouble() * 1.3 + 0.7;
  double rotation = Random().nextDouble() * 2 * pi;

  void update() {
    y -= speed;
    opacity -= 0.012;
    rotation += 0.05;
  }
}

class _Particle {
  double x;
  double y;
  double size;
  double speed;
  double opacity = 1;

  _Particle({required this.x, required this.y, required this.size, required this.speed});

  void update() {
    y -= speed / 2;
    opacity -= 0.008;
    if (opacity < 0) opacity = 0;
  }
}

class _Spark {
  double x;
  double y;
  double size;
  double opacity = 1;
  double speedX;
  double speedY;


  _Spark({required double centerX, required double centerY})
      : x = centerX + (Random().nextDouble() * 60 - 30),
        y = centerY + (Random().nextDouble() * 60 - 30),
        size = Random().nextDouble() * 4 + 2,
        speedX = (Random().nextDouble() - 0.5) * 1.5,
        speedY = (Random().nextDouble() - 0.5) * 1.5;

  void update() {
    x += speedX;
    y += speedY;
    opacity -= 0.03;
    if (opacity < 0) opacity = 0;
  }
}

// --- Painter ها ---

class _LightRayPainter extends CustomPainter {
  final double animationValue;
  final Color dynamicPurple;
  _LightRayPainter(this.animationValue, this.dynamicPurple);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          dynamicPurple.withOpacity(0.05),
          Colors.transparent,
        ],
        stops: [animationValue, animationValue + 0.1],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _LightRayPainter oldDelegate) => true;
}

class _RadialBurstPainter extends CustomPainter {
  final Color color;

  _RadialBurstPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) * 0.7;

    final gradient = RadialGradient(
      colors: [color, Colors.transparent],
      stops: [0.0, 1.0],
    );

    final paint = Paint()
      ..shader = gradient.createShader(Rect.fromCircle(center: center, radius: radius));

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _RadialBurstPainter oldDelegate) => true;
}

class _LightWavePainter extends CustomPainter {
  final double progress;
  final Color color;

  _LightWavePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final waveHeight = 6.0;
    final waveLength = 60.0;
    final speed = progress * 2 * pi;

    final paint = Paint()
      ..color = color.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    final path = Path();

    for (double x = 0; x <= size.width; x++) {
      double y = waveHeight * sin((x / waveLength * 2 * pi) + speed) + waveHeight;
      if (x == 0) {
        path.moveTo(x, size.height - y);
      } else {
        path.lineTo(x, size.height - y);
      }
    }
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
  }
  @override
  bool shouldRepaint(covariant _LightWavePainter oldDelegate) => true;
}