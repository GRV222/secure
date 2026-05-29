import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../config/route_names.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../services/seed_service.dart';
import '../../../services/notification_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late Animation<double> _logoFade;
  late Animation<double> _logoScale;

  late AnimationController _tagCtrl;
  late Animation<double> _tagFade;
  late Animation<Offset> _tagSlide;

  late AnimationController _mandalaOuter;
  late AnimationController _mandalaInner;
  late AnimationController _mandalaAlt;

  late AnimationController _glowCtrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();

    _logoCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _logoFade =
        CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));

    _tagCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _tagFade =
        CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut);
    _tagSlide = Tween<Offset>(
            begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _tagCtrl, curve: Curves.easeOut));

    _mandalaOuter = AnimationController(
        vsync: this, duration: const Duration(seconds: 10))
      ..repeat();
    _mandalaInner = AnimationController(
        vsync: this, duration: const Duration(seconds: 7))
      ..repeat(reverse: true);
    _mandalaAlt = AnimationController(
        vsync: this, duration: const Duration(seconds: 5))
      ..repeat();

    _glowCtrl = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1800))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.4, end: 0.9).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _logoCtrl.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) _tagCtrl.forward();
      });
      Future.delayed(const Duration(milliseconds: 800), () {
        if (mounted) _init();
      });
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _tagCtrl.dispose();
    _mandalaOuter.dispose();
    _mandalaInner.dispose();
    _mandalaAlt.dispose();
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    try {
      final seedService = SeedService();
      await seedService.seedHashtagsIfEmpty();
      await seedService.seedCompetitionsIfEmpty();
      await seedService.seedPostsIfEmpty();
    } catch (e) {
      debugPrint('Seed error (non-fatal): $e');
    }
    if (!mounted) return;
    try {
      final authProvider = context.read<AuthProvider>();
      await authProvider.initialize();
      if (!mounted) return;
      try {
        await NotificationService().initialize();
        final uid = authProvider.currentUser?.uid;
        if (uid != null) {
          await NotificationService().saveTokenToFirestore(uid);
        }
      } catch (e) {
        debugPrint('FCM init error: $e');
      }
      if (!mounted) return;
      if (authProvider.isSignedIn) {
        context.go(RouteNames.home);
        return;
      }
      final prefs = await SharedPreferences.getInstance();
      if (!mounted) return;
      final onboardingDone = prefs.getBool('onboarding_done') ?? false;
      context.go(
          onboardingDone ? RouteNames.signIn : RouteNames.onboarding);
    } catch (e) {
      debugPrint('Auth init error: $e');
      if (mounted) context.go(RouteNames.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final bg = AppColors.bg(isDigital);

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Mandala background rings
          AnimatedBuilder(
            animation: Listenable.merge(
                [_mandalaOuter, _mandalaInner, _mandalaAlt, _glowCtrl]),
            builder: (context, _) {
              return CustomPaint(
                size: Size(MediaQuery.of(context).size.width,
                    MediaQuery.of(context).size.height),
                painter: _MandalaBackgroundPainter(
                  outerAngle: _mandalaOuter.value * 2 * pi,
                  innerAngle: _mandalaInner.value * 2 * pi,
                  altAngle: _mandalaAlt.value * 2 * pi,
                  color: primary,
                  glowOpacity: _glow.value,
                  isDigital: isDigital,
                ),
              );
            },
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // S logo with glow
              ScaleTransition(
                scale: _logoScale,
                child: FadeTransition(
                  opacity: _logoFade,
                  child: AnimatedBuilder(
                    animation: _glow,
                    builder: (context, child) => Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: primary
                                .withValues(alpha: _glow.value * 0.3),
                            blurRadius: 40,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: child,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.asset(
                        'assets/1024.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              FadeTransition(
                opacity: _logoFade,
                child: Text(
                  'SECURE',
                  style: TextStyle(
                    fontFamily: 'CormorantGaramond',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 10,
                    color: AppColors.textFor(isDigital),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Tagline
              SlideTransition(
                position: _tagSlide,
                child: FadeTransition(
                  opacity: _tagFade,
                  child: Column(
                    children: [
                      Text(
                        'Be Seen. Be Real. Be SECURE.',
                        style: TextStyle(
                          fontFamily: 'CormorantGaramond',
                          fontStyle: FontStyle.italic,
                          fontSize: 15,
                          color: AppColors.textSubFor(isDigital),
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                              width: 40,
                              height: 0.5,
                              color: primary.withValues(alpha: 0.3)),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8),
                            child: Text('✿',
                                style: TextStyle(
                                    color:
                                        primary.withValues(alpha: 0.4),
                                    fontSize: 12)),
                          ),
                          Container(
                              width: 40,
                              height: 0.5,
                              color: primary.withValues(alpha: 0.3)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // Mandala loader
              FadeTransition(
                opacity: _tagFade,
                child: AnimatedBuilder(
                  animation: Listenable.merge(
                      [_mandalaOuter, _mandalaInner, _mandalaAlt]),
                  builder: (context, _) {
                    return SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Transform.rotate(
                            angle: _mandalaOuter.value * 2 * pi,
                            child: _Ring(
                                size: 60,
                                color:
                                    primary.withValues(alpha: 0.25),
                                strokeWidth: 1.2),
                          ),
                          Transform.rotate(
                            angle: -_mandalaInner.value * 2 * pi,
                            child: _Ring(
                                size: 42,
                                color:
                                    primary.withValues(alpha: 0.18),
                                strokeWidth: 1),
                          ),
                          Transform.rotate(
                            angle: _mandalaAlt.value * 2 * pi,
                            child: _Ring(
                                size: 26,
                                color:
                                    primary.withValues(alpha: 0.15),
                                strokeWidth: 0.8),
                          ),
                          Text('✿',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: primary
                                      .withValues(alpha: 0.35))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 40,
            child: FadeTransition(
              opacity: _tagFade,
              child: Text(
                'v1.0.0',
                style: TextStyle(
                  fontSize: 10,
                  letterSpacing: 2,
                  color: AppColors.textSubFor(isDigital)
                      .withValues(alpha: 0.4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final double strokeWidth;
  const _Ring({
    required this.size,
    required this.color,
    required this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: color, width: strokeWidth),
        ),
      ),
    );
  }
}

class _MandalaBackgroundPainter extends CustomPainter {
  final double outerAngle;
  final double innerAngle;
  final double altAngle;
  final Color color;
  final double glowOpacity;
  final bool isDigital;

  const _MandalaBackgroundPainter({
    required this.outerAngle,
    required this.innerAngle,
    required this.altAngle,
    required this.color,
    required this.glowOpacity,
    required this.isDigital,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < 3; i++) {
      final radius = 140.0 + (i * 50);
      paint.color =
          color.withValues(alpha: (0.04 - i * 0.01) * glowOpacity);
      canvas.drawCircle(center, radius, paint);
    }

    final dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = color.withValues(alpha: 0.06 * glowOpacity);

    for (int i = 0; i < 8; i++) {
      final angle = outerAngle + (i / 8) * 2 * pi;
      final x = center.dx + cos(angle) * 160;
      final y = center.dy + sin(angle) * 160;
      canvas.drawCircle(Offset(x, y), 3, dotPaint);
    }

    for (int i = 0; i < 6; i++) {
      final angle = innerAngle + (i / 6) * 2 * pi;
      final x = center.dx + cos(angle) * 110;
      final y = center.dy + sin(angle) * 110;
      canvas.drawCircle(
          Offset(x, y),
          2,
          dotPaint
            ..color = color.withValues(alpha: 0.08 * glowOpacity));
    }
  }

  @override
  bool shouldRepaint(_MandalaBackgroundPainter old) =>
      old.outerAngle != outerAngle ||
      old.innerAngle != innerAngle ||
      old.glowOpacity != glowOpacity;
}
