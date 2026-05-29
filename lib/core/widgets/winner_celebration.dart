import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../constants/app_colors.dart';
import '../providers/theme_provider.dart';

class WinnerCelebration extends StatefulWidget {
  final String winnerName;
  final String hashtag;
  final double ratingAvg;
  final int ratingCount;
  final VoidCallback? onDismiss;

  const WinnerCelebration({
    super.key,
    required this.winnerName,
    required this.hashtag,
    required this.ratingAvg,
    required this.ratingCount,
    this.onDismiss,
  });

  @override
  State<WinnerCelebration> createState() => _WinnerCelebrationState();
}

class _WinnerCelebrationState extends State<WinnerCelebration>
    with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _confettiCtrl;
  late AnimationController _trophyCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _starsCtrl;

  late Animation<double> _entranceFade;
  late Animation<double> _entranceScale;
  late Animation<double> _trophyBounce;
  late Animation<double> _glow;
  late Animation<double> _starsRotate;

  final List<_ConfettiPiece> _confetti = [];
  final Random _rng = Random();

  @override
  void initState() {
    super.initState();

    for (int i = 0; i < 40; i++) {
      _confetti.add(_ConfettiPiece(
        x: _rng.nextDouble(),
        delay: _rng.nextDouble() * 0.6,
        speed: 0.4 + _rng.nextDouble() * 0.6,
        size: 4 + _rng.nextDouble() * 6,
        color: [
          AppColors.tradGold,
          AppColors.tradPrimary,
          AppColors.mauve,
          const Color(0xFFE8B4A0),
          const Color(0xFFC9A227),
        ][_rng.nextInt(5)],
        rotation: _rng.nextDouble() * 2 * pi,
        isCircle: _rng.nextBool(),
      ));
    }

    _entranceCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _entranceFade =
        CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _entranceScale = Tween<double>(begin: 0.5, end: 1.0).animate(
        CurvedAnimation(
            parent: _entranceCtrl, curve: Curves.elasticOut));

    _confettiCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3));

    _trophyCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _trophyBounce = TweenSequence([
      TweenSequenceItem(
          tween: Tween<double>(begin: 0, end: -20)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 40),
      TweenSequenceItem(
          tween: Tween<double>(begin: -20, end: 4)
              .chain(CurveTween(curve: Curves.easeIn)),
          weight: 30),
      TweenSequenceItem(
          tween: Tween<double>(begin: 4, end: 0)
              .chain(CurveTween(curve: Curves.easeOut)),
          weight: 30),
    ]).animate(_trophyCtrl);

    _glowCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1500))
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: 0.3, end: 0.8).animate(
        CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _starsCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 6))
      ..repeat();
    _starsRotate =
        Tween<double>(begin: 0, end: 2 * pi).animate(_starsCtrl);

    _entranceCtrl.forward().then((_) {
      _confettiCtrl.forward();
      _trophyCtrl.forward();
      HapticFeedback.heavyImpact();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _trophyCtrl.repeat(
              period: const Duration(seconds: 3));
        }
      });
    });
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _confettiCtrl.dispose();
    _trophyCtrl.dispose();
    _glowCtrl.dispose();
    _starsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDigital = context.watch<ThemeProvider>().isDigital;
    final primary = AppColors.adaptivePrimary(isDigital);
    final gold = AppColors.gold;

    return ScaleTransition(
      scale: _entranceScale,
      child: FadeTransition(
        opacity: _entranceFade,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDigital
                  ? [
                      const Color(0xFF2E2024),
                      const Color(0xFF3D2830),
                      const Color(0xFF2A1E22),
                    ]
                  : [
                      const Color(0xFFFDF6F0),
                      const Color(0xFFF5E8D8),
                      const Color(0xFFEDD5B0),
                    ],
            ),
            border: Border.all(
                color: gold.withValues(alpha: 0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: gold.withValues(alpha: 0.2),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Confetti layer
              AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (context, _) => CustomPaint(
                  size: const Size(double.infinity, 200),
                  painter: _ConfettiPainter(
                    pieces: _confetti,
                    progress: _confettiCtrl.value,
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Trophy with bounce + glow
                    AnimatedBuilder(
                      animation:
                          Listenable.merge([_trophyBounce, _glow]),
                      builder: (context, _) => Transform.translate(
                        offset: Offset(0, _trophyBounce.value),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: gold.withValues(
                                    alpha: _glow.value * 0.5),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Text('🏆',
                              style: TextStyle(fontSize: 64)),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Animated stars
                    AnimatedBuilder(
                      animation: _starsRotate,
                      builder: (context, _) {
                        return SizedBox(
                          width: 100,
                          height: 24,
                          child: Stack(
                            alignment: Alignment.center,
                            children: List.generate(5, (i) {
                              const spacing = 18.0;
                              return Positioned(
                                left: i * spacing,
                                child: Transform.scale(
                                  scale: 1.0 +
                                      0.2 *
                                          sin(_starsRotate.value +
                                              i * pi / 2.5),
                                  child: Text('★',
                                      style: TextStyle(
                                        color: gold,
                                        fontSize: 16,
                                        shadows: [
                                          Shadow(
                                              color: gold.withValues(
                                                  alpha: 0.6),
                                              blurRadius: 8)
                                        ],
                                      )),
                                ),
                              );
                            }),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    Text(
                      'Competition Winner',
                      style: TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontSize: 14,
                        letterSpacing: 3,
                        color: isDigital
                            ? AppColors.digTextSub
                            : AppColors.tradTextSub,
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      widget.winnerName,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'CormorantGaramond',
                        fontSize: 28,
                        fontWeight: FontWeight.w600,
                        color: isDigital
                            ? AppColors.digText
                            : AppColors.tradText,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: primary.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        '#${widget.hashtag}',
                        style: TextStyle(
                          color: primary,
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('★★★★★',
                            style: TextStyle(
                              color: gold,
                              fontSize: 18,
                              shadows: [
                                Shadow(
                                    color: gold.withValues(alpha: 0.5),
                                    blurRadius: 8)
                              ],
                            )),
                        const SizedBox(width: 10),
                        Text(
                          widget.ratingAvg.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            color: gold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(${widget.ratingCount} ratings)',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDigital
                                ? AppColors.digTextSub
                                : AppColors.tradTextSub,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    Row(
                      children: [
                        Expanded(
                            child: Container(
                                height: 0.5,
                                color: gold.withValues(alpha: 0.2))),
                        Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          child: Text('✿',
                              style: TextStyle(
                                  color: gold.withValues(alpha: 0.4),
                                  fontSize: 14)),
                        ),
                        Expanded(
                            child: Container(
                                height: 0.5,
                                color: gold.withValues(alpha: 0.2))),
                      ],
                    ),

                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 12),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [gold, primary]),
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: gold.withValues(alpha: 0.3),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: const Text(
                          'Celebrate! 🎉',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConfettiPiece {
  final double x;
  final double delay;
  final double speed;
  final double size;
  final Color color;
  final double rotation;
  final bool isCircle;

  const _ConfettiPiece({
    required this.x,
    required this.delay,
    required this.speed,
    required this.size,
    required this.color,
    required this.rotation,
    required this.isCircle,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiPiece> pieces;
  final double progress;

  const _ConfettiPainter({
    required this.pieces,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final piece in pieces) {
      final adjustedProgress =
          ((progress - piece.delay) / (1 - piece.delay))
              .clamp(0.0, 1.0);
      if (adjustedProgress <= 0) continue;

      final paint = Paint()
        ..color =
            piece.color.withValues(alpha: (1 - adjustedProgress) * 0.9);

      final x = piece.x * size.width;
      final y = adjustedProgress * size.height * piece.speed;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(piece.rotation + adjustedProgress * 4);

      if (piece.isCircle) {
        canvas.drawCircle(Offset.zero, piece.size / 2, paint);
      } else {
        canvas.drawRect(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.6,
          ),
          paint,
        );
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) =>
      old.progress != progress;
}
